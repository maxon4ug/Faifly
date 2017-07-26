//
//  ViewController.swift
//  Faifly
//
//  Created by Max Surgai on 26.07.17.
//  Copyright © 2017 Max Surgai. All rights reserved.
//

import UIKit
import RealmSwift

class CityListViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var countryPickerTextField : UITextField!
    let countryPickerView = UIPickerView()
    let countries = List<Country>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryPickerSetup()
    }
    
    func countryPickerSetup() {
        countryPickerView.delegate = self
        let countryPickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        countryPickerToolbar.setItems([cancelButton, flex, doneButton], animated: false)
        countryPickerTextField.inputView = countryPickerView
        countryPickerTextField.inputAccessoryView = countryPickerToolbar
    }
    
    func doneButtonTapped() {
        countryPickerTextField.text = countries[countryPickerView.selectedRow(inComponent: 0)].name
        countryPickerTextField.endEditing(true)
    }
    
    func cancelButtonTapped() {
        countryPickerTextField.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row].name
    }
}

