//
//  PointOfInterestVC.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class PointOfInterestVC: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let layout = SnappingCollectionViewLayoutWithOffset()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collection.delegate = self
        collection.backgroundColor = .white
        collection.dataSource = self
        collection.decelerationRate = .fast
        collection.showsHorizontalScrollIndicator = false
        collection.register(POIsCell.self, forCellWithReuseIdentifier: "cellID")
        collection.register(BarChartCell.self, forCellWithReuseIdentifier: "cellID2")
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
extension PointOfInterestVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID2", for: indexPath) as! BarChartCell
            return cell
        }else{
            let metrics = ["speedometer","location.fill","cloud.sun.fill"]
            
            let merticValues = ["75 Kmh","47.567903N 2.74893W",""]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! POIsCell
            return cell
        }

        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        return CGSize(width: width, height: height)
        
    }
    
    
}

