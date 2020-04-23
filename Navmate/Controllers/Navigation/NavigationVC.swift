//
//  NavigationVC.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol NavigationVCDelegate {
    func didStartNewRoute(destination: MKAnnotation)
}
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
    
    
    //MARK: - Data
    var steps: [Step]?
    var route: Route?
    
    var newRoute: Route?
    
    var delegate: NavigationVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addIndicationsTableView()
        self.addHeaderBG()
        self.addMetricsCollection()
        self.addPOIsCollection()
        self.addObserver()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Locator.shared.startNavigation()
    }
    private func addObserver() {
        
        let route = Notification.Name(K.shared.notificationRoute)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveRouteInformation(_:)), name: route, object: nil)
        let newStep = Notification.Name(K.shared.notificationNewStep)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewInstruction(_:)), name: newStep, object: nil)
        
    }
    @objc private func didReceiveNewInstruction(_ notification:Notification) {
//        print("\(#function) \(self.indicationsTableView.indexPathForSelectedRow!.row)")
        
        let currentRow = self.indicationsTableView.indexPathForSelectedRow?.row ?? 0
        let nextRow = IndexPath(row: currentRow + 1, section: 0)
        
        if nextRow.row < indicationsTableView.numberOfRows(inSection: 0) - 1{
            
            self.indicationsTableView.selectRow(at: nextRow, animated: true, scrollPosition: .top)
            let cell = indicationsTableView.cellForRow(at: nextRow) as! NavigationCell
            cell.magnify(on: true)
        }
        
    }
    @objc private func didReceiveRouteInformation(_ notification:Notification) {
        
        if let route = notification.userInfo?["route"] as? Route {
            
            self.route = route
            self.steps = route.steps
            self.indicationsTableView.reloadData()
            indicationsTableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
            
        }
        if let route = notification.userInfo?["routeNew"] as? Route {
            
            self.newRoute = route
            
        }
        
    }
     
    private func addPOIsCollection() {
        
        self.addChild(poisCollection)
        poisCollection.delegate = self
        poisCollection.willMove(toParent: self)
        
        let view = poisCollection.view!
        self.view.addSubview(view)
        
        func addConstraints(fromView: UIView, toView: UIView) {
                
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: metricsCollection.view.bottomAnchor, constant: 5),
                                        fromView.bottomAnchor.constraint(equalTo:toView.bottomAnchor ,constant: -160)])
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
                                        fromView.topAnchor.constraint(equalTo: toView.safeAreaLayoutGuide.topAnchor, constant: 0),
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
                                        fromView.bottomAnchor.constraint(equalTo: toView.layoutMarginsGuide.topAnchor,constant: 15)])
        }
        addConstraints(fromView: headerBackGround, toView: self.view)
        
    }
    

}
extension NavigationVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let steps = self.steps {
//            let step = Step(type: 14, instruction: "-", name: "-", wayPoints: [1,1], distance: 0, exitNumber: 0, duration: 0)
//            self.steps?.append(step)
            return steps.count + 1
        }else {
            return 10
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! NavigationCell
        
        if let steps = self.steps {
            let i = indexPath.row
            if i == steps.count {
                let step = Step(type: 14, instruction: "-", name: "-", wayPoints: [1,1], distance: 0, exitNumber: 0, duration: 0)
                cell.updateIndications(main: "-", sub: 0, type: 14, step: step)
            }else{
                cell.updateIndications(main: steps[i].name, sub: steps[max(0,i-1)].distance, type: steps[i].type, step: steps[i])
            }
            
        }
        
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
extension NavigationVC: PointOfInterestVCDelegate {
    func didRequestRouteUpdate(destination: CLLocation) {
        if let userLocation = Locator.shared.getUserLocation() {
            
            if let summary = self.route?.summary {
                Locator.shared.getDirections(from: userLocation.coordinate, to: destination.coordinate, mode: summary.mode , preference: summary.preference, avoid: summary.avoid, calculationMode: .recalculation)
            }
            
        }
    }
    
    
    func didRequestRerouting() {
        if let route = self.newRoute {
            
            
//            switch route.summary.destinationType {
//            case .regular:
//                
////                let annotation = MKAnnotation()
////                annotation.title = "Destination"
////
////                delegate?.didStartNewRoute(destination: annotation)
//                break
//            case .monument:
//                
//                let annotation = MonumentAnnotation()
//                annotation.destinationType = .monument
//                annotation.title = newRoute?.summary.destination ?? "Destination"
//                
//                delegate?.didStartNewRoute(destination: annotation)
//            
//            case .pointOfInterest:
//                break
//            }
            
//            let annotation = CustomPin(title: "Destination", subtitle: "", coordinate: route.wayPoints.last?.coordinate)
            
            Locator.shared.startRerouting()
            
            self.route = route
            
            self.steps = route.steps
            indicationsTableView.reloadData()
            indicationsTableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
            
            
            
        }
    }
    
}
