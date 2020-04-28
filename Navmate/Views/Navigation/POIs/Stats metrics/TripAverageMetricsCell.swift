//
//  TripAverageMetricsCell.swift
//  Navmate
//
//  Created by Gautier Billard on 21/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class TripAverageMetricsCell: CommonPoisCell {
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.delegate = self
        table.register(AvgMetricsCell.self, forCellReuseIdentifier: "CellID1")
        table.dataSource = self
        return table
    }()
    private lazy var thumbsBack: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "blueGray")
        return view
    }()
    private lazy var container: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = K.shared.white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = K.shared.white
        
        self.addCard()
        self.addContainer()
        self.addThumbBackground()
        self.addTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func addTableView() {
        
        self.addSubview(self.tableView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: self.tableView, toView: self.container)
        
    }
    private func addThumbBackground() {
        
        self.container.addSubview(thumbsBack)
        
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.widthAnchor.constraint(equalToConstant: 100),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: thumbsBack, toView: self.container)
        
    }
    private func addContainer() {
        
        self.addSubview(self.container)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                         fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor ,constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
        }
        addConstraints(fromView: self.container, toView: self.cardBG)
        
    }
    
    
}
extension TripAverageMetricsCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID1", for: indexPath) as! AvgMetricsCell
        
        let i = indexPath.row
        switch i {
        case 0:
            cell.passData(imageName: "speedWhite", metricName: "Max", cellType: .maxSpeed)
        case 1:
            cell.passData(imageName: "speedWhite", metricName: "Moy", cellType: .avgSpeed)
        case 2:
            cell.passData(imageName: "timeWhite", metricName: "Durée", cellType: .duration)
        case 3:
            cell.passData(imageName: "roadWhite", metricName: "Distance", cellType: .distance)
        default:
            break
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
}
