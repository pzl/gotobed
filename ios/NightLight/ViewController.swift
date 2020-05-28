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
        t.tableFooterView = UIView(frame: .zero)
        return t
    }()
    
    lazy var addTimerView: AddTimerView = {
        let v = AddTimerView(self.addTimerTap)
        v.frame.size.height = 50
        v.highlightColor = .systemGreen
        v.offColor = .systemBackground
        return v
    }()
    
    lazy var addTimerButton: UIImageView = {
        let b = UIImageView(image: .add)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = .systemGreen
        b.layer.cornerRadius = 100
        return b
    }()
    
    lazy var addTimerLabel: UILabel = {
        let l = UILabel(frame: .zero)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Add Timer"
        return l
    }()
    
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    lazy var hapSel = UISelectionFeedbackGenerator()
    lazy var hapNotif = UINotificationFeedbackGenerator()
    
    var settings: UIViewController?
    
    var timers: [TimedAction] = []
        
    override func loadView() {
        super.loadView()
        
        self.addTimerView.addSubview(addTimerButton)
        
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
        self.timertable.delegate = self
        self.timertable.allowsSelection = false
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\u{2699}\u{0000FE0E}", style: .plain, target: self, action: #selector(settingsTap))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Avenir Next", size: 27)!], for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didResume), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    @objc func didResume() {
        reloadData()
    }
    
    func setupTableView() {
        addTimerView.addSubview(addTimerButton)
        addTimerView.addSubview(addTimerLabel)
        view.addSubview(timertable)
        
        timertable.tableFooterView = addTimerView
        
        NSLayoutConstraint.activate([
            timertable.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -200),
            timertable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            timertable.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            timertable.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            addTimerButton.leadingAnchor.constraint(equalTo: addTimerView.leadingAnchor, constant: 20),
            addTimerButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            addTimerButton.heightAnchor.constraint(equalTo: addTimerButton.widthAnchor),
            addTimerButton.centerYAnchor.constraint(equalTo: addTimerView.centerYAnchor),
            addTimerLabel.centerYAnchor.constraint(equalTo: addTimerButton.centerYAnchor),
            addTimerLabel.leadingAnchor.constraint(equalTo: addTimerButton.trailingAnchor, constant: 12),
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
    
    @objc func addTimerTap() {
        print("adding Timer")
        let now = Date().timeIntervalSince1970
        let newTimer = TimedAction(withState: TrafficState(false, false, false, false), at: Int64(now))
        let editVC = TimerEditVC(timer: newTimer, onAccept: { setTimer in
            guard let host = UserDefaults.standard.string(forKey: "host") else {
                print("no host configured")
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Error", message: "unable to create timer, no Host configured", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
                return
            }
            LSCreateScheduled(host, setTimer) { response in
                guard let schedule = response else {
                    print("nil response")
                    DispatchQueue.main.async {
                        let ac = UIAlertController(title: "Error", message: "unable to create timer", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.timers = schedule
                    self.timertable.reloadData()
                }
            }
        })
        
        let navc = UINavigationController(rootViewController: editVC)
        present(navc, animated: true)
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
        
        if t.state.red {
            tcell.stateView.backgroundColor = .systemRed
        } else if t.state.yellow {
            tcell.stateView.backgroundColor = .systemYellow
        } else if t.state.green {
            tcell.stateView.backgroundColor = .systemGreen
        }
        return cell
    }
}

// MARK: - timer table actions
extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .destructive, title: "Remove") { (action, view, completionHandler) in
            guard let host = UserDefaults.standard.string(forKey: "host") else {
                print("no host configured")
                DispatchQueue.main.async {
                    completionHandler(false)
                    let ac = UIAlertController(title: "Error", message: "unable to Delete timer, no Host set", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
                return
            }
            let timer = self.timers[indexPath.row]
            guard let id = timer.id else {
                print("no id to delete")
                DispatchQueue.main.async {
                    completionHandler(false)
                    let ac = UIAlertController(title: "Error", message: "unable to delete timer, no ID", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
                return
            }
            LSDeleteSchedule(host, id: id) { schedule in
                if schedule == nil {
                    print("nil state returned after delete")
                    DispatchQueue.main.async {
                        completionHandler(false)
                        let ac = UIAlertController(title: "Error", message: "unable to delete timer", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                    return
                }
                // if API deletion success:
                DispatchQueue.main.async {
                    self.timers.remove(at: indexPath.row)
                    self.timertable.deleteRows(at: [indexPath], with: .automatic)
                    completionHandler(true)
                }
            }
        }

        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            let timer = self.timers[indexPath.row]
            let editVC = TimerEditVC(timer: timer, onAccept: { edited in
                guard let host = UserDefaults.standard.string(forKey: "host") else {
                    print("no host configured")
                    DispatchQueue.main.async {
                        completion(false)
                        let ac = UIAlertController(title: "Error", message: "unable to edit timer, no Host set", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                    return
                }
                LSUpdateScheduled(host, edited) { response in
                    guard let schedule = response else {
                        print("nil response")
                        DispatchQueue.main.async {
                            completion(false)
                            let ac = UIAlertController(title: "Error", message: "unable to edit timer", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(ac, animated: true)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.timers = schedule
                        self.timertable.reloadData()
                        completion(true)
                    }
                }
            })
            let navVC = UINavigationController(rootViewController: editVC)
            self.present(navVC, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [edit])
    }
}


class AddTimerView: UIControl {
    private var animator = UIViewPropertyAnimator()
    let done: () -> Void
    var offColor: UIColor = UIColor()
    var highlightColor: UIColor = UIColor()
    
    init(_ withDone: @escaping () -> Void) {
        self.done = withDone
        super.init(frame: .zero)
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
    }
    
    required init?(coder: NSCoder) {
        fatalError("coder: not implemented")
    }
    
    @objc private func touchDown() {
        animator.stopAnimation(true)
        backgroundColor = highlightColor
    }
    
    @objc private func touchUp() {
        animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
            self.backgroundColor = self.offColor
        })
        animator.startAnimation()
        done()
    }
}
