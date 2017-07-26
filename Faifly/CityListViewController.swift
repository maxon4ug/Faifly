//
//  ViewController.swift
//  Faifly
//
//  Created by Max Surgai on 26.07.17.
//  Copyright © 2017 Max Surgai. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class CityListViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var cityListTableView: UITableView!
    @IBOutlet weak var countryPickerTextField : UITextField!
    let countryPickerView = UIPickerView()
    //    let countries = List<Country>()
    let dataLink = "https://raw.githubusercontent.com/David-Haim/CountriesToCitiesJSON/master/countriesToCities.json"
    let realm = try! Realm()
    lazy var countries: Results<Country> = { self.realm.objects(Country) }()
    var selectedCountryNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityListTableView.tableFooterView = UIView(frame: CGRect.zero)
        fetchData()
        countryPickerSetup()
    }
    
    func fetchData() {
        if countries.count == 0 {
            try! realm.beginWrite()
            Alamofire.request(dataLink).responseJSON(completionHandler: { response in
                guard let json = response.result.value as? [String:[String]] else {
                    print("Error: \(response.result.error)")
                    return
                }
                for (country,cities) in json {
                    let newCountry = Country()
                    newCountry.name = country
                    //                let newCities = List<City>()
                    for city in cities {
                        let newCity = City()
                        newCity.name = city
                        newCountry.cities.append(newCity)
                        //                    newCities.append(newCity)
                    }
                    //                self.countries.append(newCountry)
                    self.realm.add(newCountry)
                }
            })
            countries = realm.objects(Country)
        }
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
        selectedCountryNumber = countryPickerView.selectedRow(inComponent: 0)
        countryPickerTextField.endEditing(true)
        cityListTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedCountryNumber != nil {
            return countries[selectedCountryNumber!].cities.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityTableViewCell
        cell.cityNameLabel.text = countries[selectedCountryNumber!].cities[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
