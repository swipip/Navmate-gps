//
//  BarChartCell.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class BarChartCell: UICollectionViewCell {
    
    private lazy var cardBG: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addShadow(radius: 5, opacity: 0.5, color: .gray)
        view.layer.cornerRadius = 8
        return view
    }()
    private lazy var cardTitle: UILabel = {
        let label = UILabel()
        label.text = "Dénivelé"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 22,weight: .medium)
        return label
    }()
    
    private var barBacks: [UIView] = []
    private var bars: [UIView] = []
    private var barHeights:[NSLayoutConstraint] = []
    
    private var maximumHeight:CGFloat = 0
    
    private var barQty = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCard()
        self.addLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addBarBacks()
        
        maximumHeight = 100
        
        self.addBars()
        
    }
    private func addBars() {
        let barWidth = (self.cardBG.frame.size.width - CGFloat(5 * (barQty-1)) - 20)/CGFloat(barQty)
        
        var leadingAch:CGFloat = 10
        
        for i in 0 ..< barQty {
            let bar = UIView()
            bar.layer.cornerRadius = 8
            bar.backgroundColor = UIColor(named: "blue")
            
            self.addSubview(bar)
            
            
            func addConstraints(fromView: UIView, toView: UIView) {
                   
               fromView.translatesAutoresizingMaskIntoConstraints = false
               
               NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: leadingAch),
                                            fromView.widthAnchor.constraint(equalToConstant: barWidth),
                                            fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -30)])
            }
            addConstraints(fromView: bar, toView: cardBG)
            
            let constraint = NSLayoutConstraint(item: bar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: maximumHeight/2)
            
            self.addConstraint(constraint)
            
            leadingAch += barWidth + 5
            
            bars.append(bar)
            barHeights.append(constraint)
            
        }
    }
    private func addBarBacks() {
        
        let barWidth = (self.cardBG.frame.size.width - CGFloat(5 * (barQty-1)) - 20)/CGFloat(barQty)
        
        var leadingAch:CGFloat = 10
        
        for i in 0 ..< barQty {
            let barBack = UIView()
            barBack.layer.cornerRadius = 8
            barBack.backgroundColor = .systemGray5
            
            self.addSubview(barBack)
            
            
            func addConstraints(fromView: UIView, toView: UIView) {
                   
               fromView.translatesAutoresizingMaskIntoConstraints = false
               
               NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: leadingAch),
                                            fromView.widthAnchor.constraint(equalToConstant: barWidth),
                                            fromView.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: 5),
                                            fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -30)])
            }
            addConstraints(fromView: barBack, toView: cardBG)
            
            leadingAch += barWidth + 5
            
            barBacks.append(barBack)
            
        }
        
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
