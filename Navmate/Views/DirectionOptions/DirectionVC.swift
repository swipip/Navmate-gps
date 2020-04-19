//
//  DirectionVC.swift
//  Navmate
//
//  Created by Gautier Billard on 18/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import CoreLocation

protocol DirectionVCDelegate {
    func didEngagedNavigation()
    func didDismissNavigation()
    func didChooseOptions(mode: String, preference: String, avoid: [String],destination: CLLocation)
}
class DirectionVC: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let layout = SnappingCollectionViewLayoutWithOffset()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collection.delegate = self
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.decelerationRate = .fast
        collection.showsHorizontalScrollIndicator = false
        collection.register(DirectionGoCell.self, forCellWithReuseIdentifier: "cellID")
        collection.register(DirectionOptionsCell.self, forCellWithReuseIdentifier: "cellID2")
        return collection
    }()

    var delegate: DirectionVCDelegate?
    
    var summary: Summary?
    var destination: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        
        addCollectionView()
        
    }
    func updateValues(summary: Summary, destination: CLLocation) {
        
        self.destination = destination
        self.summary = summary
        self.collectionView.reloadData()
        
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
extension DirectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let index = indexPath.row
        
        if index == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! DirectionGoCell
            
            if let summary = summary, let destination = destination {
                cell.updateValues(summary: summary, destination: destination)
            }
            
            cell.delegate = self
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID2", for: indexPath) as! DirectionOptionsCell
            cell.delegate = self
            return cell
        }

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        return CGSize(width: width, height: height)
        
    }
    
    
}
extension DirectionVC: DirectionGoCellDelegate {
    func didDismissNavigation() {
        delegate?.didDismissNavigation()
    }
    
    func didEngagedNavigation() {
        delegate?.didEngagedNavigation()
    }
    
    
}
extension DirectionVC: DirectionOptionsCellDelegate {
    func didChooseOptions(mode: String, preference: String, avoid: [String]) {
        delegate?.didChooseOptions(mode: mode, preference: preference, avoid: avoid, destination: destination!)
    }
}
class SnappingCollectionViewLayoutWithOffset: UICollectionViewFlowLayout {

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left
        

        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)

        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)

        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        })

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
