//
//  ViewController.swift
//  NightLight
//
//  Created by Dan on 10/3/19.
//  Copyright © 2019 Dan Panzarella. All rights reserved.
//

import UIKit
import LightServer

class ViewController: UIViewController {

    lazy var trafficBox: UIView = {
        let t = UIView(frame: .zero)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = .trafficLight
        t.layer.cornerRadius = 10
        return t
    }()
    
    lazy var redView = CircleLight(onColor: .systemRed, offColor: .trafficRed)
    lazy var yellowView = CircleLight(onColor: .systemYellow, offColor: .trafficYellow)
    lazy var greenView = CircleLight(onColor: .green, offColor: .trafficGreen)
    lazy var lampView = Light(onColor: .systemYellow, offColor: .systemGray)
    
    let host = "http://192.168.1.10" // "http://192.168.1.172"
    
    override func viewDidLoad() {
        print("view loaded")
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(trafficBox)
        self.view.addSubview(lampView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        lampView.addGestureRecognizer(tap)
        lampView.layer.cornerRadius = 20
        
        let vs: [Light] = [redView, yellowView, greenView]
        for i in vs {
            self.view.addSubview(i)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            i.addGestureRecognizer(tap)
            
            i.centerXAnchor.constraint(equalTo: trafficBox.centerXAnchor).isActive = true
            i.widthAnchor.constraint(equalTo: trafficBox.widthAnchor, multiplier: 0.6).isActive = true
            i.heightAnchor.constraint(equalTo: i.widthAnchor).isActive = true
        }

        trafficBox.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        trafficBox.widthAnchor.constraint(equalToConstant: 80).isActive = true
        trafficBox.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 2).isActive = true
        trafficBox.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let lightpad: CGFloat = 10
        redView.topAnchor.constraint(equalTo: trafficBox.topAnchor, constant: lightpad).isActive = true
        yellowView.centerYAnchor.constraint(equalTo: trafficBox.centerYAnchor).isActive = true
        greenView.bottomAnchor.constraint(equalTo: trafficBox.bottomAnchor, constant: -lightpad).isActive = true
        
        lampView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        lampView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        lampView.centerXAnchor.constraint(equalTo: trafficBox.centerXAnchor).isActive = true
        lampView.topAnchor.constraint(equalTo: trafficBox.bottomAnchor, constant: 80).isActive = true
        
    }
    
    func reloadState() {
        print("getting state")
        self.getState { state in
            if let state = state {
                self.handleState(state)
            } else {
                print("could not get state")
            }
        }
    }
    
    func getState(_ done: @escaping (TrafficState?) -> Void){
        LSGetState(done)
    }
    
    func setState(_ state: TrafficState) {
        LSSetState(state) { s in
            if let s = s {
                self.handleState(s)
            }
        }
    }
    
    func handleState(_ state: TrafficState) {
        DispatchQueue.main.async {
            self.redView.on = state.red
            self.yellowView.on = state.yellow
            self.greenView.on = state.green
            self.lampView.on = state.lamp
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let s = sender else {
            print("tap: nil sender")
            return
        }
        guard s.view != nil else {
            print("tap: nil view")
            return
        }
        
        var state = TrafficState(redView.on, yellowView.on, greenView.on, lampView.on)
        
        switch s.view {
        case redView:
            state.yellow = false
            state.green = false
            state.red = true
        case yellowView:
            state.red = false
            state.green = false
            state.yellow = true
        case greenView:
            state.red = false
            state.yellow = false
            state.green = true
        case lampView: state.lamp = !state.lamp
        default:
            print("unknown view clicked: \(s.view!)")
        }
        
        self.setState(state)
    }

}


