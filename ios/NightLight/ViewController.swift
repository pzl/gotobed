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
        ai.centerXAnchor.constraint(equalTo: s.centerXAnchor).isActive = true
        ai.centerYAnchor.constraint(equalTo: s.centerYAnchor).isActive = true
        ai.widthAnchor.constraint(equalTo: s.widthAnchor).isActive = true
        ai.heightAnchor.constraint(equalTo: s.heightAnchor).isActive = true
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
        self.centerTraffic.isActive = !UIDevice.current.orientation.isLandscape
        self.leftTraffic = trafficBox.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        self.leftTraffic.isActive = UIDevice.current.orientation.isLandscape

        self.topTraffic =  trafficBox.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 2)
        self.topTraffic.isActive = !UIDevice.current.orientation.isLandscape
        self.CYTraffic = trafficBox.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
        self.CYTraffic.isActive = UIDevice.current.orientation.isLandscape

        trafficBox.widthAnchor.constraint(equalToConstant: 80).isActive = true
        trafficBox.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let lightpad: CGFloat = 10
        redView.topAnchor.constraint(equalTo: trafficBox.topAnchor, constant: lightpad).isActive = true
        yellowView.centerYAnchor.constraint(equalTo: trafficBox.centerYAnchor).isActive = true
        greenView.bottomAnchor.constraint(equalTo: trafficBox.bottomAnchor, constant: -lightpad).isActive = true
        
        self.lampCenter = lampView.centerXAnchor.constraint(equalTo: trafficBox.centerXAnchor)
        self.lampCenter.isActive = !UIDevice.current.orientation.isLandscape
        self.lampRight = lampView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        self.lampRight.isActive = UIDevice.current.orientation.isLandscape
        
        self.lampBottom = lampView.topAnchor.constraint(equalTo: trafficBox.bottomAnchor, constant: 80)
        self.lampBottom.isActive = !UIDevice.current.orientation.isLandscape
        self.CYlamp = lampView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
        self.CYlamp.isActive = UIDevice.current.orientation.isLandscape
        
        lampView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        lampView.widthAnchor.constraint(equalToConstant: 60).isActive = true
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
            self.failView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.failView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        }
    }
    func hideFail() {
        self.failView.removeFromSuperview()
    }
    
    func spin() {
        if !self.spinner.isDescendant(of: self.view){
            self.view.addSubview(self.spinner)
            self.spinner.centerXAnchor.constraint(equalTo: self.trafficBox.centerXAnchor).isActive = true
            self.spinner.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
            self.spinner.widthAnchor.constraint(equalTo: self.trafficBox.widthAnchor).isActive = true
            self.spinner.heightAnchor.constraint(equalTo: self.spinner.widthAnchor).isActive = true
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


