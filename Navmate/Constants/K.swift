//
//  K.swift
//  Navmate
//
//  Created by Gautier Billard on 19/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class K {
    
    static let shared = K()
    
    private init() {
        
    }
    //fonts
    let cardTitleFontSize:CGFloat = 20
    let cardContentFontSize:CGFloat = 15
    let cellTitleFontSize:CGFloat = 16
    let cellSubTitleFontSize:CGFloat = 12
    //UI
    let cornerRadiusImageThumbNailCell:CGFloat = 12
    let cornerRadiusCard:CGFloat = 12
    //colors
    let blue = UIColor(named: "blue")
    let brown = UIColor(named: "brown")
    let orange = UIColor(named: "orange")
    let lightBrown = UIColor(named: "lightBrown")
    let bluegray = UIColor(named: "blueGray")
    let blueGrayFont = UIColor(named: "blueGrayFont")
    let white = UIColor(named: "white")
    
    // Notification Keys
    let notificationSpeed = "speed"
    let notificationLocation = "location"
    let notificationHeading = "heading"
    let notificationRoute = "route"
    let notificationNewStep = "newStep"
    let notificationMonuments = "monument"
    let notificationDurationTracking = "durationTracking"
    let notificationDistance = "distance"
    let notificationTotalDistance = "totalDistance"
    let notificationWikiPedia = "Wikipedia"
    let notificationRerouting = "reRouting"
    let notificationStartRerouting = "startRerouting"
    let notificationAvgSpeed = "avgSpeed"
    let notificationTotalTime = "totalTime"
    let notificationWeather = "weather"
    
}
