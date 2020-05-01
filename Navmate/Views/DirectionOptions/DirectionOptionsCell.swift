//
//  DirectionOptionsCell.swift
//  Navmate
//
//  Created by Gautier Billard on 18/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
protocol DirectionOptionsCellDelegate {
    func didChooseOptions(mode: String,preference: String, avoid: [String])
}
class DirectionOptionsCell: UICollectionViewCell {
    
    private lazy var directionCard: UIVisualEffectView = {
        var blur = UIBlurEffect()
        if traitCollection.userInterfaceStyle == .light {
            blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        }else{
            blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
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
        switcher.addTarget(self, action: #selector(switcherChangedval(_:)), for: .valueChanged)
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
        switcher.addTarget(self, action: #selector(switcherChangedval(_:)), for: .valueChanged)
        return switcher
    }()
    private lazy var modeSegment: UISegmentedControl = {
        let items = ["walk","drive","cycle"]
        let images = [UIImage(named: "walk"),UIImage(named: "car"),UIImage(named: "bike")]
        let segment = UISegmentedControl(items: items)
        segment.setImage(images[0], forSegmentAt: 0)
        segment.setImage(images[1], forSegmentAt: 1)
        segment.setImage(images[2], forSegmentAt: 2)
        segment.selectedSegmentIndex = 1
        segment.addTarget(self, action: #selector(segmentedControlChangedValue(_:)), for: .valueChanged)
        return segment
    }()
    
    //data
    var delegate: DirectionOptionsCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addDirectionCard()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addCardTitle()
        self.addSegment()
        self.addModeSegment()
        self.addAvoidTollSwitch()
        self.addAvoidToll()
        self.addAvoidHWSwitch()
        self.addAvoidHW()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    @objc private func switcherChangedval(_ sender:UISwitch) {
     
        updateTripOptions()
        
    }
    private func addModeSegment() {
        
        self.addSubview(modeSegment)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.bottomAnchor, constant: 10),
                                        fromView.heightAnchor.constraint(equalToConstant: 40)])
        }
        addConstraints(fromView: modeSegment, toView: segment)
    }
    private func updateTripOptions() {
        let preferenceIndex = segment.selectedSegmentIndex
        var preference = ""
        switch preferenceIndex {
        case 0:
            preference = "shortest"
        case 1:
            preference = "fastest"
        case 2:
            preference = "recommended"
        default:
            break
        }
        let modeIndex = modeSegment.selectedSegmentIndex
        var mode = ""
        switch modeIndex {
        case 0:
            mode = "foot-walking"
        case 1:
            mode = "driving-car"
        case 2:
            mode = "cycling-road"
        default:
            break
        }
        
        var avoid = [String]()
        
        if avoidHighWaysSwitch.isOn {avoid.append("highways")}
        if avoidTollSwitch.isOn {avoid.append("tollways")}
        
        delegate?.didChooseOptions(mode: mode,preference: preference, avoid: avoid)
    }
    @objc private func updateButtonPressed(_ sender:UIButton!) {
        
        updateTripOptions()
        
    }
    private func addAvoidTollSwitch() {
        self.addSubview(avoidTollSwitch)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.widthAnchor.constraint(equalToConstant: 60),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: modeSegment.bottomAnchor, constant: 10),
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
                                        fromView.topAnchor.constraint(equalTo: avoidTollSwitch.bottomAnchor, constant: 10),
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
        
        if sender == modeSegment {
            if sender.selectedSegmentIndex == 0 || sender.selectedSegmentIndex == 2 {
                avoidTollSwitch.isEnabled = false
                avoidHighWaysSwitch.isEnabled = false
            }else{
                avoidTollSwitch.isEnabled = true
                avoidHighWaysSwitch.isEnabled = true
            }
        }
        
        updateTripOptions()
        
        
        
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
