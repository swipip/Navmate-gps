//
//  userSettingsCell.swift
//  Navmate
//
//  Created by Gautier Billard on 03/05/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
protocol UserSettingsCellDelegate: class {
    func didConfirm()
}
class UserSettingsCell: UITableViewCell {
    
    private lazy var imageBG: UIView = {
        let view = UIView()
        view.backgroundColor = K.shared.white
        view.addShadow(radius: 5, opacity: 0.3, color: K.shared.shadow!)
        view.layer.cornerRadius = K.shared.cornerRadiusImageThumbNailCell
        return view
    }()
    private lazy var confirmationButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.alpha = 0.0
        button.layer.cornerRadius = K.shared.cornerRadiusCard
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.setTitle("Confirmer", for: .normal)
        button.addShadow(radius: 5, opacity: 0.3, color: K.shared.shadow!)
        button.addTarget(self, action: #selector(confimationPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var imageThumb: UIImageView = {
        let view = UIImageView()
        view.image = UIImage()
        view.contentMode = .scaleAspectFit
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private var confirmationDisplaying = false
    
    weak var delegate: UserSettingsCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        addImageBG()
        addThumbNail()
        addTitle()
        addButton()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func confimationPressed(_ sender:UIButton!) {
        
        delegate?.didConfirm()
        
        self.confirmationButton.alpha = 0.0
        self.titleLabel.alpha = 1.0
        
    }
    func updateData(imageName: String, title: String) {
        imageThumb.image = UIImage(named: imageName)
        titleLabel.text = title
    }
    private func addButton() {
        
        self.addSubview(confirmationButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.widthAnchor.constraint(equalToConstant: 120),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -20),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 40)])
        }
        addConstraints(fromView: confirmationButton, toView: self)
        
    }
    private func addTitle() {
        
        self.addSubview(titleLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: imageThumb.trailingAnchor, constant: 20),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -20),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0)])
        }
        addConstraints(fromView: titleLabel, toView: self)
        
    }
    private func addThumbNail() {
        
        self.addSubview(imageThumb)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor,constant: -10),
                                         fromView.topAnchor.constraint(equalTo: toView.topAnchor ,constant: 10),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor ,constant: -10)])
        }
        addConstraints(fromView: imageThumb, toView: imageBG)
        
    }
    private func addImageBG() {
        
        self.addSubview(imageBG)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 20),
                                         fromView.widthAnchor.constraint(equalToConstant: 50),
                                        fromView.heightAnchor.constraint(equalToConstant: 50),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor,constant: 0)])
        }
        addConstraints(fromView: imageBG, toView: self)
        
    }
    private func animateConfirmation(on: Bool? = true) {
        confirmationButton.isHidden = on! ? false : false
        let alpha:CGFloat = on! ? 1.0 : 0.0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.confirmationButton.alpha = alpha
            self.titleLabel.alpha = 1 - alpha
            self.layoutIfNeeded()
        }) { (_) in
            if !on! {
                self.confirmationButton.isHidden = true
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            if confirmationDisplaying == false {
                animateConfirmation()
                confirmationDisplaying.toggle()
            }else{
                animateConfirmation(on: false)
                confirmationDisplaying.toggle()
            }
            
        }else{
            animateConfirmation(on: false)
        }
        
    }

}
