//
//  Country.swift
//  Faifly
//
//  Created by Max Surgai on 26.07.17.
//  Copyright © 2017 Max Surgai. All rights reserved.
//

import Foundation
import RealmSwift

class Country: Object {
    
    dynamic var name = ""
    let cities = List<City>()
}
