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
    
    let stateLabel = UILabel()
    
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
        setupStateLabel()
        setupTimeLabel()
    }
    
    func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: stateLabel.topAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: stateLabel.trailingAnchor, constant: 10),
        ])
    }
    
    func setupStateLabel() {
        addSubview(stateLabel)
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stateLabel.leadingAnchor.constraint(equalTo: safeMargins.leadingAnchor),
        ])
    }
}
