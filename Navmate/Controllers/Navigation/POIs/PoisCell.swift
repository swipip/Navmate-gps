//
//  PoisCell.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class POIsCell: UICollectionViewCell {
    
    private lazy var cardBG: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addShadow(radius: 5, opacity: 0.5, color: .gray)
        view.layer.cornerRadius = 8
        return view
    }()
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.showsVerticalScrollIndicator = false
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        return table
    }()
    private lazy var cardTitle: UILabel = {
        let label = UILabel()
        label.text = "Lieux Interessants"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25,weight: .medium)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addCard()
        self.addLabel()
        self.addTableView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addTableView(){
        self.addSubview(tableView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -0),
                                        fromView.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: 5),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -5)])
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        
        cell.textLabel?.text = "Point of Interest"
        
        return cell
    }
    
    
}
