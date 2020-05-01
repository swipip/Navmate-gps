//
//  CommonPoisCell.swift
//  Navmate
//
//  Created by Gautier Billard on 21/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class CommonPoisCell: UICollectionViewCell {
    
    lazy var cardBG: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addShadow(radius: 5, opacity: 0.5, color: K.shared.shadow!)
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = K.shared.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCard() {
        self.addSubview(cardBG)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 20),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -20),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: cardBG, toView: self)
    }
    
}
