//
//  MonumentCell.swift
//  Navmate
//
//  Created by Gautier Billard on 19/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import CoreLocation
protocol MonumentCellDelegate {
    func didSelectMonument(monument: Monument)
}
class MonumentCell: UITableViewCell {

    lazy var collectionView: UICollectionView = {
        let layout = SnappingCollectionViewLayoutWithOffset()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collection.delegate = self
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.decelerationRate = .fast
        collection.showsHorizontalScrollIndicator = false
        collection.register(MonumentSearchDetailCell.self, forCellWithReuseIdentifier: "cellID")
        return collection
    }()
    
    private var monuments = [Monument]()
    var delegate: MonumentCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addCollectionView()
        
        if let location = Locator.shared.getUserLocation() {
            let region = CLCircularRegion(center: location.coordinate, radius: 20000, identifier: "")
            MonumentManager.shared.delegate = self
            MonumentManager.shared.getData(for: region)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCollectionView() {
        
        self.addSubview(collectionView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: collectionView, toView: self)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
extension MonumentCell: MonumentManagerDelegate {
    func didFetchData(monuments: [Monument]) {
        for monument in monuments.shuffled() {
            
            self.monuments.append(monument)
            
        }
        self.collectionView.reloadData()
    }
}
extension MonumentCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(1,monuments.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! MonumentSearchDetailCell
        
        if monuments.count != 0 {
            cell.updateData(monument: monuments[indexPath.row])
        }else{
            
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! MonumentSearchDetailCell
    
        if let monument = cell.monument {
            delegate?.didSelectMonument(monument: monument)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = self.frame.size
        
        return size
        
    }
    

}
