//
//  SignInManager.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 4/21/20.
//  Copyright © 2020 Lucas Popp. All rights reserved.
//

import Foundation
import GoogleSignIn

class SignInManager: NSObject, GIDSignInDelegate, DataManagerListener {
    
    static let shared = SignInManager()
    
    var currentUser: GIDGoogleUser?
    var transmitted: Bool = false
    
    // MARK: GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("User has not signed in before, or has since signed out")
            } else {
                print(error.localizedDescription)
            }
            
            return
        }
        
        currentUser = user
        
        guard let idToken = user.authentication.idToken else {
            return print("No idToken found")
        }
        
        API.shared.establishAuth(idToken) { (success, userExists) in
            if success && userExists {
                print(API.shared.currentUid!)
            } else {
                print("Failed to establish auth")
            }
        }
    }
    
    // MARK: DataManagerListener
    func handleLoadingEvent(_ eventType: DataManager.LoadingEventType, error: Error?) {
        if eventType == .end {
            if !transmitted {
                API.shared.transmitData()
            }
            
            transmitted = true
        }
    }
    
}
