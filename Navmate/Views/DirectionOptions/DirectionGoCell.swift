//
//  DirectionGoCell.swift
//  Navmate
//
//  Created by Gautier Billard on 18/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import CoreLocation
import Lottie

protocol DirectionGoCellDelegate {
    func didDismissNavigation()
    func didEngagedNavigation()
}

class DirectionGoCell: UICollectionViewCell {
    
    
    private lazy var directionCard: UIVisualEffectView = {
        var blur = UIBlurEffect()
        if traitCollection.userInterfaceStyle == .light {
            blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        }else{
            blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
        let view = UIVisualEffectView(effect: blur)
        view.layer.cornerRadius = K.shared.cornerRadiusCard
        view.clipsToBounds = true
        return view
    }()
    private lazy var goButton: UIButton = {
        let button = UIButton()
        button.setTitle("C'est Parti !", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = K.shared.blue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(goButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pas Aujourd'hui", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = K.shared.orange
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(dismissButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "- Km"
        label.font = UIFont.systemFont(ofSize: K.shared.cardContentFontSize)
        return label
    }()
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "- min"
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize, weight: .medium)
        return label
    }()
    private lazy var summaryCard: UIView = {
        let view = UIView()
        view.backgroundColor = K.shared.white
        view.alpha = 0.3
        view.layer.cornerRadius = 12
        return view
    }()
    private lazy var directionTitle: UILabel = {
        let label = UILabel()
        label.text = "Itinéraire vers "
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize, weight: .medium)
        return label
    }()
    private lazy var directionName: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize, weight: .medium)
        return label
    }()
    private var animation = AnimationView()
    //MARK: - Data
    var delegate: DirectionGoCellDelegate?
    private var summary: Summary?
    
    //MARK: - View loading
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        addDirectionCard()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        addGoButton()
        addDismissButton()
        addCardTitle()
        addSummaryCard()
        addTimeLabel()
        addDistanceLabel()
        addDirectionName()
        addWeatherView()
        addObservers()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - UI Construction
    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours:Int,minutes: Int,seconds: Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    private func addObservers() {
        
        let weather = Notification.Name(K.shared.notificationWeather)
        NotificationCenter.default.addObserver(self, selector: #selector(didFindWeather), name: weather, object: nil)
        
    }
    @objc private func didFindWeather(_ notification:Notification) {
        if let weather = notification.userInfo?["weather"] as? String {
            
            animation.animation = Animation.named(weather)
            animation.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { (_) in

            }
        }
    }
    func updateValues(summary: Summary, destination: CLLocation) {
        
        self.summary = summary
        
        let distance = String(format: "%.2f",summary.distance / 1000)
        let time = secondsToHoursMinutesSeconds(seconds: Int(summary.duration))
        
        WeatherManager.shared.fetchWeather(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude)
        
        self.distanceLabel.text = "\(distance) Km"
        self.timeLabel.text = "\(time.hours)h\(time.minutes) min"
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(destination) { (placemarks, error) in
            if let err = error {
                print(err)
                return
            }else {
                if let placemark = placemarks?.first {
                    let destinationName = placemark.locality
                    self.directionName.text = destinationName ?? "no destination found"
                }
            }
        }
        
    }
    private func addWeatherView() {
        
        self.addSubview(animation)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.widthAnchor.constraint(equalToConstant: 100),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -15),
                                        fromView.topAnchor.constraint(equalTo: directionTitle.bottomAnchor, constant: 5),
                                        fromView.bottomAnchor.constraint(equalTo: dismissButton.topAnchor,constant: -5)])
        }
        addConstraints(fromView: animation, toView: directionCard)

    }
    private func addDirectionName() {
        self.addSubview(directionName)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: self.summaryCard.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0)])
        }
        addConstraints(fromView: directionName, toView: directionTitle)
    }
    private func addCardTitle() {
        self.addSubview(directionTitle)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 12),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 5)])
        }
        addConstraints(fromView: directionTitle, toView: directionCard)
    }
    private func addSummaryCard() {
        self.addSubview(summaryCard)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.bottomAnchor.constraint(equalTo: goButton.topAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: directionTitle.bottomAnchor,constant: 10)])
        }
        addConstraints(fromView: summaryCard, toView: directionCard)
    }
    
    private func addTimeLabel() {
        
        self.addSubview(timeLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
            
            fromView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 4),
                                         fromView.topAnchor.constraint(equalTo: toView.topAnchor,constant: 10)])
            
        }
        addConstraints(fromView: timeLabel, toView: self.summaryCard)
        
    }
    private func addDistanceLabel() {
        
        self.addSubview(distanceLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
            
            fromView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 4),
                                         fromView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor,constant: 15)])
        }
        addConstraints(fromView: distanceLabel, toView: self.summaryCard)
        
    }
    @objc private func dismissButtonPressed(_ sender:UIButton!) {
        delegate?.didDismissNavigation()
    }
    @objc private func goButtonPressed(_ sender:UIButton!) {
        
        delegate?.didEngagedNavigation()
        
    }
    private func addDismissButton() {
        self.addSubview(dismissButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
              
            let width = (directionCard.frame.size.width - CGFloat(10 * 3)) / 2
            
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.widthAnchor.constraint(equalToConstant: width),
                                        fromView.heightAnchor.constraint(equalToConstant: 50),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: dismissButton, toView: self.directionCard)
    }
    private func addGoButton() {

        self.addSubview(goButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
              
            let width:CGFloat = (directionCard.frame.size.width - CGFloat(10 * 3)) / 2
            
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.widthAnchor.constraint(equalToConstant: width),
                                        fromView.heightAnchor.constraint(equalToConstant: 50),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: goButton, toView: self.directionCard)
        
    }
    private func addDirectionCard() {
        
        self.addSubview(directionCard)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: directionCard, toView: self)
        
    }
    
}
