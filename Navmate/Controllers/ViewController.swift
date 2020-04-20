//
//  ViewController.swift
//  Navmate
//
//  Created by Gautier Billard on 12/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {

    //MARK: - UI
    lazy var mapView: MapVC = {
        let map = MapVC()
        map.delegate = self
        return map
    }()
    private lazy var searchVC: SearchVC = {
        let child = SearchVC()
        child.delegate = self
        return child
    }()
    private lazy var selectableAreaMapVC: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:)))
        view.addGestureRecognizer(panGesture)
        
        return view
    }()
    private lazy var selectableAreaSearchVC: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:)))
        view.addGestureRecognizer(panGesture)
        
        return view
    }()
    private lazy var locationButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = K.shared.cornerRadiusImageThumbNailCell
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = K.shared.brown
        button.addTarget(self, action: #selector(locationButtonPressed(_ :)), for: .touchUpInside)
        return button
    }()
    private lazy var directionCardVC: DirectionVC = {
        let child = DirectionVC()
        child.delegate = self
        return child
    }()
    //MARK: - Animations Variables
    private var animators = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    
    //SearchVC animation
    private lazy var searchVCTopConstraint = NSLayoutConstraint()
    var cardVisible = false
    var nextState: searchVCState {
        return cardVisible ? .collapsed : .expanded
    }
    
    enum searchVCState {
        case expanded, collapsed, hidden
    }
    //MapVC
    private lazy var MapVCTopConstraint = NSLayoutConstraint()
    var mapVisible = true
    var nextStateMap: MapVCState {
        return mapVisible ? .collapsed : .midWay
    }
    enum MapVCState {
        case total, collapsed, midWay
    }
    //MARK: - Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        addMapView()
        addSearchVC()
        addSelectableHandle()
        addSelectableHandleMap()
        addLocationButton()
        
    }
    //MARK: - UI Construction
    private func addDirectionCard() {
        
        self.addChild(directionCardVC)
        directionCardVC.willMove(toParent: self)
        let directionCardVCView = directionCardVC.view!
        directionCardVCView.alpha = 1
        self.view.addSubview(directionCardVCView)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 250),
                                        fromView.bottomAnchor.constraint(equalTo: locationButton.topAnchor,constant: -10)])
        }
        addConstraints(fromView: directionCardVCView, toView: self.view)
    }
    @objc private func locationButtonPressed(_ sender: UIButton!) {
        
        mapView.showUserLocation()
        
    }
    private func addLocationButton() {
        
        self.view.addSubview(locationButton)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.widthAnchor.constraint(equalToConstant: 40),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.heightAnchor.constraint(equalToConstant: 40),
                                        fromView.bottomAnchor.constraint(equalTo: toView.topAnchor,constant: -20)])
        }
        addConstraints(fromView: locationButton, toView: self.searchVC.view!)
        
    }
    private func addSelectableHandle() {
        
        self.view.addSubview(selectableAreaSearchVC)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 20)])
        }
        addConstraints(fromView: selectableAreaSearchVC, toView: self.searchVC.view!)
        
    }
    private func addSelectableHandleMap() {
        
        self.view.addSubview(selectableAreaMapVC)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 20)])
        }
        addConstraints(fromView: selectableAreaMapVC, toView: self.mapView.view!)
        
    }
    func addSearchVC() {
        
        self.addChild(searchVC)
        searchVC.willMove(toParent: searchVC)
        let view = searchVC.view!
        view.layer.cornerRadius = 12
        self.view.addSubview(view)
        
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: self.view.frame.size.height)])
        }
        addConstraints(fromView: view, toView: self.view)
        
        searchVCTopConstraint = NSLayoutConstraint(item: searchVC.view!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -100)
        self.view.addConstraint(searchVCTopConstraint)
        
    }
    func addMapView() {
        self.addChild(mapView)
        mapView.willMove(toParent: self)
        self.view.addSubview(mapView.view)
        
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: 0)])
            
            MapVCTopConstraint = NSLayoutConstraint(item: fromView, attribute: .top, relatedBy: .equal, toItem: toView, attribute: .top, multiplier: 1, constant: 0)
            
            self.view.addConstraint(MapVCTopConstraint)
            
        }
        addConstraints(fromView: mapView.view, toView: self.view)
        
    }
    //MARK: - Animations
    @objc private func panHandler(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if recognizer.view == selectableAreaSearchVC {
                startInteractiveTransition(state: nextState, duration: 0.9)
            }else{
                startInteractiveTransitionMap(state: nextStateMap, duration: 0.9)
            }
            
        case .changed:
            let translation = recognizer.translation(in: self.view)
            
            var fractionComplete = translation.y / 340
            
            if recognizer.view == selectableAreaSearchVC {
                fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            }else{
                fractionComplete = mapVisible ? fractionComplete : -fractionComplete
            }
            
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    func animateTransitionIfNeededMap (state:MapVCState, duration:TimeInterval) {
        if animators.isEmpty {
            let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .total:
                    self.MapVCTopConstraint.constant = 0
                    
                    self.view.layoutIfNeeded()
                case .collapsed:
                    self.MapVCTopConstraint.constant = 600
                    self.mapView.view.layer.cornerRadius = 12
                    self.view.layoutIfNeeded()
                case .midWay:
                    self.MapVCTopConstraint.constant = 500
                    self.mapView.view.layer.cornerRadius = 12
                    self.view.layoutIfNeeded()
                }
            }
            animator.addCompletion { (_) in
                self.mapVisible.toggle()
                self.animators.removeAll()

            }

            animator.startAnimation()
            animators.append(animator)
            
        }
        
    }
    func startInteractiveTransitionMap(state:MapVCState, duration:TimeInterval) {
        
        if animators.isEmpty {
            animateTransitionIfNeededMap(state: state, duration: duration)
        }
        for animator in animators {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }


    }
    
    func animateTransitionIfNeeded (state:searchVCState, duration:TimeInterval) {
        if animators.isEmpty {
            let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.searchVCTopConstraint.constant = -self.view.frame.size.height * 0.8
                    self.searchVC.researchTable.alpha = 1.0
                    self.view.layoutIfNeeded()
                case .collapsed:
                    self.searchVCTopConstraint.constant = -100
                    
                    self.view.layoutIfNeeded()
                case .hidden:
                    self.searchVCTopConstraint.constant = 0
                    
                    self.view.layoutIfNeeded()
                }
            }
            animator.addCompletion { (_) in
                self.cardVisible.toggle()
                self.animators.removeAll()

            }
            if state == .collapsed {self.searchVC.resignKeyboard()}
            animator.startAnimation()
            animators.append(animator)
            
        }
        
    }
    func startInteractiveTransition(state:searchVCState, duration:TimeInterval) {
        
        if animators.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in animators {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }


    }
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        
        for animator in animators {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
        
    }
    
    func continueInteractiveTransition (){
        
        for animator in animators {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
        
    }
    

}
extension ViewController: MonumentManagerDelegate {
    
