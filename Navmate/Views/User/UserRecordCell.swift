//
//  UserRecordCell.swift
//  Navmate
//
//  Created by Gautier Billard on 03/05/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class UserRecordCell: CommonPoisCell {
    
    private lazy var cardCover: UIImageView =  {
        let view = UIImageView()
        view.backgroundColor = K.shared.white
        view.layer.cornerRadius = K.shared.cornerRadiusCard
        view.clipsToBounds = true
        view.image = UIImage(named: "cardBack")
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ma liste de monuments à visiter"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addCard()
        cardBG.backgroundColor = K.shared.white
        
        addCardCover()
        addTitleLabel()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addTitleLabel() {
        
        self.addSubview(titleLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 15),
                                         fromView.widthAnchor.constraint(equalToConstant: 200),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -15)])
        }
        addConstraints(fromView: titleLabel, toView: cardBG)
        
        titleLabel.addParallaxToView()
        
    }
    private func addCardCover() {
        
        self.addSubview(cardCover)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: cardCover, toView: cardBG)
        
    }
    
}
extension UIView {
    func addParallaxToView() {
        let amount = 15
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        self.addMotionEffect(group)
    }
}
