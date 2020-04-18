//
//  DirectionOptionsCell.swift
//  Navmate
//
//  Created by Gautier Billard on 18/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
protocol DirectionOptionsCellDelegate {
    
}
class DirectionOptionsCell: UICollectionViewCell {
    
    private lazy var directionCard: UIVisualEffectView = {
        
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let view = UIVisualEffectView(effect: blur)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    private lazy var cardTitle: UILabel = {
        let label = UILabel()
        label.text = "Options d'itinéraire"
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    private lazy var segment: UISegmentedControl = {
        let items = ["Plus court","Plus rapide","Recommandé"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentedControlChangedValue(_:)), for: .valueChanged)
        return segment
    }()
    private lazy var avoidHighways: UILabel = {
        let label = UILabel()
        label.text = "Eviter les autoroutes"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    private lazy var avoidHighWaysSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = true
        return switcher
    }()
    private lazy var avoidToll: UILabel = {
        let label = UILabel()
        label.text = "Eviter les péages"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    private lazy var avoidTollSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.isOn = true
        return switcher
    }()
    private lazy var updateButton: UIButton = {
        let button = UIButton()
        button.setTitle("Modifier", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(updateButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addDirectionCard()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addCardTitle()
        self.addSegment()
        self.addAvoidTollSwitch()
        self.addAvoidToll()
        self.addAvoidHWSwitch()
        self.addAvoidHW()
        self.addButton()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    private func addButton() {
        self.addSubview(updateButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.heightAnchor.constraint(equalToConstant: 50),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: updateButton, toView: self.directionCard)
    }
    @objc private func updateButtonPressed(_ sender:UIButton!) {
        
        
        
    }
    private func addAvoidTollSwitch() {
        self.addSubview(avoidTollSwitch)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.widthAnchor.constraint(equalToConstant: 60),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 5),
                                        fromView.heightAnchor.constraint(equalToConstant: 30)])
        }
        addConstraints(fromView: avoidTollSwitch, toView: self.directionCard)
    }
    private func addAvoidToll() {
        self.addSubview(avoidToll)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.centerYAnchor.constraint(equalTo: avoidTollSwitch.centerYAnchor, constant: 0)])
        }
        addConstraints(fromView: avoidToll, toView: directionCard)
    }
    private func addAvoidHWSwitch() {
        self.addSubview(avoidHighWaysSwitch)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.widthAnchor.constraint(equalToConstant: 60),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: avoidTollSwitch.bottomAnchor, constant: 5),
                                        fromView.heightAnchor.constraint(equalToConstant: 30)])
        }
        addConstraints(fromView: avoidHighWaysSwitch, toView: self.directionCard)
    }
    private func addAvoidHW() {
        self.addSubview(avoidHighways)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.centerYAnchor.constraint(equalTo: avoidHighWaysSwitch.centerYAnchor, constant: 0)])
        }
        addConstraints(fromView: avoidHighways, toView: avoidToll)
    }
    private func addSegment() {
        
        self.addSubview(segment)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: 10),
                                        fromView.heightAnchor.constraint(equalToConstant: 40)])
        }
        addConstraints(fromView: segment, toView: directionCard)
        
    }
    @objc private func segmentedControlChangedValue(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        default:
            break
        }
        
    }
    private func addCardTitle() {
        self.addSubview(cardTitle)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 12),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 5)])
        }
        addConstraints(fromView: cardTitle, toView: directionCard)
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
