//
//  Source.swift
//  News
//
//  Created by Subhadeep Pal on 18/02/17.
//  Copyright © 2017 Subhadeep Pal. All rights reserved.
//

import UIKit

class Source: NSObject {
    
    var id: String
    var name: String
    var desc: String
    var url: String
    var category: String
    var language: String
    var country: String
    var urlsToLogos: [String: String]
    var sortBysAvailable: [String]

    
    init(id: String, name: String, desc: String, url: String, category: String, language: String, country: String, urlsToLogos:[String:String], sort: [String]) {
        self.id = id
        self.name = name
        self.desc = desc
        self.url = url
        self.category = category
        self.language = language
        self.country = country
        self.urlsToLogos = urlsToLogos
        self.sortBysAvailable = sort
    }
    
}
