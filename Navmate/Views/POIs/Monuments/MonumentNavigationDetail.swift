//
//  MonumentNavigationDetail.swift
//  Navmate
//
//  Created by Gautier Billard on 22/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import CoreLocation

class MonumentNavigationDetail: UIView {

    private lazy var effectView: UIVisualEffectView = {
        let effect = UIVisualEffectView()
        effect.layer.cornerRadius = K.shared.cornerRadiusCard
        effect.clipsToBounds = true
        return effect
    }()
    private lazy var imageThumb: UIImageView = {
        let image = UIImageView()
        image.image = UIImage()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 8
        image.layer.masksToBounds = true
        image.alpha = 0
        return image
    }()
    private lazy var goButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = K.shared.cornerRadiusImageThumbNailCell
        button.setTitle("Go!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = K.shared.blue
        button.addTarget(self, action: #selector(goButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = K.shared.cornerRadiusImageThumbNailCell
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemRed
        button.addTarget(self, action: #selector(dismissPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var summaryViewBG: UIVisualEffectView = {
        let effect = UIVisualEffectView()
        effect.clipsToBounds = true
        effect.alpha = 0
        return effect
    }()
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize, weight: .bold)
        label.textColor = .white
        label.alpha = 0
        label.numberOfLines = 0
        return label
    }()
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize, weight: .regular)
        label.textColor = .white
        label.alpha = 0
        return label
    }()
    
    let startReroutingNotification = Notification.Name(K.shared.notificationStartRerouting)
    
    convenience init(frame: CGRect, monument: Monument) {
        self.init(frame: frame)
        
        let location = CLLocation(latitude: monument.latitude, longitude: -monument.longitude)
        
        WikiManagerCoord.shared.requestInfo(location: location)
        
    }
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addEffectView()
        self.animateDisplay()
        self.addImage()
        self.addGoButton()
        self.addDismissButton()
        self.addObservers()
        
    }
    @objc private func goButtonPressed(_ sender:UIButton!) {
        
        dismissDetailView()
        
        NotificationCenter.default.post(name: startReroutingNotification, object: nil, userInfo: nil)
        
    }
    fileprivate func dismissDetailView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.effectView.effect = nil
            self.imageThumb.alpha = 0
            self.goButton.alpha = 0
            self.dismissButton.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    @objc private func dismissPressed(_ sender:UIButton!) {
        
        dismissDetailView()
        
    }
    private func addDistanceLabel() {
        
        self.addSubview(distanceLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -5),
                                        fromView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5)])
        }
        addConstraints(fromView: distanceLabel, toView: summaryViewBG)
        
    }
    private func addTimeLabel() {
        
        self.addSubview(timeLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -5),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10)])
        }
        addConstraints(fromView: timeLabel, toView: summaryViewBG)
        
    }
    private func addSummaryView() {
        
        self.imageThumb.addSubview(summaryViewBG)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.widthAnchor.constraint(equalToConstant: 120),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: summaryViewBG, toView: imageThumb)
        
    }
    private func addDismissButton() {
        
        self.addSubview(dismissButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
            
            fromView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: self.imageThumb.trailingAnchor, constant: 10),
                                         fromView.widthAnchor.constraint(equalToConstant: 60),
                                         fromView.heightAnchor.constraint(equalToConstant: 60),
                                         fromView.bottomAnchor.constraint(equalTo: goButton.topAnchor,constant: -10)])
        }
        addConstraints(fromView: dismissButton, toView: self.effectView)
        
    }
    private func addGoButton() {
        
        self.addSubview(goButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: self.imageThumb.trailingAnchor, constant: 10),
                                         fromView.widthAnchor.constraint(equalToConstant: 60),
                                        fromView.heightAnchor.constraint(equalToConstant: 60),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: goButton, toView: self.effectView)
        
    }
    private func addObservers() {
        
        let notificationNewRoute = Notification.Name(K.shared.notificationRoute)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveRouteUpdate(_:)), name: notificationNewRoute, object: nil)
        let notificationMonuments = Notification.Name(K.shared.notificationWikiPedia)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMonument(_:)), name: notificationMonuments, object: nil)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func didReceiveMonument(_ notification:Notification) {
        
        if let monument = notification.userInfo?["wikipedia"] as? WikiObject {
            self.imageThumb.image = monument.image
            self.imageThumb.animateAlpha()
        }
        
    }
    @objc private func didReceiveRouteUpdate(_ notification:Notification) {
        
        if let route = notification.userInfo?["routeNew"] as? Route {
            
            self.addSummaryView()
            self.addTimeLabel()
            self.addDistanceLabel()

            let time = Locator.shared.secondsToHoursMinutesSeconds(seconds: Int(route.summary.duration)).timeString
            timeLabel.text = time
            distanceLabel.text = "\(Int(route.summary.distance) / 1000) Km"

            summaryViewBG.alpha = 1.0

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.summaryViewBG.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
                self.timeLabel.alpha = 1.0
                self.distanceLabel.alpha = 1.0
            }) { (_) in

            }
            
        }
        
    }
    private func addImage() {
        
        self.addSubview(imageThumb)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -80),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: imageThumb, toView: self)
        
    }
    private func animateDisplay() {
        
        UIView.animate(withDuration: 0.3) {
            self.effectView.effect = UIBlurEffect(style: .light)
        }
        
    }
    private func addEffectView() {
        
        self.addSubview(effectView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: effectView, toView: self)
        
    }
    

}
