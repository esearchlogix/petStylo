//
//  Section.swift
//  ExpendableTableView
//
//  Created by Alekh Verma on 08/06/18.
//  Copyright © 2018 Alekh Verma. All rights reserved.
//

import Foundation

struct Section{
    var category : String?
    var subCategory : [String]?
    var Ids : [Int]?
    var expended :  Bool?
    
    init(category: String, subCategory : [String], id: [Int], expended : Bool) {
        self.category = category
        self.subCategory = subCategory
        self.Ids = id
        self.expended = expended
    }
}
