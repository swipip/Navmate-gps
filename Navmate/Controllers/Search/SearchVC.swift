//
//  SearchVC.swift
//  Navmate
//
//  Created by Gautier Billard on 16/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import MapKit
protocol SearchVCDelegate {
    func didEnterSearchField()
    func didSelectAddress(placemark: MKPointAnnotation)
    func didSelectedPOI(type: String)
}
class SearchVC: UIViewController {
    
    private lazy var searchField: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = .default
        searchBar.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        return searchBar
    }()
    private lazy var handle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.backgroundColor = .systemGray4
        return view
    }()
    lazy var researchTable: UITableView = {
        let table = UITableView()
        table.register(ResearchCell.self, forCellReuseIdentifier: Cells.searchCell)
        table.register(MonumentCell.self, forCellReuseIdentifier: Cells.monumentCell)
        table.alpha = 0.0
        table.backgroundColor = K.shared.white
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        return table
    }()
    //MARK: - Data
    
    struct Cells {
        static let searchCell = "cellID"
        static let monumentCell = "cellID2"
    }
    
    private var searchCompletionResults:[MKLocalSearchCompletion]?
    private var searchQueryResults:[MKPlacemark]?
    private let searchCompleter = MKLocalSearchCompleter()
    var delegate: SearchVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter.delegate = self
        
        self.view.backgroundColor = K.shared.white
        
        addSearchBar()
        addHandle()
        addSearchResultsTable()
        
    }
    deinit {
        print("search vc out")
    }
    func transitionTable() {
        
        if let cell = researchTable.cellForRow(at: IndexPath(item: 0, section: 0)) as? MonumentCell {
            cell.collectionView.invalidateIntrinsicContentSize()
            cell.collectionView.reloadData()
        }
        
        
    }
    func resignKeyboard() {
        self.searchField.resignFirstResponder()
        self.researchTable.alpha = 0.0
    }
    private func addSearchResultsTable() {
        
        self.view.addSubview(researchTable)
        
        researchTable.autoresizingMask = .flexibleWidth
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 0),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor, constant: 0)])
        }
        addConstraints(fromView: researchTable, toView: self.view)
    }
    private func addHandle() {
        self.view.addSubview(handle)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: 0),
                                        fromView.widthAnchor.constraint(equalToConstant: 100),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10),
                                        fromView.heightAnchor.constraint(equalToConstant: 6)])
        }
        addConstraints(fromView: handle, toView: self.view)
    }
    private func addSearchBar() {
        
        self.view.addSubview(searchField)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -10),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 20),
                                        fromView.heightAnchor.constraint(equalToConstant: 50)])
        }
        addConstraints(fromView: searchField, toView: self.view)
    }
    

}
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if section == 0 {
            return 1
        }else{
            if let searchQuery = self.searchCompletionResults {
                return min(searchQuery.count,5)
            }else{
                return 5
            }
        }

    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let _ = scrollView as? UITableView {
            searchField.resignFirstResponder()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let titles = ["Intéréssant aux alentours","Recherche"]
        
        let headerView = UIView()
        headerView.backgroundColor = K.shared.white
        
        let label = UILabel()
        label.text = titles[section]
        label.font = UIFont.systemFont(ofSize: 20,weight: .medium)

        headerView.addSubview(label)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 20),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0)])
        }
        addConstraints(fromView: label, toView: headerView)
        
        return headerView
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.monumentCell, for: indexPath) as! MonumentCell
            cell.delegate = self
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.searchCell, for: indexPath) as! ResearchCell
            
            if let searchResults = self.searchCompletionResults {
                let i = indexPath.row
                let title = searchResults[i].title
                if title == "Restaurants" || title == "Restaurant"{
                    cell.passDataToCell(title: searchResults[i].title, subTitle: searchResults[i].subtitle, imageName: "restaurant", searchResult: searchResults[i])
                }else if title == "Aeroport" || title == "Internationnal Airports" || title.contains("Aéroports") || title.contains("Aéroport") || title.contains("Airport"){
                    cell.passDataToCell(title: searchResults[i].title, subTitle: searchResults[i].subtitle, imageName: "airport", searchResult: searchResults[i])
                }else if title == "Bars"{
                    cell.passDataToCell(title: searchResults[i].title, subTitle: searchResults[i].subtitle, imageName: "bar", searchResult: searchResults[i])
                }else if title.contains("Station service") || title.contains("Gas") || title.contains("Essence") {
                    cell.passDataToCell(title: searchResults[i].title, subTitle: searchResults[i].subtitle, imageName: "gas", searchResult: searchResults[i])
                }else {
                    cell.passDataToCell(title: searchResults[i].title, subTitle: searchResults[i].subtitle, imageName: "place", searchResult: searchResults[i])
                }
            }
            
            return cell
        }
        

        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.searchField.resignFirstResponder()
        
        if let cell = tableView.cellForRow(at: indexPath) as? ResearchCell {
            if cell.searchResult.subtitle == "Search Nearby" || cell.searchResult.subtitle == "Rechercher à proximité" {
                
                delegate?.didSelectedPOI(type: cell.searchResult.title)
                
            }else{
                let address = "\(cell.searchResult.title) \(cell.searchResult.subtitle)"
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address) { (placemarks, error) in
                    if let err = error {
                        print(err)
                    }else if let place = placemarks?.first {
                        let mkPlacemark = MKPlacemark(placemark: place)
                        
                        let annotation = MKPointAnnotation()
                        annotation.title = cell.searchResult.title
                        annotation.subtitle = cell.searchResult.subtitle
                        annotation.coordinate = mkPlacemark.coordinate
                        
                        self.researchTable.alpha = 0.0
                        self.delegate?.didSelectAddress(placemark: annotation)
                    }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }else {
            return 70
        }
    }
    
    
    
}
extension SearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        searchCompleter.queryFragment = searchBar.text!
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.didEnterSearchField()
        
    }
    
}
extension SearchVC: MonumentCellDelegate {
    
    func didSelectMonument(monument: Monument) {
 
        let placeMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: monument.latitude, longitude: -monument.longitude))
        
        let annotation = MonumentAnnotation()
        annotation.title = monument.name
        annotation.subtitle = "Monument \(monument.protection.lowercased())"
        annotation.coordinate = placeMark.coordinate
//        annotation.destinationType = .monument
        
        self.researchTable.alpha = 0.0
        delegate?.didSelectAddress(placemark: annotation)
        
    }
    
    
}
extension SearchVC: MKLocalSearchCompleterDelegate {
    
    
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        print(completer.results)
        searchCompletionResults = [MKLocalSearchCompletion]()
        
        completer.results.forEach { (result) in
            self.searchCompletionResults!.append(result)
        }
        
        researchTable.alpha = 1.0
        researchTable.reloadData()
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
    
}


