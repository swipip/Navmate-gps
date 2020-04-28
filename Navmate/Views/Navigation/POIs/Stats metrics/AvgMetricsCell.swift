//
//  AvgMetricsCell.swift
//  Navmate
//
//  Created by Gautier Billard on 22/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class AvgMetricsCell: UITableViewCell {

    private lazy var thumbNail: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage()
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    private lazy var metricName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize)
        label.textColor = K.shared.blueGrayFont
        label.text = "-"
        return label
    }()
    private lazy var metricValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize,weight: .bold)
        label.textColor = K.shared.blueGrayFont
        label.text = "-"
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.addImageView()
        self.addMetricName()
        self.addMetricValueLabel()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    enum CellType {
        case avgSpeed,maxSpeed,duration,distance
    }
    func passData(imageName: String, metricName: String, cellType: CellType) {
        
        self.metricName.text = metricName
        self.thumbNail.image = UIImage(named: imageName)
        
        switch cellType {
        case .maxSpeed:
            
            let speed = NSNotification.Name(K.shared.notificationSpeed)
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: speed, object: nil)
        case .avgSpeed:
            let avgSpeed = NSNotification.Name(K.shared.notificationAvgSpeed)
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: avgSpeed, object: nil)
        case .duration:
            self.metricValue.text = "00 min"
            let totalTime = NSNotification.Name(K.shared.notificationTotalTime)
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: totalTime, object: nil)
            
        case .distance:
            let distance = NSNotification.Name(K.shared.notificationTotalDistance)
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: distance, object: nil)
        }
        
    }
    @objc private func didReceiveNotification(_ notification: Notification) {
        
        if let speed = notification.userInfo?["speed"] as? Double {
            
            metricValue.text = "\(Int(speed * 3.6)) Kmh"
            
        }
        if let avgSpeed = notification.userInfo?["avgSpeed"] as? Double {
            
            self.metricValue.text = "\(Int(avgSpeed * 3.6)) Kmh"
            
        }
        if let totalTime = notification.userInfo?["totalTime"] as? Double {
            
            let timeString = Locator.shared.secondsToHoursMinutesSeconds(seconds: Int(totalTime))
            metricValue.text = timeString.timeString
            
            
        }
        if let distance = notification.userInfo?["totalDistance"] as? Double {
            
            if distance > 1000 {
                let total = distance / 1000
                let totalString = String(format: "%.1f", total)
                self.metricValue.text = "\(totalString) Km"
            }else{
                self.metricValue.text = "\(Int(distance)) m"
            }
            
        }
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours:Int,minutes: Int,seconds: Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    private func addMetricValueLabel() {
        
        self.addSubview(metricValue)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -20),
                                         fromView.centerYAnchor.constraint(equalTo: self.metricName.centerYAnchor ,constant: 0)])
        }
        addConstraints(fromView: metricValue, toView: self)
        
    }
    private func addMetricName() {
        
        self.addSubview(metricName)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 35),
                                         fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor ,constant: 0)])
        }
        addConstraints(fromView: metricName, toView: self.thumbNail)
        
    }
    private func addImageView() {
        
        self.addSubview(self.thumbNail)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 25),
                                         fromView.heightAnchor.constraint(equalToConstant: 50),
                                        fromView.widthAnchor.constraint(equalToConstant: 50),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor,constant: 0)])
        }
        addConstraints(fromView: self.thumbNail, toView: self)
        
    }

}
