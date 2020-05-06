//
//  WikiMapDetailViewModel.swift
//  Navmate
//
//  Created by Gautier Billard on 06/05/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import CoreLocation

class WikiMapDetailViewModel {
    
    weak var wikiMapDetailVC: WikiMapDetailVC?
    
    var didFind = false
    
    init(location: CLLocation, view: WikiMapDetailVC) {
        
        self.wikiMapDetailVC = view
        
        WikiManagerCoord.shared.requestInfo(location: location)
        WikiManager.shared.delegate = self
        
    }
    
}
extension WikiMapDetailViewModel: WikiManagerDelegate {
    
    func didNotFindData() {
       
        if let wikiMapDetail = self.wikiMapDetailVC {
            
            wikiMapDetail.addNotFoundLabel()
            
            wikiMapDetail.loadingAnimation.removeFromSuperview()
        }
        
    }
    
    func didFindData(wiki: WikiObject) {
        
        if let wikiMapDetail = self.wikiMapDetailVC {
            if let image =  wiki.image {
                wikiMapDetail.imageThumb.image = image
            }
            wikiMapDetail.cardTitle.text = wiki.title
            wikiMapDetail.extract.text = wiki.description
            wikiMapDetail.urlString = wiki.url
            
            didFind = true
            
            wikiMapDetail.loadingAnimation.stop()
            wikiMapDetail.loadingAnimation.removeFromSuperview()
        }
        

        
    }
    
}
