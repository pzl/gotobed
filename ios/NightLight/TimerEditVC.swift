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
    let isNew: Bool
    var hasEdited: Bool = false {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    var onAccept: ((TimedAction) -> Void)?
    
    let idLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "Verdana-Bold", size: 16)
        l.textColor = .systemGray
        return l
    }()
    var lastTime: Date
    let datePicker = UIDatePicker()
    let pickerDoneBar: UIToolbar = {
        let t = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        t.barStyle = .default
        t.isTranslucent = true
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(datePickerDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(datePickerCancel))
        t.setItems([cancel, space, done], animated: false)
        t.isUserInteractionEnabled = true
        return t
    }()
    let timeField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    lazy var trafficBox: UIView = {
        let t = UIView(frame: .zero)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = .trafficLight
        t.layer.cornerRadius = 10
        return t
    }()
    
    let fmt: DateFormatter = {
        let d = DateFormatter()
        d.timeStyle = .short
        d.dateStyle = .medium
        d.timeZone = .current
        return d
    }()
    let Red = CircleLight(onColor: .systemRed, offColor: .trafficRed)
    let Yellow = CircleLight(onColor: .systemYellow, offColor: .trafficYellow)
    let Green = CircleLight(onColor: .green, offColor: .trafficGreen)
    let Lamp = Light(onColor: .systemYellow, offColor: .systemGray)
    
    
    init(timer: TimedAction) {
        self.timer = timer
        self.lastTime = Date(timeIntervalSince1970: Double(timer.time))
        self.isNew = timer.id == nil
        super.init(nibName: nil, bundle: nil)
    }
    convenience init(timer: TimedAction, onAccept: @escaping (TimedAction) -> Void) {
        self.init(timer: timer)
        self.onAccept = onAccept
    }
    
    required init?(coder: NSCoder) {
        fatalError("no init(coder:) implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        self.isModalInPresentation = true
        navigationController?.presentationController?.delegate = self
        
        view.addSubview(timeField)
        view.addSubview(idLabel)
        view.addSubview(trafficBox)
        view.addSubview(Red)
        view.addSubview(Yellow)
        view.addSubview(Green)
        view.addSubview(Lamp)
        timeField.inputView = datePicker
        timeField.inputAccessoryView = pickerDoneBar
        pickerDoneBar.sizeToFit()
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        Lamp.layer.cornerRadius = 20
        
        NSLayoutConstraint.activate([
            idLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            idLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeField.leadingAnchor.constraint(equalTo: idLabel.leadingAnchor),
            timeField.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 20),
            trafficBox.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            trafficBox.widthAnchor.constraint(equalToConstant: 80),
            trafficBox.heightAnchor.constraint(equalToConstant: 200),
            trafficBox.topAnchor.constraint(equalTo: timeField.bottomAnchor, constant: 20),
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
        self.view.backgroundColor = .systemBackground
        
        let confirmString = isNew ? "Create" : "Save"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.navCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: confirmString, style: .done, target: self, action: #selector(self.complete))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let tappables: [Light] = [Red, Yellow, Green, Lamp]
        for i in tappables {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.stateTapped(_:)))
            i.addGestureRecognizer(tap)
        }
        
        
        
        let initDate = Date(timeIntervalSince1970: Double(timer.time))
        timeField.text = fmt.string(from: initDate)
        datePicker.date = initDate
        
        if let id = timer.id {
            idLabel.text = "ID: " + id
        } else {
            idLabel.isHidden = true
        }
        
        self.Red.on = self.timer.state.red
        self.Yellow.on = self.timer.state.yellow
        self.Green.on = self.timer.state.green
        self.Lamp.on = self.timer.state.lamp
        
        self.timeField.becomeFirstResponder()
    }
    
    // MARK: - sheet action responders
    @objc func navCancel() {
        self.dismiss(animated: true)
    }
    
    @objc func complete() {
        if let done = self.onAccept {
            var t = TimedAction(withState: TrafficState(Red.on, Yellow.on, Green.on, Lamp.on), at: Int64(datePicker.date.timeIntervalSince1970))
            if self.timer.id != nil {
                t.id = self.timer.id
            }
            done(t)
        }
        self.dismiss(animated: true)
    }
    
    // MARK: - Date Picker responders
    @objc func datePickerDone() {
        print("picker done")
        lastTime = datePicker.date
        timeField.text = fmt.string(from: datePicker.date)
        timeField.resignFirstResponder()
    }
    
    @objc func datePickerCancel() {
        print("canceled")
        timeField.resignFirstResponder() // close date keyboard
        timeField.text = fmt.string(from: lastTime)
    }
    
    @objc func datePickerChanged() {
        print("on change")
        self.hasEdited = true
        timeField.text = fmt.string(from: datePicker.date)
    }
    
    // MARK: - light tap responder
    @objc func stateTapped(_ sender: UITapGestureRecognizer? = nil) {
        guard let s = sender else {
            print("nil tap")
            return
        }
        guard s.view != nil else {
            print("nil tap view")
            return
        }
        
        self.hasEdited = true
        switch s.view {
        case Red:
            Red.on = true
            Yellow.on = false
            Green.on = false
        case Yellow:
            Red.on = false
            Yellow.on = true
            Green.on = false
        case Green:
            Red.on = false
            Yellow.on = false
            Green.on = true
        case Lamp: Lamp.on = !Lamp.on
        default:
            print("unknown view tapped: \(s.view!)")
        }
    }
}

extension TimerEditVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        print("dismiss attempt")
        timeField.resignFirstResponder()
        if !self.hasEdited {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let a = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let confirmString = self.isNew ? "Create" : "Save"
        
        a.addAction(UIAlertAction(title: confirmString, style: .default, handler: { action in
            self.complete()
        }))
        a.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: { action in
            self.dismiss(animated: true)
        }))
        a.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        self.present(a, animated: true)
    }
    
}
