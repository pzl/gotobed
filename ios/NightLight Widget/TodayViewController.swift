//
//  TodayViewController.swift
//  NightLight Widget
//
//  Created by Dan on 10/5/19.
//  Copyright © 2019 Dan Panzarella. All rights reserved.
//

import UIKit
import NotificationCenter
import LightServer

let hosts = ["http://stop.light", "http://192.168.1.168:8088"]

@objc class TodayViewController: UIViewController, NCWidgetProviding {
    
    lazy var redView = CircleLight(onColor: .systemRed, offColor: .trafficRed)
    lazy var yellowView = CircleLight(onColor: .systemYellow, offColor: .trafficYellow)
    lazy var greenView = CircleLight(onColor: .green, offColor: .trafficGreen)
    lazy var lampView = Light(onColor: .systemYellow, offColor: .systemGray)
    
    var host = hosts[0]
    
    override func loadView() {
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 150))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vs: [Light] = [redView, yellowView, greenView]
        for (i, l) in vs.enumerated() {
            self.view.addSubview(l)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            l.addGestureRecognizer(tap)
            
            l.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: CGFloat(i*100)).isActive = true
            l.widthAnchor.constraint(equalToConstant: 30).isActive = true
            l.heightAnchor.constraint(equalTo: l.widthAnchor).isActive = true
            l.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        }
        
        self.view.addSubview(lampView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        lampView.addGestureRecognizer(tap)
        
        lampView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -5).isActive = true
        lampView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        lampView.heightAnchor.constraint(equalTo: lampView.widthAnchor).isActive = true
        lampView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        
        
        // make expandable https://stfalcon.com/en/blog/post/today-extension-swift-4
        //extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        self.getState { state in
            if let state = state {
                self.handleState(state)
                completionHandler(.newData)
            } else {
                completionHandler(.failed)
            }
        }
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
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
        LSGetState(self.host, done)
    }
    
    func setState(_ state: TrafficState) {
        LSSetState(host: self.host, withState: state) { s in
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