    func didFetchData(monuments: [Monument]) {
        #warning("update server with right longitude")
//        let coordinate = CLLocation(latitude: monuments[120].latitude, longitude: -monuments[120].longitude)
//
//        mapView.updatePosition(with: coordinate, name: monuments[120].name)
        
    }
    
}
extension ViewController: SearchVCDelegate {
    func didSelectedPOI(type: String) {
        
        self.animateTransitionIfNeeded(state: .collapsed, duration: 1)
        
        if let location = Locator.shared.getUserLocation() {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 8000, longitudinalMeters: 8000)
            self.mapView.mapView.setRegion(region, animated: true)
            
            let request = MKLocalSearch.Request()
            request.region = region
            request.naturalLanguageQuery = type
            let localSearch = MKLocalSearch(request: request)
            localSearch.start { (response, error) in
                if let err = error {
                    print(err)
                }else{
                    
                    if let places = response?.mapItems {
                        for place in places {
                            
                            let annotation = CustomPin(title: place.name ?? "name", subtitle: type, coordinate: place.placemark.coordinate)
//                            annotation.title = place.name
//                            annotation.coordinate = place.placemark.coordinate
                            self.mapView.mapView.addAnnotation(annotation)
                            
                        }
                    }
                }
            }
        }
    }
    
    func didSelectAddress(placemark: MKPointAnnotation) {
        
        let pinAnnotation = MKPinAnnotationView(annotation: placemark, reuseIdentifier: "")
        
        self.mapView.mapView.addAnnotation(placemark)
        
        let region = MKCoordinateRegion(center: placemark.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        self.mapView.mapView.setRegion(region, animated: true)
        
        self.animateTransitionIfNeeded(state: .collapsed, duration: 1)
        
    }
    
    private func cleanMapView() {
        self.mapView.mapView.removeOverlays(mapView.mapView.overlays)
        self.mapView.mapView.removeAnnotations(mapView.mapView.annotations)
    }
    
    func didEnterSearchField() {
        self.animateTransitionIfNeeded(state: .expanded, duration: 1)
        cleanMapView()
    }
 
}
extension ViewController: MapVCDelegate {
    func didRequestAdditionnalInfo(location: CLLocation) {
        let vc = WikiMapDetailVC()
        vc.delegate = self
        vc.getInfo(monumentLocation: location)
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: nil)
        
        self.directionCardVC.view.animateAlpha(on: false)
        
    }
    
    func didDrawRoute(summary: Summary,destination: CLLocation) {
        self.addDirectionCard()
        self.animateTransitionIfNeeded(state: .hidden, duration: 0.6)
        self.directionCardVC.updateValues(summary: summary, destination: destination)
        
    }
}
extension ViewController: DirectionVCDelegate {
    
    func didChooseOptions(mode: String,preference: String, avoid: [String],destination: CLLocation) {
        
        self.mapView.updateRoute(mode: mode,preference: preference, avoid: avoid, to: destination)
        self.cleanMapView()
    }
    
    func didEngagedNavigation() {
        
        self.removeDirectionCard()
        self.mapView.animateMapView()
        self.mapView.view.addShadow(radius: 5, opacity: 0.5, color: .gray)
        self.mapView.centerOnUserLocation()
        self.animateTransitionIfNeededMap(state: .collapsed, duration: 0.9)
        
    }
    
    func removeDirectionCard() {
        
        let view = directionCardVC.view!
        
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 0
        }) { (_) in
            self.directionCardVC.willMove(toParent: nil)
            self.directionCardVC.removeFromParent()
            view.removeFromSuperview()
        }
        
    }
    
    func didDismissNavigation() {
        self.cleanMapView()
        self.removeDirectionCard()
        self.animateTransitionIfNeeded(state: .collapsed, duration: 0.6)
    }
    
}
extension ViewController: WikiMapDetailVCDelegate {
    func didDismiss() {
        directionCardVC.view.animateAlpha()
    }
    
    func didRequestMoreInfo() {
        
    }
    
}
extension UIView {
    func addShadow(radius: CGFloat, opacity: Float, color: UIColor) {
        
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        
    }
}
