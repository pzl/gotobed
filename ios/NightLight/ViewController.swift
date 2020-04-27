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
    
    lazy var spinner: UIView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.startAnimating()
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        let s = UIView(frame: .zero)
        s.backgroundColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        s.layer.cornerRadius = 10
        s.translatesAutoresizingMaskIntoConstraints = false
        s.addSubview(ai)
        NSLayoutConstraint.activate([
            ai.centerXAnchor.constraint(equalTo: s.centerXAnchor),
            ai.centerYAnchor.constraint(equalTo: s.centerYAnchor),
            ai.widthAnchor.constraint(equalTo: s.widthAnchor),
            ai.heightAnchor.constraint(equalTo: s.heightAnchor),
        ])
        return s
    }()
    
    lazy var failView: UIView = {
        let v = UIView(frame: .zero)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var centerTraffic: NSLayoutConstraint!
    var leftTraffic: NSLayoutConstraint!
    var topTraffic: NSLayoutConstraint!
    var CYTraffic: NSLayoutConstraint!
    
    var lampCenter: NSLayoutConstraint!
    var lampRight: NSLayoutConstraint!
    var lampBottom: NSLayoutConstraint!
    var CYlamp: NSLayoutConstraint!
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(trafficBox)
        self.view.addSubview(lampView)
        
        lampView.layer.cornerRadius = 20
        
        let vs: [Light] = [redView, yellowView, greenView]
        for i in vs {
            self.view.addSubview(i)
            NSLayoutConstraint.activate([
                i.centerXAnchor.constraint(equalTo: trafficBox.centerXAnchor),
                i.widthAnchor.constraint(equalTo: trafficBox.widthAnchor, multiplier: 0.6),
                i.heightAnchor.constraint(equalTo: i.widthAnchor)
            ])
        }
        
        self.centerTraffic = trafficBox.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        self.leftTraffic = trafficBox.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        self.topTraffic =  trafficBox.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 2)
        self.CYTraffic = trafficBox.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)

        
        let lightpad: CGFloat = 10

        NSLayoutConstraint.activate([
            trafficBox.widthAnchor.constraint(equalToConstant: 80),
            trafficBox.heightAnchor.constraint(equalToConstant: 200),
            redView.topAnchor.constraint(equalTo: trafficBox.topAnchor, constant: lightpad),
            yellowView.centerYAnchor.constraint(equalTo: trafficBox.centerYAnchor),
            greenView.bottomAnchor.constraint(equalTo: trafficBox.bottomAnchor, constant: -lightpad),
            lampView.heightAnchor.constraint(equalToConstant: 60),
            lampView.widthAnchor.constraint(equalToConstant: 60),
        ])
        
        self.lampCenter = lampView.centerXAnchor.constraint(equalTo: trafficBox.centerXAnchor)
        self.lampRight = lampView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        self.lampBottom = lampView.topAnchor.constraint(equalTo: trafficBox.bottomAnchor, constant: 80)
        self.CYlamp = lampView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
        
        if UIDevice.current.orientation.isLandscape {
            NSLayoutConstraint.activate([self.leftTraffic, self.CYTraffic, self.lampRight, self.CYlamp])
        } else {
            NSLayoutConstraint.activate([self.centerTraffic, self.topTraffic, lampCenter, self.lampBottom])
        }

    }
    
    override func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        lampView.addGestureRecognizer(tap)
        
        let vs: [Light] = [redView, yellowView, greenView]
        for i in vs {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            i.addGestureRecognizer(tap)
        }
    }
    
    // listen for device rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            NSLayoutConstraint.deactivate([self.centerTraffic, self.lampCenter, self.lampBottom, self.topTraffic])
            NSLayoutConstraint.activate([self.leftTraffic, self.lampRight, self.CYlamp, self.CYTraffic])
        } else {
            NSLayoutConstraint.deactivate([self.leftTraffic, self.lampRight, self.CYlamp, self.CYTraffic])
            NSLayoutConstraint.activate([self.centerTraffic, self.lampCenter, self.lampBottom, self.topTraffic])
        }
    }
    
    func showFail() {
        if !self.failView.isDescendant(of: self.view){
            let symbolSize = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold, scale: .large)
            let ic = UIImage.init(systemName: "exclamationmark.triangle.fill", withConfiguration: symbolSize)?.withTintColor(.red, renderingMode: .alwaysOriginal)
            let iv = UIImageView(image: ic)
            self.failView.addSubview(iv)
            self.view.addSubview(self.failView)
            //self.failView.center = self.view.center // if not using constraints
            NSLayoutConstraint.activate([
                self.failView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.failView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            ])
        }
    }
    func hideFail() {
        self.failView.removeFromSuperview()
    }
    
    func spin() {
        if !self.spinner.isDescendant(of: self.view){
            self.view.addSubview(self.spinner)
            NSLayoutConstraint.activate([
                self.spinner.centerXAnchor.constraint(equalTo: self.trafficBox.centerXAnchor),
                self.spinner.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
                self.spinner.widthAnchor.constraint(equalTo: self.trafficBox.widthAnchor),
                self.spinner.heightAnchor.constraint(equalTo: self.spinner.widthAnchor),
            ])
        }
    }
    
    func stopspin() {
        self.spinner.removeFromSuperview()
    }
    
    func reloadState() {
        print("getting state")
        self.getState { state in
            if let state = state {
                self.handleState(state)
            }
        }
    }
    
    func getState(_ done: @escaping (TrafficState?) -> Void){
        print("getting state")
        self.spin()
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


