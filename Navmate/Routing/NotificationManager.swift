//
//  NotificationManager.swift
//  Navmate
//
//  Created by Gautier Billard on 26/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import UIKit

class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    let center = UNUserNotificationCenter.current()
    
    private override init() {
        center.requestAuthorization(options: [.alert,.sound]) { (granted, error) in
            
        }
    }
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let request = UNNotificationRequest(identifier: "Direction", content: content, trigger: nil)
        
        center.add(request) { (error) in
            if let err = error {
                print("\(err)")
            }
        }
        
    }

    
}
