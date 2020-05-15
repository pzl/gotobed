//
//  TimerCell.swift
//  NightLight
//
//  Created by Dan on 5/13/20.
//  Copyright © 2020 Dan Panzarella. All rights reserved.
//

import Foundation
import UIKit

class TimerCell: UITableViewCell {
    var safeMargins: UILayoutGuide!
    let timeLabel = UILabel()
    
    let stateView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        safeMargins = layoutMarginsGuide
        
        //add subviews, setup constraints
        setupStateView()
        setupTimeLabel()
    }
    
    func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: stateView.trailingAnchor, constant: 10),
        ])
    }
    
    func setupStateView() {
        addSubview(stateView)
        stateView.translatesAutoresizingMaskIntoConstraints = false
        stateView.layer.cornerRadius = 4
        
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stateView.leadingAnchor.constraint(equalTo: safeMargins.leadingAnchor),
            stateView.widthAnchor.constraint(equalToConstant: 5),
            stateView.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
}
