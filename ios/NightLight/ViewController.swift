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
    
    lazy var timertable: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    lazy var hapSel = UISelectionFeedbackGenerator()
    lazy var hapNotif = UINotificationFeedbackGenerator()
    
    var settings: UIViewController?
    
    var timers: [TimedAction] = []
        
    override func loadView() {
        super.loadView()
        self.view.addSubview(trafficBox)
        self.view.addSubview(lampView)
        self.setupTableView()
        
        self.settings = SettingsVC()
        
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
        
        self.portraitConstraints = [
            trafficBox.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor), // center the traffic light horizontally
            trafficBox.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50), //traffic box near top
            lampView.centerXAnchor.constraint(equalTo: trafficBox.centerXAnchor), // center the lamp horizontally
            lampView.topAnchor.constraint(equalTo: trafficBox.bottomAnchor, constant: 80), // lamp falls below traffic light
        ]
        
        self.landscapeConstraints = [
            trafficBox.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20), // left-align the traffic light
            trafficBox.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor), //traffic light centered vertically
            lampView.leadingAnchor.constraint(equalTo: self.trafficBox.trailingAnchor, constant: 80), // to the right of traffic
            lampView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor), // center lamp vertically
        ]
        
        
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
        
        NSLayoutConstraint.deactivate(self.landscapeConstraints + self.portraitConstraints)
        if UIDevice.current.orientation.isLandscape {
            NSLayoutConstraint.activate(self.landscapeConstraints)
        } else {
            NSLayoutConstraint.activate(self.portraitConstraints)
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
        self.timertable.dataSource = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\u{2699}\u{0000FE0E}", style: .plain, target: self, action: #selector(settingsTap))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 27)!], for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func setupTableView() {
        view.addSubview(timertable)
        
        NSLayoutConstraint.activate([
            timertable.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -200),
            timertable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            timertable.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            timertable.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        timertable.register(TimerCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: rotation support
    
    // enable rotation support explicitly
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    // listen for device rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            NSLayoutConstraint.deactivate(self.portraitConstraints)
            NSLayoutConstraint.activate(self.landscapeConstraints)
        } else {
            NSLayoutConstraint.deactivate(self.landscapeConstraints)
            NSLayoutConstraint.activate(self.portraitConstraints)
        }
    }
    
    // MARK: UI fail/sping state
    
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
    
    // MARK: state functions
    
    func reloadData() {
        self.spin()
        print("getting state")
        self.getState { state in
            DispatchQueue.main.async { [weak self] in
                self?.stopspin()
                self?.hideFail()
            }
            if let state = state {
                self.handleState(state)
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.showFail()
                }
            }
        }
        print("getting schedule")
        self.getSchedule { schedule in
            DispatchQueue.main.async { [weak self] in
                self?.stopspin()
                self?.hideFail()
            }
            if let s = schedule {
                self.handleSchedule(s)
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.showFail()
                }
                print("nil schedule")
            }
        }
    }
    
    func getSchedule(_ done: @escaping ([TimedAction]?) -> Void) {
        guard let host = UserDefaults.standard.string(forKey: "host") else {
            print("no host configured")
            return
        }
        print("getting schedule")
        LSGetSchedule(host, done)
    }
    
    func getState(_ done: @escaping (TrafficState?) -> Void){
        guard let host = UserDefaults.standard.string(forKey: "host") else {
            print("no host configured")
            return
        }
        print("getting state")
        LSGetState(host, done)
    }
    
    func setState(_ state: TrafficState) {
        guard let host = UserDefaults.standard.string(forKey: "host") else {
            print("no host configured")
            return
        }
        LSSetState(host: host, withState: state) { s in
            if let s = s {
                self.handleState(s)
            } else {
                self.hapNotif.notificationOccurred(.error)
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
    
    func handleSchedule(_ schedule: [TimedAction]) {
        self.timers = schedule
        DispatchQueue.main.async { [weak self] in
            self?.timertable.reloadData()
            if self?.timers.count == 0 {
                self?.timertable.isHidden = true
            } else {
                self?.timertable.isHidden = false
            }
        }
    }
    
    // MARK: interaction handlers
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let s = sender else {
            print("tap: nil sender")
            return
        }
        guard s.view != nil else {
            print("tap: nil view")
            return
        }
        
        self.hapSel.selectionChanged()
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
    
    @objc func settingsTap() {
        // push nav
        //self.navigationController!.present(settings!, animated: true)
        self.navigationController?.pushViewController(settings!, animated: true)
    }
    
}

// timer table stuff
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let t = self.timers[indexPath.row]
        // set cell properties here based on t
    
        guard let tcell = cell as? TimerCell else {
            return cell // send up a default cell
        }
       
        let date = Date(timeIntervalSince1970: Double(t.time))
        let df = DateFormatter()
        df.timeStyle = .medium
        df.dateStyle = .medium
        df.timeZone = .current
        tcell.timeLabel.text = df.string(from: date)
        return cell
    }
}
