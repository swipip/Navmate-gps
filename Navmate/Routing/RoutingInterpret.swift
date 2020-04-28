//
//  RoutingInterpret.swift
//  Navmate
//
//  Created by Gautier Billard on 26/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation

//https://github.com/GIScience/openrouteservice-docs/blob/master/README.md

class RoutingInterpret:NSObject {
    
    static let shared = RoutingInterpret()
    
    let typeTranslation = [0:"Tounez à gauche",
                           1:"tournez à droite",
                           2:"Virage serré à gauche",
                           3:"Virage serré à droite",
                           4:"Tournez légèrement à gauche",
                           5:"Tournez legèrement à droite",
                           6:"Tout droit",
                           7:"Au rond point",
                           8:"Au rond point",
                           9:"Faites demi-tour",
                           10:"Vous êtes arrivé",
                           11:"C'est parti!",
                           12:"Serrez à gauche",
                           13:"Serrez à droite",]
    
    let typeAngle:[Int:Double] = [0:-90,
                           1:90,
                           2:-135,
                           3:135,
                           4:-45,
                           5:45,
                           6:0,
                           7:90,
                           8:90,
                           9:180,
                           10:0,
                           11:0,
                           12:-20,
                           13:20,]
    
    func interpretType(type: Int) -> String{
      
        let message = typeTranslation[type]!
        
        return message
        
    }



}
