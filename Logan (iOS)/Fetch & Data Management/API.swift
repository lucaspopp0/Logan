//
//  API.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 4/15/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import Foundation

typealias Blob = [String: Any]

class API: NSObject {
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    struct ResponseError: Error, LocalizedError {
        let message: String
        
        init(_ message: String) {
            self.message = message
        }
        
        var errorDescription: String? {
            return message
        }
    }
    
    struct RequestData {
        let method: HTTPMethod
        let path: String
    }
    
    static let shared = API()
    lazy var BASE_URL = URL(string: "http://logan-backend.us-west-2.elasticbeanstalk.com")
    lazy var baseConfig: URLSessionConfiguration = makeBasicConfig()
    
    var authEstablished: Bool = false
    
    var unauthedSession: URLSession!
    var authedSession: URLSession?
    
    override init() {
        super.init()
        
        unauthedSession = URLSession(configuration: baseConfig)
    }
    
    private func makeBasicConfig() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = ["Client-Type": "ios",
                                        "Content-Type": "application/json"]
        return config
    }
    
    private func perror(_ request: RequestData, _ message: String) {
        print("Request error (\(request.method.rawValue) \(request.path)): \(message)")
    }
    
    private func httpTask(method: HTTPMethod, path: String, body: Data? = nil, ignoreAuth: Bool = false, _ completionHandler: @escaping (RequestData, Data?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        let requestData = RequestData(method: method, path: path)
        
        // Display error if the appropriate session is nil
        if ignoreAuth && unauthedSession == nil {
            perror(requestData, "No valid unauthed session exists")
            return nil
        } else if !ignoreAuth && authedSession == nil {
            perror(requestData, "No valid authed session exists")
            return nil
        }
        
        let session = ignoreAuth ? unauthedSession! : authedSession!
        
        // Add the path to the base URL
        guard let fullUrl = URL(string: path, relativeTo: BASE_URL) else {
            perror(requestData, "Invalid URL")
            return nil
        }
        
        var urlRequest = URLRequest(url: fullUrl)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        
        return session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if error != nil {
                return completionHandler(requestData, data, urlResponse, error)
            } else if let httpResponse: HTTPURLResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let message = data != nil ? String(data: data!, encoding: .utf8) ?? "Unknown error" : "Unknown error"
                return completionHandler(requestData, data, urlResponse, ResponseError(message))
            } else {
                return completionHandler(requestData, data, urlResponse, error)
            }
        }
    }
    
    private func basicGet<T>(endpoint: String, _ completion: @escaping (T?) -> Void) {
        guard let task = httpTask(method: .GET, path: endpoint, { (request, data, httpResponse, error) in
            if let error = error {
                self.perror(request, error.localizedDescription)
                return completion(nil)
            }
            
            guard let data = data else {
                self.perror(request, "No response data")
                return completion(nil)
            }
            
            if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? T {
                return completion(response)
            } else {
                self.perror(request, "Improper response format")
                return completion(nil)
            }
        }) else {
            return completion(nil)
        }
        
        task.resume()
    }
    
    func establishAuth(_ idToken: String, _ completion: @escaping (Bool, User?) -> Void) {
        guard let body = try? JSONSerialization.data(withJSONObject: ["idToken": idToken]) else {
            print("Error serializing JSON for auth handshake")
            return completion(false, nil)
        }
        
        guard let task = httpTask(method: .POST, path: "/auth", body: body, ignoreAuth: true, { (request, data, httpResponse, error) in
            if let error = error {
                self.perror(request, error.localizedDescription)
                return completion(false, nil)
            }
            
            guard let data = data else {
                self.perror(request, "Empty response")
                return completion(false, nil)
            }
            
            if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Blob, let bearer = response["bearer"] as? String {
                print("Fetched bearer. Auth established with backend")
                let authedConfig = self.makeBasicConfig()
                authedConfig.httpAdditionalHeaders!["Authorization"] = "Bearer \(bearer)"
                self.authedSession = URLSession(configuration: authedConfig)
                self.authEstablished = true
                
                if let userBlob = response["user"] as? Blob, let user = User(blob: userBlob) {
                    completion(true, user)
                } else {
                    completion(true, nil)
                }
            } else {
                print(String(data: data, encoding: .utf8) ?? "Unable to fetch bearer token. Reason unknown.")
                completion(false, nil)
            }
        }) else {
            return completion(false, nil)
        }
        
        print("Attempting to fetch bearer token")
        task.resume()
    }
    
    func createUser(name: String, email: String, _ completion: @escaping (Bool, User?) -> Void) {
        guard let body = try? JSONSerialization.data(withJSONObject: ["name": name, "email": email]) else {
            print("Error serializing JSON for new user")
            return completion(false, nil)
        }
        
        guard let task = httpTask(method: .POST, path: "/users", body: body, ignoreAuth: true, { (request, data, response, error) in
            if let error = error {
                self.perror(request, error.localizedDescription)
                return completion(false, nil)
            }
            
            guard let data = data else {
                self.perror(request, "Empty response")
                return completion(false, nil)
            }
            
            if let userBlob = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Blob, let user = User(blob: userBlob) {
                print("New user created")
                return completion(true, user)
            } else {
                self.perror(request, "Error creating new user: \(String(data: data, encoding: .utf8) ?? "Reason unknown")")
                return completion(false, nil)
            }
        }) else {
            return completion(false, nil)
        }
        
        task.resume()
    }
    
    func getSemesters(_ completion: @escaping ([Blob]?) -> Void) {
        basicGet(endpoint: "/semesters", completion)
    }
    
    func getCourses(_ completion: @escaping ([String: [Blob]]?) -> Void) {
        basicGet(endpoint: "/courses", completion)
    }
    
    func getSections(_ completion: @escaping ([String: [Blob]]?) -> Void) {
        basicGet(endpoint: "/sections", completion)
    }
    
    func getAssignments(_ completion: @escaping ([Blob]?) -> Void) {
        basicGet(endpoint: "/assignments", completion)
    }
    
    func getTasks(_ completion: @escaping ([Blob]?) -> Void) {
        basicGet(endpoint: "/tasks", completion)
    }
    
}
