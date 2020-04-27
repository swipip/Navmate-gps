//
//  RoutingInterpret.swift
//  Navmate
//
//  Created by Gautier Billard on 26/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation


class RoutingInterpret:NSObject {
    
    static let shared = RoutingInterpret()
    
    let typeTranslation = [0:"Tounez à gauche",
                           1:"tournez à droite",
                           2:"Virage serré à droite",
                           3:"Virage serré à gauche",
                           4:"Tournez légèrement à gauche",
                           5:"Tournez legèrement à gauche",
                           6:"Tout droit",
                           7:"Au rond point",
                           8:"Au rond point",
                           9:"Faites demi-tour",
                           10:"Vous êtes arrivé",
                           11:"C'est parti!",
                           12:"Serrez à gauche",
                           13:"Serrez à droite",]
    
    func interpretType(type: Int) -> String{
      
        let message = typeTranslation[type]!
        
        return message
        
    }



}
