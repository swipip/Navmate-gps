//
//  userAchievmentsCell.swift
//  Navmate
//
//  Created by Gautier Billard on 02/05/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class UserAchievmentsCell: CommonPoisCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addCard()
        cardBG.backgroundColor = K.shared.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
