//
//  NavigationCell.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class NavigationCell: UITableViewCell {

    private lazy var cardBG: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "lightBrown")
        view.layer.cornerRadius = 8
        return view
    }()
    private lazy var roadSignIV: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage(systemName: "arrow.turn.up.right")
        imageV.tintColor = .white
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    private var widthAnch: NSLayoutConstraint!
    private var heightAnch: NSLayoutConstraint!
    private lazy var nameIndicator: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "Avenue Lucien Guitry"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private lazy var subIndicator: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "90m"
        return label
    }()
    private var heightConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!
    
    private var distance = 0.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.addBG()
        self.addSign()
        self.addNameIndicator()
        self.addSubIndicator()
        
        
        let distance = Notification.Name(K.shared.notificationLocation)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDistanceUpdate(_:)), name: distance, object: nil)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func didReceiveDistanceUpdate(_ notification:Notification) {
        if self.isSelected {
            distance -= 3
            self.subIndicator.text = "\(distance) m"
        }
        
        
    }
    func updateIndications(main: String, sub: Double, type: Int, step: Step) {
        
        self.nameIndicator.text = main
        self.distance = sub
        self.subIndicator.text = "\(sub)m"
        
        switch type {
        case 0:
            self.roadSignIV.image = UIImage(named: "left")
        case 1:
            self.roadSignIV.image = UIImage(named: "right")
        case 2:
            self.roadSignIV.image = UIImage(named: "sharpLeft")
        case 3:
            self.roadSignIV.image = UIImage(named: "sharpRight")
        case 4:
            self.roadSignIV.image = UIImage(named: "slightLeft")
        case 5:
            self.roadSignIV.image = UIImage(named: "slightRight")
        case 6:
            self.roadSignIV.image = UIImage(named: "continue")
        case 7:
            switch step.exitNumber {
            case 1:
                self.roadSignIV.image = UIImage(named: "round1")
            case 2:
                self.roadSignIV.image = UIImage(named: "round2")
            case 3:
                self.roadSignIV.image = UIImage(named: "round3")
            default:
                self.roadSignIV.image = UIImage(named: "round3")
            }
        case 8:
            switch step.exitNumber {
            case 1:
                self.roadSignIV.image = UIImage(named: "round1")
            case 2:
                self.roadSignIV.image = UIImage(named: "round2")
            case 3:
                self.roadSignIV.image = UIImage(named: "round3")
            default:
                self.roadSignIV.image = UIImage(named: "round3")
            }
        case 9:
            self.roadSignIV.image = UIImage(named: "uTurn")
        case 10:
            self.roadSignIV.image = UIImage(named: "arrive")
            self.nameIndicator.text = "Vous êtes arrivé"
        case 11:
            self.roadSignIV.image = UIImage(named: "depart")
        case 12:
            self.roadSignIV.image = UIImage(named: "keepLeft")
        case 13:
            self.roadSignIV.image = UIImage(named: "keepRight")
        default:
            self.roadSignIV.image = UIImage(named: "")
        }
        
    }
    private func addSubIndicator(){
        self.addSubview(subIndicator)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
                                        fromView.bottomAnchor.constraint(equalTo: roadSignIV.bottomAnchor, constant: 0)])
        }
        addConstraints(fromView: subIndicator, toView: nameIndicator)
    }
    private func addNameIndicator(){
        self.addSubview(nameIndicator)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 20),
                                        fromView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0)])
        }
        addConstraints(fromView: nameIndicator, toView: roadSignIV)
    }
    private func addSign() {
        self.addSubview(roadSignIV)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 25),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0)])
            
            heightAnch = NSLayoutConstraint(item: roadSignIV, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
            widthAnch = NSLayoutConstraint(item: roadSignIV, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50)
            
            self.addConstraints([heightAnch,widthAnch])
            
        }
        addConstraints(fromView: roadSignIV, toView: self.cardBG)
    }
    private func addBG() {
        
        self.addSubview(cardBG)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0)])
            
            let cellWidth = self.frame.size.width
            
            widthConstraint = NSLayoutConstraint(item: cardBG, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: cellWidth)
            heightConstraint = NSLayoutConstraint(item: cardBG, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 60)
            
            self.addConstraints([widthConstraint,heightConstraint])
            
        }
        addConstraints(fromView: cardBG, toView: self)
        
        
    }
    func magnify(on:Bool) {
        
        let cellWidth = self.frame.size.width
        let width:CGFloat = on ? cellWidth : cellWidth * 0.9
        let height:CGFloat = on ? 92 : 85
        let color:UIColor = on ? UIColor(named: "blueGray")! : UIColor(named: "lightBrown")!
//        let scale:CGFloat = on ? 1.1 : 1.0
        let mainFont:UIFont = on ? UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.bold) : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)
        let subFont:UIFont = on ? UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.bold) : UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        let cornerRadius:CGFloat = on ? 0 : 8
        let thumbSize:CGFloat = on ? 60 : 50
        
        UIView.animate(withDuration: 0.3, animations: {
            self.heightConstraint.constant = height
            self.widthConstraint.constant = width
            self.cardBG.backgroundColor = color
            self.cardBG.layer.cornerRadius = cornerRadius
            self.widthAnch.constant = thumbSize
            self.heightAnch.constant = thumbSize
            self.nameIndicator.font = mainFont
            self.subIndicator.font = subFont
            self.layoutIfNeeded()
        }) { (_) in
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.magnify(on: selected)
    }

}
