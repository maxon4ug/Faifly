//
//  CountryPickerView.swift
//  Faifly
//
//  Created by Max Surgai on 26.07.17.
//  Copyright © 2017 Max Surgai. All rights reserved.
//

import UIKit

class CountryPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var pickerData : [String]!
    var pickerTextField : UITextField!
    var selectionHandler : ((_ selectedText: String) -> Void)?
    
    init(pickerData: [String], dropdownField: UITextField) {
        super.init(frame: CGRect.zero)
        
        self.pickerData = pickerData
        self.pickerTextField = dropdownField
        
        self.delegate = self
        self.dataSource = self
        
        DispatchQueue.main.async(execute: {
            if pickerData.count > 0 {
                self.pickerTextField.text = self.pickerData[0]
                self.pickerTextField.isEnabled = true
            } else {
                self.pickerTextField.text = nil
                self.pickerTextField.isEnabled = false
            }
        })
        
        if self.pickerTextField.text != nil && self.selectionHandler != nil {
            selectionHandler!(self.pickerTextField.text!)
        }
    }
    
    convenience init(pickerData: [String], dropdownField: UITextField, onSelect selectionHandler: @escaping (_ selectedText: String) -> Void) {
        self.init(pickerData: pickerData, dropdownField: dropdownField)
        self.selectionHandler = selectionHandler
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
    }
}
