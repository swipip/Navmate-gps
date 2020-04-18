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
    func didSelectAddress(placemark: MKPlacemark)
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
    private lazy var researchTable: UITableView = {
        let table = UITableView()
        table.register(ResearchCell.self, forCellReuseIdentifier: "cellID")
        table.alpha = 1.0
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        return table
    }()
    //Data
    private var searchCompletionResults:[MKLocalSearchCompletion]?
    private var searchQueryResults:[MKPlacemark]?
    private let searchCompleter = MKLocalSearchCompleter()
    var delegate: SearchVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchCompleter.delegate = self
        
        self.view.backgroundColor = .white
        
        addSearchBar()
        addHandle()
        addSearchResultsTable()
        
    }
    func resignKeyboard() {
        self.searchField.resignFirstResponder()
        self.researchTable.alpha = 0.0
    }
    private func addSearchResultsTable() {
        
        self.view.addSubview(researchTable)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0),
                                        fromView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 300)])
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
        
        if let searchQuery = self.searchCompletionResults {
            return min(searchQuery.count,5)
        }else{
            return 5
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! ResearchCell
        
        if let searchResults = self.searchCompletionResults {
            let i = indexPath.row
            cell.passDataToCell(title: searchResults[i].title, subTitle: searchResults[i].subtitle, imageName: "place", searchResult: searchResults[i])
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ResearchCell
        let address = "\(cell.searchResult.title) \(cell.searchResult.subtitle)"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let err = error {
                print(err)
            }else if let place = placemarks?.first {
                let mkPlacemark = MKPlacemark(placemark: place)
                self.researchTable.alpha = 0.0
                self.delegate?.didSelectAddress(placemark: mkPlacemark)
                self.searchField.resignFirstResponder()
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
extension SearchVC: MKLocalSearchCompleterDelegate {
    
    
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print(completer.results)
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
