//
//  TimerEditVC.swift
//  NightLight
//
//  Created by Dan on 5/14/20.
//  Copyright © 2020 Dan Panzarella. All rights reserved.
//

import Foundation
import UIKit
import LightServer

class TimerEditVC: UIViewController {
    let timer: TimedAction
    
    let idLabel = UILabel()
    let timeLabel = UILabel()
    
    lazy var trafficBox: UIView = {
        let t = UIView(frame: .zero)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = .trafficLight
        t.layer.cornerRadius = 10
        return t
    }()
    let Red = CircleLight(onColor: .systemRed, offColor: .trafficRed)
    let Yellow = CircleLight(onColor: .systemYellow, offColor: .trafficYellow)
    let Green = CircleLight(onColor: .green, offColor: .trafficGreen)
    let Lamp = Light(onColor: .systemYellow, offColor: .systemGray)
    
    
    init(timer: TimedAction) {
        self.timer = timer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("no init(coder:) implemented")
    }
    
    override func loadView() {
        super.loadView()
                
        view.addSubview(timeLabel)
        view.addSubview(idLabel)
        view.addSubview(trafficBox)
        view.addSubview(Red)
        view.addSubview(Yellow)
        view.addSubview(Green)
        view.addSubview(Lamp)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        Lamp.layer.cornerRadius = 20
        
        NSLayoutConstraint.activate([
            idLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            idLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeLabel.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 20),
            trafficBox.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            trafficBox.widthAnchor.constraint(equalToConstant: 80),
            trafficBox.heightAnchor.constraint(equalToConstant: 200),
            trafficBox.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            Red.topAnchor.constraint(equalTo: trafficBox.topAnchor, constant: 10),
            Red.widthAnchor.constraint(equalTo: trafficBox.widthAnchor, multiplier: 0.6),
            Red.centerXAnchor.constraint(equalTo: trafficBox.centerXAnchor),
            Red.heightAnchor.constraint(equalTo: Red.widthAnchor),
            Yellow.centerYAnchor.constraint(equalTo: trafficBox.centerYAnchor),
            Yellow.widthAnchor.constraint(equalTo: trafficBox.widthAnchor, multiplier: 0.6),
            Yellow.centerXAnchor.constraint(equalTo: trafficBox.centerXAnchor),
            Yellow.heightAnchor.constraint(equalTo: Yellow.widthAnchor),
            Green.bottomAnchor.constraint(equalTo: trafficBox.bottomAnchor, constant: -10),
            Green.widthAnchor.constraint(equalTo: trafficBox.widthAnchor, multiplier: 0.6),
            Green.centerXAnchor.constraint(equalTo: trafficBox.centerXAnchor),
            Green.heightAnchor.constraint(equalTo: Green.widthAnchor),
            Lamp.widthAnchor.constraint(equalTo: trafficBox.widthAnchor),
            Lamp.heightAnchor.constraint(equalTo: Lamp.widthAnchor),
            Lamp.centerXAnchor.constraint(equalTo: trafficBox.centerXAnchor),
            Lamp.topAnchor.constraint(equalTo: trafficBox.bottomAnchor, constant: 20),
        ])
}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
                
        idLabel.font = UIFont(name: "Verdana-Bold", size: 16)
        idLabel.textColor = .systemGray
        
        let date = Date(timeIntervalSince1970: Double(timer.time))
        let df = DateFormatter()
        df.timeStyle = .medium
        df.dateStyle = .medium
        df.timeZone = .current
        timeLabel.text = df.string(from: date)
        
        if let id = timer.id {
            idLabel.text = "ID: " + id
        } else {
            idLabel.isHidden = true
        }
        
        
        self.Red.on = self.timer.state.red
        self.Yellow.on = self.timer.state.yellow
        self.Green.on = self.timer.state.green
        self.Lamp.on = self.timer.state.lamp
        
    }
}
