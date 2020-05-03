//
//  Navmate.swift
//  wikiView
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices
import Lottie

protocol WikiMapDetailVCDelegate {
    func didDismiss()
    func didRequestMoreInfo(urlString: String)
}

class WikiMapDetailVC: UIViewController {

    private lazy var loadingAnimation: AnimationView = {
        let animation = AnimationView()
        animation.animation = Animation.named("progress")
        return animation
    }()
    private lazy var blurView: UIVisualEffectView = {
        var blur = UIBlurEffect()
        if traitCollection.userInterfaceStyle == .light {
            blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        }else{
            blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
        let view = UIVisualEffectView(effect: blur)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    private lazy var cardTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize)
        label.text = ""
        label.alpha = 0.0
        return label
    }()
    private lazy var imageThumb: UIImageView = {
        let image = UIImageView()
        image.image = UIImage()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 8
        image.layer.masksToBounds = true
        image.alpha = 0
        return image
    }()
    private lazy var extract: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: K.shared.cardContentFontSize)
        textView.alpha = 0
        return textView
    }()
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("J'ai vu", for: .normal)
        button.alpha = 0.0
        button.layer.cornerRadius = 8
        button.backgroundColor = K.shared.orange
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var knowMoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("En savoir plus", for: .normal)
        button.alpha = 0.0
        button.layer.cornerRadius = 8
        button.backgroundColor = K.shared.blue
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    var buttonWidth: CGFloat!
    var blurWidth: NSLayoutConstraint!
    var blurHeight: NSLayoutConstraint!
    
    var location: CLLocationCoordinate2D?
    var urlString: String?
    var delegate: WikiMapDetailVCDelegate?
    
    var didFind = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mode = WeatherManager.shared.checkForDarkmode() {
            if mode == false {
                overrideUserInterfaceStyle = .dark
            }
        }
        
        self.addVisualBackground()
        
    }
    func getInfo(monumentLocation location: CLLocation) {
        
        WikiManagerCoord.shared.requestInfo(location: location)
        WikiManager.shared.delegate = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        buttonWidth = (self.view.frame.size.width * 0.8 - 10 * 3)/2
        
        UIView.animate(withDuration: 0.7, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.blurWidth.constant = self.view.frame.size.width * 0.8
            self.blurHeight.constant = self.view.frame.size.height * 0.6
            self.view.layoutIfNeeded()
        }) { (_) in
            self.addTitle()
            self.addImage()
            self.addExtract()
            self.addButton()
            self.addKnowMoreButton()
            if self.didFind == false {
               self.addAnimation()
            }
            
        }
    }
    @objc private func buttonPressed(_ sender:UIButton!) {
        
        if sender == dismissButton {
            self.dismiss(animated: true) {
                
            }
            delegate?.didDismiss()
        }else{
            
            self.dismiss(animated: true, completion: nil)
            delegate?.didRequestMoreInfo(urlString: self.urlString ?? "https://fr.wikipedia.org")
            
        }
        
    }
    private func addAnimation() {
        
        self.view.addSubview(loadingAnimation)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.widthAnchor.constraint(equalToConstant: 60),
                                         fromView.heightAnchor.constraint(equalToConstant: 60),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0),
                                        fromView.centerXAnchor.constraint(equalTo: toView.centerXAnchor,constant: 0)])
        }
        addConstraints(fromView: loadingAnimation, toView: self.blurView)
        
        loadingAnimation.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { (_) in
            
        }
        
    }
    private func addKnowMoreButton() {
        self.view.addSubview(knowMoreButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.widthAnchor.constraint(equalToConstant: buttonWidth),
                                        fromView.heightAnchor.constraint(equalToConstant: 40),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: knowMoreButton, toView: blurView)
        knowMoreButton.animateAlpha()
    }
    private func addButton() {
        self.view.addSubview(dismissButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.widthAnchor.constraint(equalToConstant: buttonWidth),
                                        fromView.heightAnchor.constraint(equalToConstant: 40),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: dismissButton, toView: blurView)
        dismissButton.animateAlpha()
    }
    private func addExtract() {
        
        self.view.addSubview(extract)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.bottomAnchor, constant: 10),
                                        fromView.bottomAnchor.constraint(equalTo: self.blurView.bottomAnchor,constant: -60)])
        }
        addConstraints(fromView: extract, toView: self.imageThumb)
        extract.animateAlpha()
        
    }
    private func addImage() {
        
        self.view.addSubview(imageThumb)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: 10),
                                        fromView.heightAnchor.constraint(equalToConstant: 200)])
        }
        addConstraints(fromView: imageThumb, toView: blurView)
        imageThumb.animateAlpha()
    }
    private func addTitle() {
        self.view.addSubview(cardTitle)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10)])
        }
        addConstraints(fromView: cardTitle, toView: self.blurView)
        
        cardTitle.animateAlpha()
        
    }
    private func addVisualBackground() {
        
        self.view.addSubview(blurView)
        
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0),
                                        fromView.centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: 0)])
            
            blurWidth = NSLayoutConstraint(item: blurView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
            blurHeight = NSLayoutConstraint(item: blurView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
            
            self.view.addConstraints([blurHeight,blurWidth])
            
        }
        addConstraints(fromView: blurView, toView: self.view)
        
    }



}
extension WikiMapDetailVC: WikiManagerDelegate {
    
    func didNotFindData() {
        
        
        let label = UILabel()
        label.text = "La page Wikipédia n'existe pas pour ce lieu"
        label.numberOfLines = 0
        
        self.view.addSubview(label)
        
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 20),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -20),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0)])
        }
        addConstraints(fromView: label, toView: self.blurView)
        
    }
    
    func didFindData(wiki: WikiObject) {
        if let image =  wiki.image {
            self.imageThumb.image = image
        }
        self.cardTitle.text = wiki.title
        self.extract.text = wiki.description
        self.urlString = wiki.url
        
        didFind = true
        
        loadingAnimation.stop()
        loadingAnimation.removeFromSuperview()
        
    }
}
extension UIView {
    func animateAlpha(on: Bool? = true) {
        
        UIView.animate(withDuration: 0.4) {
            self.alpha = on! ? 1.0 : 0.0
        }
        
    }
}
