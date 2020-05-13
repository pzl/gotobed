//
//  SettingsViewC.swift
//  NightLight
//
//  Created by Dan on 5/8/20.
//  Copyright © 2020 Dan Panzarella. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    lazy var hostField: UITextField = {
        let t = UITextField(frame: .zero)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.placeholder = "Host"
        t.font = UIFont.systemFont(ofSize: 16)
        t.borderStyle = .roundedRect
        t.autocorrectionType = .no
        t.returnKeyType = .done
        t.text = UserDefaults.standard.string(forKey: "host")
        return t
    }()
    
    let picker = UIPickerView()
    lazy var pickerDoneBar: UIToolbar = {
        let t = UIToolbar()
        t.barStyle = .default
        t.isTranslucent = true
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.hostPickerDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.hostPickerCancel))
        t.setItems([cancel, space, done], animated: false)
        t.isUserInteractionEnabled = true
        return t
    }()
    let dataSource: [String] = ["http://stop.light", "http://192.168.1.168:8088"]

    override func loadView() {
        super.loadView()
        
        hostField.inputView = picker
        hostField.inputAccessoryView = pickerDoneBar
        //hostField.delegate = self
        view.addSubview(hostField)
        pickerDoneBar.sizeToFit()
        
        NSLayoutConstraint.activate([
            hostField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            hostField.heightAnchor.constraint(equalToConstant: 25),
            hostField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            hostField.widthAnchor.constraint(equalToConstant: 400)
        ])
        
        /*
        self.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            picker.heightAnchor.constraint(equalToConstant: 200),
            picker.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        */
        picker.delegate = self as UIPickerViewDelegate
        picker.dataSource = self as UIPickerViewDataSource
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        self.title = "Settings"
    }
    
    func changeHost(_ host: String) {
        print("setting host to \(host)")
        UserDefaults.standard.set(host, forKey: "host")
    }
    
    // MARK: picker view methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return dataSource.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return dataSource[row] }
    
    // selection callbacks
    @objc func hostPickerDone(){
        let row = self.picker.selectedRow(inComponent: 0)
        self.picker.selectRow(row, inComponent: 0, animated: false)
        self.hostField.text = dataSource[row]
        self.hostField.resignFirstResponder()
        changeHost(dataSource[row])
    }
    @objc func hostPickerCancel() {
        //@todo: select row of current host value
        self.hostField.resignFirstResponder()
    }
    
    
    
}
