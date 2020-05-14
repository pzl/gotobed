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
        setupTimeLabel()
    }
    
    func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            timeLabel.leadingAnchor.constraint(equalTo: safeMargins.leadingAnchor),
        ])
    }
}
