//
//  researchCell.swift
//  Navmate
//
//  Created by Gautier Billard on 17/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import MapKit

class ResearchCell: UITableViewCell {
    
    var titleLabel = UILabel()
    var subTitleLabel = UILabel()
    var searchResult = MKLocalSearchCompletion()
    lazy var thumbNail: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.layer.cornerRadius = K.shared.cornerRadiusImageThumbNailCell
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        
        self.selectionStyle = .none
        
        self.backgroundColor = K.shared.white
        
        addThumbNail()
        addTitleLabel()
        addsubTitleLabel()
        
    }
    func passDataToCell(title: String ,subTitle: String ,imageName: String, searchResult: MKLocalSearchCompletion? = nil) {
        self.thumbNail.image = UIImage(named: imageName)
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.searchResult = searchResult ?? MKLocalSearchCompletion()
    }
    func addThumbNail() {
        
        self.addSubview(thumbNail)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 20),
                                        fromView.widthAnchor.constraint(equalToConstant: 50),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10),
                                        fromView.heightAnchor.constraint(equalToConstant: 50)])
        }
        addConstraints(fromView: thumbNail, toView: self)
        
    }
    func addTitleLabel() {
        
        titleLabel.font = UIFont.systemFont(ofSize: K.shared.cellTitleFontSize)
        
        self.addSubview(titleLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: thumbNail.trailingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -20),
                                        fromView.topAnchor.constraint(equalTo: thumbNail.topAnchor, constant: 3)])
        }
        addConstraints(fromView: titleLabel, toView: self)
        
    }
    func addsubTitleLabel() {
        
        subTitleLabel.font = UIFont.systemFont(ofSize: 12)
        
        self.addSubview(subTitleLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: thumbNail.trailingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -20),
                                        fromView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)])
        }
        addConstraints(fromView: subTitleLabel, toView: self)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
