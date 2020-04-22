//
//  MonumentSearchDetailCell.swift
//  Navmate
//
//  Created by Gautier Billard on 19/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class MonumentSearchDetailCell: UICollectionViewCell {
    
    private lazy var cardBG: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.addShadow(radius: 5, opacity: 0.3, color: .gray)
        return view
    }()
    private lazy var imageView: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage(named: "historic")
        imageV.layer.cornerRadius = K.shared.cornerRadiusImageThumbNailCell
        imageV.clipsToBounds = true
        return imageV
    }()
    private lazy var title: UILabel = {
        let label = UILabel()
        label.text = "Title placeholder"
        label.font = UIFont.systemFont(ofSize: K.shared.cellTitleFontSize)
        return label
    }()
    private lazy var monumentDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: K.shared.cellSubTitleFontSize)
        return label
    }()
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: K.shared.cellSubTitleFontSize)
        label.numberOfLines = 0
        return label
    }()
    //Data
    
    var monument: Monument?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addCardBG()
        self.addImage()
        self.addTitle()
        self.addDescription()
        self.addAddressLabel()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(monument: Monument) {
        
        self.title.text = monument.name
        self.monumentDescription.text = "Monument \(monument.protection.lowercased())"
        self.monument = monument
        if monument.address != "0" {
            self.addressLabel.text = "\(monument.town), \(monument.address)"
        }else {
            self.addressLabel.text = "\(monument.town)"
        }
        let name = monument.name
        
        if name.contains("Eglise") || name.contains("Croix") || name.contains("Chapelle") {
            
            self.imageView.image = UIImage(named: "church")
            
        }else if name.contains("Phare") {
            imageView.image = UIImage(named: "lighthouse")
        }else if name.contains("Château") || name.contains("Remparts")  {
            imageView.image = UIImage(named: "castel")
        }else if name.contains("Mosqué") {
            imageView.image = UIImage(named: "mosque")
        }else{
            imageView.image = UIImage(named: "historic")
        }
        
    }
    private func addAddressLabel() {
        
        self.addSubview(addressLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.widthAnchor.constraint(equalToConstant: 250),
                                        fromView.topAnchor.constraint(equalTo: toView.bottomAnchor, constant: 3)])
        }
        addConstraints(fromView: addressLabel, toView: self.monumentDescription)
        
    }
    private func addDescription() {
        
        self.addSubview(monumentDescription)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.bottomAnchor, constant: 3)])
        }
        addConstraints(fromView: monumentDescription, toView: self.title)
        
    }
    private func addTitle() {
        
        self.addSubview(title)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: self.cardBG.trailingAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0)])
        }
        addConstraints(fromView: title, toView: self.imageView)
        
    }
    private func addImage() {
        
        self.addSubview(imageView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.heightAnchor.constraint(equalToConstant: 60),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10),
                                        fromView.widthAnchor.constraint(equalToConstant: 60)])
        }
        addConstraints(fromView: imageView, toView: cardBG)
        
    }
    private func addCardBG() {
        
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

