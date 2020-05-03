//
//  UserAccountPage.swift
//  Navmate
//
//  Created by Gautier Billard on 02/05/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class UserAccountPage: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let layout = SnappingCollectionViewLayoutWithOffset()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collection.delegate = self
        collection.backgroundColor = K.shared.white
        collection.dataSource = self
        collection.decelerationRate = .fast
        collection.showsHorizontalScrollIndicator = false
        collection.register(UserRecordCell.self, forCellWithReuseIdentifier: "cellID")
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let mode = WeatherManager.shared.checkForDarkmode() {
            if mode == false {
                overrideUserInterfaceStyle = .dark
            }
        }
        
        self.view.backgroundColor = K.shared.white
        
        self.title = "Votre Compte"

        addCollection()
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if previousTraitCollection?.userInterfaceStyle == UIUserInterfaceStyle.light {
            self.navigationController?.navigationBar.largeTitleTextAttributes         = [NSAttributedString.Key.foregroundColor: K.shared.white as Any]
            self.navigationController?.navigationBar.tintColor                        = K.shared.white
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        self.navigationController?.but
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationController?.navigationBar.largeTitleTextAttributes         = [NSAttributedString.Key.foregroundColor: K.shared.blueBars as Any]
               self.navigationController?.navigationBar.tintColor                        = K.shared.blueBars
        

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        
    }
    private func addCollection() {
        
        self.view.addSubview(collectionView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: 0),
                                         fromView.topAnchor.constraint(equalTo: toView.layoutMarginsGuide.topAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 300)])
        }
        addConstraints(fromView: collectionView, toView: self.view)
        
    }
    

}
extension UserAccountPage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! UserRecordCell
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: self.view.frame.width, height: 200)
        
        return size
    }
    
}
