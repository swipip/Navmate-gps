//
//  WikiDetailVC.swift
//  Navmate
//
//  Created by Gautier Billard on 21/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import WebKit

class WikiDetailVC: UIViewController {
    
    private lazy var webView = WKWebView()
    
    private lazy var blurView: UIVisualEffectView = {
        var blur = UIBlurEffect()
        if traitCollection.userInterfaceStyle == .light {
            blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        }else{
            blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
        let visualEffect = UIVisualEffectView(effect: blur)
        visualEffect.layer.cornerRadius = 12
        visualEffect.clipsToBounds = true
        return visualEffect
    }()
    private lazy var cardTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize)
        label.text = "Détails"
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBlur()
        self.addWebView()
        self.addTitle()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let mode = WeatherManager.shared.checkForDarkmode() {
            if mode == false {
                overrideUserInterfaceStyle = .dark
            }
        }
    }
    private func addTitle() {
        self.view.addSubview(cardTitle)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.centerYAnchor.constraint(equalTo: toView.topAnchor, constant: 25)])
        }
        addConstraints(fromView: cardTitle, toView: self.view)
    }
    private func addBlur() {
        
        self.view.addSubview(blurView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: self.blurView, toView: self.view)
        
    }
    private func addWebView() {
        
        self.view.addSubview(webView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 50),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: self.webView, toView: self.view)
        
    }
    func urlToOpen(urlString:String) {
        //https://fr.wikipedia.org/wiki/Chapelle_Notre-Dame-la-Blanche_de_Gu%C3%A9rande
        
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            self.webView.navigationDelegate = self
            self.webView.uiDelegate = self
            self.webView.load(urlRequest)
            
            
        }
    }
}
extension WikiDetailVC: WKUIDelegate,WKNavigationDelegate {
    func webView(_ webView: WKWebView,
      didFail navigation: WKNavigation!,
      withError error: Error) {
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        

    }
}
