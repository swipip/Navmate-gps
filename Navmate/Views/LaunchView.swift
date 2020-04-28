//
//  LaunchView.swift
//  Navmate
//
//  Created by Gautier Billard on 27/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class LaunchView: UIView {

    private lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = K.shared.blue
        return view
    }()
    private lazy var brandLabel: UILabel = {
        let label = UILabel()
        label.text = "Navmate"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 50)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        addColorView()
        
        addBrandLabel()
        
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0.0
            }) { (_) in
                self.removeFromSuperview()
            }
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func addBrandLabel() {
        self.addSubview(brandLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
            
            fromView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([fromView.centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: 0),
                                         fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0)])
        }
        addConstraints(fromView: brandLabel, toView: self)
    }
    
    fileprivate func addColorView() {
        self.addSubview(colorView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
            
            fromView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                         fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                         fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: colorView, toView: self)
    }
    

    
    
}
