//
//  CityInfoViewController.swift
//  Faifly
//
//  Created by Max Surgai on 26.07.17.
//  Copyright © 2017 Max Surgai. All rights reserved.
//

import UIKit
import Alamofire

class CityInfoViewController: UIViewController {
    
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    var countryName: String!
    var cityName: String!
    let wikipediaSearchURL = "http://api.geonames.org/wikipediaSearchJSON"
    let wikipediaSearchUsername = "maxon4ug"
    var wikipediaArticleURL: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityImageView.layer.cornerRadius = 10
        cityImageView.clipsToBounds = true
        fetchCityInfo()
    }
    
    func fetchCityInfo() {
        Alamofire.request(wikipediaSearchURL, parameters: ["q":cityName,"username":wikipediaSearchUsername,"maxRows":"1"]).responseJSON(completionHandler: {
            (response) in
            guard let json = response.result.value as? [String:Array<[String:Any]>] else {
                print("Error: \(response.result.error?.localizedDescription ?? "Wrong casting")")
                return
            }
            if let thumbnailImgURL = json["geonames"]![0]["thumbnailImg"] as? String {
                Alamofire.request(thumbnailImgURL).responseData { response in
                    guard let data = response.result.value else { return }
                     let image = UIImage(data: data)
                    self.cityImageView.image = image
                }
            } else {
                self.cityImageView.image = #imageLiteral(resourceName: "nophoto")
            }
            self.cityNameLabel.text = self.cityName
            self.countryNameLabel.text = "Country: \(self.countryName!)"
            self.summaryTextView.text = json["geonames"]![0]["summary"] as! String
            self.wikipediaArticleURL = json["geonames"]![0]["wikipediaUrl"] as! String
        })
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        guard let url = URL(string: "https://\(wikipediaArticleURL!)") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
