//
//  MonumentNavigationCell.swift
//  Navmate
//
//  Created by Gautier Billard on 22/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import CoreLocation
protocol MonumentNavigationCellDelegate {
    func didPressSeeMoreButton(monument: Monument)
}
class MonumentNavigationCell: ResearchCell {

    private lazy var effectView: UIVisualEffectView = {
        let effect = UIVisualEffectView()
        effect.layer.cornerRadius = 8
        return effect
    }()
    private lazy var goButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = K.shared.blue
        button.setTitle("Voir", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = K.shared.cornerRadiusImageThumbNailCell
        button.addTarget(self, action: #selector(goButtonPressed(_:)), for: .touchUpInside)
        button.alpha = 0.0
        return button
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.0
        return label
    }()
        private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0.0
        return label
    }()
    
    var monument: Monument?
    var delegate: MonumentNavigationCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addEffectView()
        self.addGoButton()
        self.addNameLabel()
        self.addDistanceLabel()
        
    }
    func passDataToCell(title: String, subTitle: String, imageName: String, monument: Monument) {
        
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.thumbNail.image = UIImage(named: imageName)
        self.monument = monument
        
    }
    @objc private func goButtonPressed(_ sender:UIButton!) {
        
        if let monument = self.monument {
            self.isSelected = false
            delegate?.didPressSeeMoreButton(monument: monument)
        }
        
    }
    private func addDistanceLabel() {
        
        self.addSubview(distanceLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.bottomAnchor, constant: 10)])
        }
        addConstraints(fromView: distanceLabel, toView: nameLabel)
        
    }
    private func addNameLabel() {
        
        self.addSubview(nameLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 20),
                                         fromView.trailingAnchor.constraint(equalTo: self.goButton.leadingAnchor ,constant: -10),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10)])
        }
        addConstraints(fromView: nameLabel, toView: self)
        
    }
    private func addGoButton() {
        
        self.addSubview(goButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.widthAnchor.constraint(equalToConstant: 50),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -20),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 50)])
        }
        addConstraints(fromView: goButton, toView: self)
        
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
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func geoCodeMonument() {
        if let monument = self.monument {
            
            if let location = Locator.shared.getUserLocation() {
                
                let monumentPosition = CLLocation(latitude: monument.latitude, longitude: -monument.longitude)
                
                let distance = monumentPosition.distance(from: location)
                
                let distanceString = Int(distance/1000)
                
                self.distanceLabel.text = "\(distanceString) Km"
                
            }
            
            
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.nameLabel.text = self.titleLabel.text
        
        geoCodeMonument()
        
        if selected {
            UIView.animate(withDuration: 0.4) {
                self.effectView.effect = UIBlurEffect(style: .light)
                self.goButton.alpha = 1.0
                self.nameLabel.alpha = 1.0
                self.distanceLabel.alpha = 1.0
            }
        }else{
            UIView.animate(withDuration: 0.4) {
                self.effectView.effect = nil
                self.goButton.alpha = 0.0
                self.nameLabel.alpha = 0.0
                self.distanceLabel.alpha = 0.0
            }
        }
        
        
    }

}
