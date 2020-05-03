//
//  UserLogIn.swift
//  Navmate
//
//  Created by Gautier Billard on 02/05/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import AuthenticationServices

class UserLogIn: UIViewController {

    private var appleButton = ASAuthorizationAppleIDButton()
    
    private lazy var connexionBG: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = K.shared.blueBars!.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = K.shared.cornerRadiusCard
        return view
    }()
    private lazy var connectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = K.shared.blue
        button.setTitle("Connexion", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(connect(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "e-mail"
        textField.autocapitalizationType = .none
        textField.textColor = K.shared.blueBars
        textField.tintColor = K.shared.blueBars
        textField.textAlignment = .center
        return textField
    }()
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "mot de passe"
        textField.textAlignment = .center
        textField.tintColor = K.shared.blueBars
        textField.textColor = K.shared.blueBars
        textField.isSecureTextEntry = true
        return textField
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Connexion"
        
        if let mode = WeatherManager.shared.checkForDarkmode() {
            if mode == false {
                overrideUserInterfaceStyle = .dark
            }
        }
        
        self.view.backgroundColor = K.shared.white
        
        addConnexionBG()
        addLine()
        addEmailTextField()
        addPasswordTextField()
        addAppleButton()
        addButton()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.navigationBar.back
        self.navigationController?.navigationBar.isHidden = false
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if previousTraitCollection?.userInterfaceStyle == UIUserInterfaceStyle.light {
            self.navigationController?.navigationBar.largeTitleTextAttributes         = [NSAttributedString.Key.foregroundColor: K.shared.white as Any]
            self.navigationController?.navigationBar.tintColor                        = K.shared.white
        }
        
        connexionBG.layer.borderColor = K.shared.blueBars!.cgColor
    }
    @objc private func connect(_ sender:UIButton!){
        
        let userAccount = UserAccountPage()
        
        self.navigationController?.pushViewController(userAccount, animated: true)
        
    }
    private func addButton() {
        
        self.view.addSubview(connectButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 40),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -40),
                                        fromView.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: 40),
                                        fromView.heightAnchor.constraint(equalToConstant: 40)])
        }
        addConstraints(fromView: connectButton, toView: self.view)
        
    }
    private func addAppleButton() {
        
        appleButton.cornerRadius = 8
        
        self.view.addSubview(appleButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 40),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -40),
                                        fromView.topAnchor.constraint(equalTo: connexionBG.bottomAnchor, constant: 40),
                                        fromView.heightAnchor.constraint(equalToConstant: 40)])
        }
        addConstraints(fromView: appleButton, toView: self.view)
        
    }
    private func addPasswordTextField() {
        
        self.view.addSubview(passwordTextField)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -10),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor, constant: -5),
                                        fromView.heightAnchor.constraint(equalToConstant: 30)])
        }
        addConstraints(fromView: passwordTextField, toView: self.connexionBG)
        
    }
    private func addEmailTextField() {
        
        self.view.addSubview(emailTextField)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -10),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 5),
                                        fromView.heightAnchor.constraint(equalToConstant: 30)])
        }
        addConstraints(fromView: emailTextField, toView: self.connexionBG)
        
    }
    private func addConnexionBG() {
        
        self.view.addSubview(connexionBG)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 40),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: -40),
                                         fromView.topAnchor.constraint(equalTo: toView.layoutMarginsGuide.topAnchor, constant: 80),
                                        fromView.heightAnchor.constraint(equalToConstant: 80)])
        }
        addConstraints(fromView: connexionBG, toView: self.view)
        
    }
    private func addLine() {
        
        let line = UIView()
        line.backgroundColor = K.shared.blueBars
        
        self.view.addSubview(line)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: 0),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 1)])
        }
        addConstraints(fromView: line, toView: self.connexionBG)
        
    }
}
extension UserLogIn: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
}
