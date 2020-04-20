//
//  NavigationMetricsCell.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class NavigationMetricsCell: UICollectionViewCell {
    
    private lazy var cardBG: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addShadow(radius: 5, opacity: 0.5, color: .gray)
        view.layer.cornerRadius = 8
        return view
    }()
    private lazy var metricIV: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage()
        imageV.tintColor = UIColor(named: "accent2")
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    private lazy var metricValue: UILabel = {
        let label = UILabel()
        label.text = "75 Kmh"
        label.font = UIFont.systemFont(ofSize: 27, weight: .medium)
        label.textColor = UIColor(named: "brown")
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addCard()
        self.addMetricImage()
        self.addLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateMetrics(imageName: String,value: String) {
        
        self.metricValue.text = value
        self.metricIV.image = UIImage(named: imageName)
        
    }
    private func addLabel() {
        self.addSubview(metricValue)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -20),
                                        fromView.leadingAnchor.constraint(equalTo: metricIV.trailingAnchor, constant: 10),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0)])
        }
        addConstraints(fromView: metricValue, toView: self.cardBG)
    }
    private func addMetricImage() {
        
        self.addSubview(metricIV)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.widthAnchor.constraint(equalToConstant: 55),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 55)])
        }
        addConstraints(fromView: metricIV, toView: self.cardBG)
        
    }
    private func addCard() {
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
