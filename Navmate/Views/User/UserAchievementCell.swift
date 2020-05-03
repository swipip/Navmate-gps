//
//  UserAchievementCell.swift
//  Navmate
//
//  Created by Gautier Billard on 03/05/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class UserAchievementCell: UITableViewCell {

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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addCollection()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func addCollection() {
        
        self.addSubview(collectionView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: 0),
                                         fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                         fromView.bottomAnchor.constraint(equalTo:toView.bottomAnchor, constant: 0)])
        }
        addConstraints(fromView: collectionView, toView: self)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
extension UserAchievementCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! UserRecordCell
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: self.frame.width, height: 200)
        
        return size
    }
    
}
