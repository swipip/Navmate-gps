//
//  NavigationVC.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class NavigationVC: UIViewController {

    private lazy var headerBackGround: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "blueGray")
        view.layer.cornerRadius = 0
        return view
    }()
    private lazy var indicationsTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor(named: "accent2")
        table.layer.cornerRadius = 0
        table.separatorStyle = .none
        table.decelerationRate = .fast
        table.register(NavigationCell.self, forCellReuseIdentifier: "cellID")
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        return table
    }()
    private lazy var metricsCollection: NavigationMetricsVC = {
        let navigation = NavigationMetricsVC()
        return navigation
    }()
    private lazy var poisCollection: PointOfInterestVC = {
        let navigation = PointOfInterestVC()
        return navigation
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.view.backgroundColor = UIColor(named: "mainBackground")
        
        self.addIndicationsTableView()
        self.addHeaderBG()
        self.addMetricsCollection()
        self.addPOIsCollection()
        
    }
    private func addPOIsCollection() {
        
        self.addChild(poisCollection)
        poisCollection.willMove(toParent: self)
        
        let view = poisCollection.view!
        self.view.addSubview(view)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: metricsCollection.view.bottomAnchor, constant: 10),
                                        fromView.heightAnchor.constraint(equalToConstant: 300)])
        }
        addConstraints(fromView: view, toView: self.view)
    }
    private func addMetricsCollection() {
        
        self.addChild(metricsCollection)
        metricsCollection.willMove(toParent: self)
        
        let view = metricsCollection.view!
        self.view.addSubview(view)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: indicationsTableView.bottomAnchor, constant: 10),
                                        fromView.heightAnchor.constraint(equalToConstant: 100)])
        }
        addConstraints(fromView: view, toView: self.view)
    }
    private func addIndicationsTableView() {
        self.view.addSubview(indicationsTableView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 50),
                                        fromView.heightAnchor.constraint(equalToConstant: 170)])
        }
        addConstraints(fromView: indicationsTableView, toView: self.view)
        
        indicationsTableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
        
    }
    private func addHeaderBG() {
        
        self.view.addSubview(headerBackGround)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.topAnchor,constant: 60)])
        }
        addConstraints(fromView: headerBackGround, toView: self.view)
        
    }
    

}
extension NavigationVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! NavigationCell
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard var scrollingToIP = indicationsTableView.indexPathForRow(at: CGPoint(x: 0, y: targetContentOffset.pointee.y)) else {
            return
        }
        var scrollingToRect = indicationsTableView.rectForRow(at: scrollingToIP)
        let roundingRow = Int(((targetContentOffset.pointee.y - scrollingToRect.origin.y) / scrollingToRect.size.height).rounded())
        scrollingToIP.row += roundingRow
        scrollingToRect = indicationsTableView.rectForRow(at: scrollingToIP)
        targetContentOffset.pointee.y = scrollingToRect.origin.y
        
        indicationsTableView.selectRow(at: scrollingToIP, animated: true, scrollPosition: .top)

    }
    
    
}
