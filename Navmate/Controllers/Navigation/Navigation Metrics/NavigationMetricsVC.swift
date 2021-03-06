//
//  NavigationMetricsVC.swift
//  gpsNavigationView
//
//  Created by Gautier Billard on 18/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class NavigationMetricsVC: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let layout = SnappingCollectionViewLayoutWithOffset()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collection.delegate = self
        collection.backgroundColor = K.shared.white
        collection.dataSource = self
        collection.decelerationRate = .fast
        collection.showsHorizontalScrollIndicator = false
        collection.register(NavigationMetricsCell.self, forCellWithReuseIdentifier: "cellID")
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = K.shared.white
        
        addCollectionView()
        
    }
    private func addCollectionView() {
        
        self.view.addSubview(collectionView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: collectionView, toView: self.view)
        
    }


}
extension NavigationMetricsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! NavigationMetricsCell
        
        switch indexPath.row {
        case 0:
            cell.updateType(type: .speed)
        case 1:
            cell.updateType(type: .location)
        case 2:
            cell.updateType(type: .altitude)
        case 3:
            cell.updateType(type: .course)
        case 4:
            cell.updateType(type: .timeLeft)
        default:
            cell.updateType(type: .course)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        return CGSize(width: width, height: height)
        
    }
    
    
}
