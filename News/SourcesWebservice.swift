//
//  SourcesWebservice.swift
//  News
//
//  Created by Subhadeep Pal on 18/02/17.
//  Copyright © 2017 Subhadeep Pal. All rights reserved.
//

import UIKit

protocol SourcesProtocol {
    func sourcesRetrieved(identifier: String, sources: [Source])
    func errorInWebService(errorMessage: String, title: String)
}

class SourcesWebservice: NSObject {
    
    var delegate: SourcesProtocol
    var identifier: String
    
    init(identifier: String, delegate: SourcesProtocol) {
        self.delegate = delegate
        self.identifier = identifier
    }
    
    
    func getSources(){
        let config = URLSessionConfiguration.default // Session Configuration
        
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: "http://newsapi.org/v1/sources?language=en")!
        let request = NSMutableURLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                
                self.delegate.errorInWebService(errorMessage: "Error fetching data. Please check your internet connection and try again.", title: "Internet Connectivity")
                
            } else {
                
                do {
                    
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                    {
                        
                        //Implement your logic
                        if let status = json["status"] as? String{
                            if status == "ok"{
                                var sourcesArray : [Source] = []
                                
                                if let sources = json["sources"] as? [[String: Any]]{
                                    for item in sources{
                                        let id: String = item["id"] as! String
                                        let name: String = item["name"] as! String
                                        let desc: String = item ["description"] as! String
                                        let url: String = item ["url"] as! String
                                        let category: String = item["category"] as! String
                                        let language: String = item ["language"] as! String
                                        let country: String = item["country"] as! String
                                        
                                        let urlsToLogos: [String: String] = item["urlsToLogos"] as! [String: String]
                                        let sortBysAvailable: [String] = item["sortBysAvailable"] as! [String]
                                        
                                        let source = Source(id: id, name: name, desc: desc, url: url, category: category, language: language, country: country, urlsToLogos: urlsToLogos, sort: sortBysAvailable)
                                        
                                        sourcesArray.append(source)
                                    }
                                }
                                
                                DispatchQueue.main.async { [unowned self] in
                                    self.delegate.sourcesRetrieved(identifier: self.identifier, sources: sourcesArray)
                                }
                            }
                        }
                    }
                    
                } catch {
                    self.delegate.errorInWebService(errorMessage: "Our Services are updating. Please be patient.", title: "Server Down")
                }
            }
            
        })
        task.resume()
    }

}
