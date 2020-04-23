//
//  PoisCell.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import CoreLocation
protocol POIsCellDelgate {
    
    func didRequestRouteUpdate(location: CLLocation)
    func didRequestRerouting()
    
}
class POIsCell: UICollectionViewCell {
    
    private lazy var cardBG: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addShadow(radius: 5, opacity: 0.5, color: .gray)
        view.layer.cornerRadius = K.shared.cornerRadiusCard
        return view
    }()
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.showsVerticalScrollIndicator = false
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(MonumentNavigationCell.self, forCellReuseIdentifier: "cellID")
        return table
    }()
    private lazy var cardTitle: UILabel = {
        let label = UILabel()
        label.text = "A découvrir aux alentours"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize,weight: .medium)
        return label
    }()
    private var monuments: [Monument]?
    private var allowReload = true
    
    var delegate: POIsCellDelgate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addCard()
        self.addLabel()
        self.addTableView()
        self.addObservers()
        #warning("remove below for last part")
        if let location = Locator.shared.getUserLocation() {
            
            let region = CLCircularRegion(center: location.coordinate, radius: 20000, identifier: "")
            
            MonumentManager.shared.getData(for: region)
            
            allowReload = false
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func addObservers() {
        
        let notificationMonuments = Notification.Name(K.shared.notificationMonuments)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMonuments(_:)), name: notificationMonuments, object: nil)
        
        let locationNotification = Notification.Name(K.shared.notificationLocation)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveLocationInfo(_:)), name: locationNotification, object: nil)
        
    }
    @objc private func didReceiveMonuments(_ notification:Notification) {
        
        if let monuments = notification.userInfo?["monuments"] as? [Monument] {
            self.monuments = [Monument]()
            self.monuments = monuments
            self.tableView.reloadData()
        }
        
    }
    @objc private func didReceiveLocationInfo(_ notification:Notification) {
        
        if allowReload {
            if let location = notification.userInfo?["location"] as? CLLocation {
                
                let region = CLCircularRegion(center: location.coordinate, radius: 20000, identifier: "")
                
                MonumentManager.shared.getData(for: region)
                
                allowReload = false
            }
        }
        
    }
    private func addTableView(){
        self.addSubview(tableView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -0),
                                        fromView.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: 10),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: tableView, toView: self.cardBG)
    }
    private func addLabel() {
        self.addSubview(cardTitle)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 5)])
        }
        addConstraints(fromView: cardTitle, toView: self.cardBG)
    }
    private func addCard() {
        self.addSubview(cardBG)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 20),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -20),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: cardBG, toView: self)
    }
}
extension POIsCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! MonumentNavigationCell
        
        let i = indexPath.row
        
        if let monuments = self.monuments {
            
            cell.delegate = self
            
            cell.passDataToCell(title: monuments[i].name, subTitle: monuments[i].town, imageName: "historic",monument: monuments[i])
            
        }

        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}

extension POIsCell: MonumentNavigationCellDelegate {
    
    func didPressSeeMoreButton(monument: Monument) {
        
        let view = MonumentNavigationDetail(frame: CGRect(x: 0, y: 0, width: 0, height: 0), monument: monument)
        view.frame = self.cardBG.frame
        view.delegate = self
        self.addSubview(view)
        
        delegate?.didRequestRouteUpdate(location: CLLocation(latitude: monument.latitude, longitude: -monument.longitude))
        
    }
    
}
extension POIsCell: MonumentNavigationDetailDelegate {
    
    func didRequestRerouting() {
        self.delegate?.didRequestRerouting()
    }
    
}
