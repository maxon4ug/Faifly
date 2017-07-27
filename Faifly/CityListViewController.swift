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
import SystemConfiguration

class CityListViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var cityListTableView: UITableView!
    @IBOutlet weak var countryPickerTextField : UITextField!
    @IBOutlet weak var loadingView: UIView!
    let countryPickerView = UIPickerView()
    let dataURL = "https://raw.githubusercontent.com/David-Haim/CountriesToCitiesJSON/master/countriesToCities.json"
    let realm = try! Realm()
    lazy var countries: Results<Country> = { self.realm.objects(Country.self) }()
    var selectedCountryNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityListTableView.tableFooterView = UIView(frame: CGRect.zero)
        fetchData()
        countryPickerSetup()
    }
    
    func fetchData() {
        guard countries.count == 0 else { return }
        if isInternetAvailable() == true {
            loadingView.isHidden = false
            Alamofire.request(dataURL).responseJSON(completionHandler: { response in
                guard let json = response.result.value as? [String:[String]] else {
                    print("Error: \(response.result.error?.localizedDescription ?? "Wrong casting")")
                    return
                }
                for (country,cities) in json {
                    guard country != "" else { continue }
                    let newCountry = Country()
                    newCountry.name = country
                    for city in cities {
                        guard city != "" else { continue }
                        let newCity = City()
                        newCity.name = city
                        newCountry.cities.append(newCity)
                    }
                    try! self.realm.write {
                        self.realm.add(newCountry)
                    }
                }
            })
            countries = realm.objects(Country.self)
            loadingView.isHidden = true
        } else {
            countryPickerTextField.isEnabled = false
            countryPickerTextField.text = "No internet connection!"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCityInfoSegue" {
            let destinationVC = segue.destination as! CityInfoViewController
            if let cityCell = (sender as? CityTableViewCell) {
                destinationVC.cityName = cityCell.cityNameLabel.text
                destinationVC.countryName = countryPickerTextField.text!
                destinationVC.navigationItem.title = "\(cityCell.cityNameLabel.text!) Info"
            }
        }
    }
}
