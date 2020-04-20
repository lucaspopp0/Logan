//
//  SignInManager.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 4/16/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import Foundation
import GoogleSignIn

@objc protocol SignInListener: NSObjectProtocol {
    
    @objc optional func signedIn()
    @objc optional func signedOut()
    
}

// TODO: Eventually deprecate this and combine with DataManager
class SignInManager: NSObject, GIDSignInDelegate {
    
    static let shared = SignInManager()
    
    var currentUser: GIDGoogleUser?
    private var listeners: [SignInListener] = []
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            
            return
        }
        
        currentUser = user
        
        DispatchQueue.main.async {
            for listener in self.listeners {
                listener.signedIn?()
            }
        }
        
        guard let idToken = user.authentication.idToken else {
            print("Unable to access user idToken")
            return
        }
        
        API.shared.establishAuth(idToken) { (success, userExists) in
            if success {
                if userExists {
                    // Fetch data
                    
                    API.shared.getSemesters { (semesters) in
                        guard let semesters = semesters else {
                            print("Empty data")
                            return
                        }
                        
                        print(semesters)
                    }
                } else {
                    API.shared.createUser(name: user.profile.name, email: user.profile.email) { (success) in
                        if success {
                            print("New user successfully created")
                        } else {
                            print("Failed to create new user")
                        }
                    }
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        currentUser = nil
        
        DispatchQueue.main.async {
            for listener in self.listeners {
                listener.signedOut?()
            }
        }
    }
    
    func addListener(_ listener: SignInListener) {
        for existingListener in listeners {
            if existingListener.isEqual(listener) {
                return
            }
        }
        
        listeners.append(listener)
    }
    
    func removeListener(_ listener: SignInListener) {
        for i in 0 ..< listeners.count {
            if listeners[i].isEqual(listener) {
                listeners.remove(at: i)
                return
            }
        }
    }
    
}
