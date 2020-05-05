//
//  UserAccountPage.swift
//  Navmate
//
//  Created by Gautier Billard on 02/05/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class UserAccountPage: UIViewController {

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        button.setImage(UIImage(systemName: "chevron.left",withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(backPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = K.shared.white
        view.roundCorners([.topLeft], radius: 30)
        view.addShadow(radius: 15, opacity: 0.5, color: K.shared.shadow!)
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mon Compte"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 35, weight: .medium)
        return label
    }()
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.register(UserAchievementCell.self, forCellReuseIdentifier: "cellID")
        table.register(UserSettingsCell.self, forCellReuseIdentifier: "cellID2")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let mode = WeatherManager.shared.checkForDarkmode() {
            if mode == false {
                overrideUserInterfaceStyle = .dark
            }
        }
        
        self.view.backgroundColor = K.shared.blue
        
        self.title = "Votre Compte"
        
        addBackGround()
        addTitle()
        addTable()
        addBackButton()
        
    }
    @objc private func backPressed(_ sender:UIButton!){
        self.navigationController?.popToRootViewController(animated: true)
    }
    private func addBackButton() {
        
        self.view.addSubview(backButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.widthAnchor.constraint(equalToConstant: 50),
                                        fromView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -5),
                                        fromView.heightAnchor.constraint(equalToConstant: 50)])
        }
        addConstraints(fromView: backButton, toView: self.view)
        
    }
    private func addTitle() {
        
        self.view.addSubview(titleLabel)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 20),
                                        fromView.bottomAnchor.constraint(equalTo: toView.topAnchor, constant: -15)])
        }
        addConstraints(fromView: titleLabel, toView: self.backView)
        
    }
    private func addBackGround() {
        
        self.view.addSubview(backView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 150),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: backView, toView: self.view)
        
    }
    private func addTable() {
        
        self.view.addSubview(tableView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: 0),
                                         fromView.topAnchor.constraint(equalTo: toView.layoutMarginsGuide.topAnchor, constant: 10),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: tableView, toView: self.backView)
        
    }
}
extension UserAccountPage: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.section
        if index == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! UserAchievementCell
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellID2", for: indexPath) as! UserSettingsCell
            cell.backgroundColor = K.shared.white
            cell.updateData(imageName: "logout",title: "Se déconnecter")
            cell.delegate = self
            return cell
        }
        
        
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let titles = ["Mes Aventures","Réglages"]
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.text = titles[section]
        label.font = UIFont.systemFont(ofSize: 25,weight: .medium)

        headerView.addSubview(label)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 20),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0)])
        }
        addConstraints(fromView: label, toView: headerView)
        
        return headerView
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 250
        }else{
            return 100
        }
    }

    
}
extension UserAccountPage: UserSettingsCellDelegate {
    
    func didConfirm() {
        AuthManager.shared.logOut {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
}
extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
//            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}
