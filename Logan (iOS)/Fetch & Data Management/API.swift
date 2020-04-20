//
//  API.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 4/15/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import Foundation

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
    
    func establishAuth(_ idToken: String, _ completion: @escaping (Bool, Bool) -> Void) {
        guard let body = try? JSONSerialization.data(withJSONObject: ["idToken": idToken]) else {
            completion(false, false)
            return
        }
        
        guard let task = httpTask(method: .POST, path: "/auth", body: body, ignoreAuth: true, { (request, data, httpResponse, error) in
            if let error = error {
                return self.perror(request, error.localizedDescription)
            }
            
            guard let data = data else {
                return self.perror(request, "Empty response")
            }
            
            if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any], let bearer = response["bearer"] as? String {
                print("Fetched bearer. Auth established with backend")
                let authedConfig = self.makeBasicConfig()
                authedConfig.httpAdditionalHeaders!["Authorization"] = "Bearer \(bearer)"
                self.authedSession = URLSession(configuration: authedConfig)
                self.authEstablished = true
                
                completion(true, (response["exists"] as? Bool) ?? false)
            } else {
                print(String(data: data, encoding: .utf8) ?? "Unable to fetch bearer token. Reason unknown.")
                completion(false, false)
            }
        }) else {
            return completion(false, false)
        }
        
        print("Attempting to fetch bearer token")
        task.resume()
    }
    
    func createUser(name: String, email: String, _ completion: @escaping (Bool) -> Void) {
        guard let body = try? JSONSerialization.data(withJSONObject: ["name": name, "email": email]) else {
            completion(false)
            return
        }
        
        guard let task = httpTask(method: .POST, path: "/users", body: body, ignoreAuth: true, { (request, data, response, error) in
            if let error = error {
                self.perror(request, error.localizedDescription)
                return completion(false)
            }
            
            guard let data = data else {
                self.perror(request, "Empty response")
                return completion(false)
            }
            
            if let _ = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
                print("New user created")
                return completion(true)
            } else {
                self.perror(request, "Error creating new user: \(String(data: data, encoding: .utf8) ?? "Reason unknown")")
                return completion(false)
            }
        }) else {
            return completion(false)
        }
        
        task.resume()
    }
    
    func getSemesters(_ completion: @escaping ([[String: Any]]?) -> Void) {
        guard let task = httpTask(method: .GET, path: "/semesters", { (request, data, httpResponse, error) in
            if let error = error {
                self.perror(request, error.localizedDescription)
                return completion(nil)
            }
            
            guard let data = data else {
                self.perror(request, "Empty response")
                return completion(nil)
            }
            
            if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]] {
                return completion(response)
            } else {
                self.perror(request, "Bad response format")
                return completion(nil)
            }
        }) else {
            return completion(nil)
        }
        
        task.resume()
    }
    
    func getCourses(_ completion: @escaping ([String: [[String: Any]]]?) -> Void) {
        guard let task = httpTask(method: .GET, path: "/courses", { (request, data, httpResponse, error) in
            if let error = error {
                self.perror(request, error.localizedDescription)
                return completion(nil)
            }
            
            guard let data = data else {
                self.perror(request, "Empty response")
                return completion(nil)
            }
            
            if let response = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: [[String: Any]]] {
                return completion(response)
            } else {
                self.perror(request, "Bad response format")
                return completion(nil)
            }
        }) else {
            return completion(nil)
        }
        
        task.resume()
    }
    
}
