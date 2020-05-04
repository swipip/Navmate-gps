//
//  AuthManager.swift
//  Navmate
//
//  Created by Gautier Billard on 03/05/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import Firebase

class AuthManager: NSObject {
    
    static let shared = AuthManager()
    
    private override init() {
        
    }
    func logOut(completion: () -> Void) {
        userDefaults.set(false, forKey: K.shared.userLogedin)
        completion()
    }
    func checkIfUserExist(email: String) {
        
    }
    func authenticate(with email: String, and passWord: String, completion: @escaping (Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: passWord) { (result, error) in
            if let err = error {
                if AuthErrorCode(rawValue: err._code) == .userNotFound {
                    self.createUser(with: email, and: passWord) {
                        completion(nil)
                    }
                }else if AuthErrorCode(rawValue: err._code) == AuthErrorCode.wrongPassword {
                    completion(err)
                }
            }else{
                if let result = result {
                    
                    print(result)
                    completion(nil)
                }
            }
        }
        
    }
    private func createUser(with email: String ,and passWord: String, completion: @escaping () -> Void) {
        Auth.auth().createUser(withEmail: email, password: passWord) { (result, error) in
            if let err = error {
                print(err)
            }else{
                if let result = result {
                    print(result)
                    completion()
                }
            }
        }
    }
    
}
