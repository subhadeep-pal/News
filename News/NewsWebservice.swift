//
//  NewsWebservice.swift
//  News
//
//  Created by Subhadeep Pal on 18/02/17.
//  Copyright © 2017 Subhadeep Pal. All rights reserved.
//

import UIKit

protocol NewsWebserviceProtocol {
    func newsRetrieved(identifier: String, news: [News])
    func errorInWebService(errorMessage: String, title: String)
}

class NewsWebservice: NSObject {

    var delegate: NewsWebserviceProtocol
    var identifier: String
    
    init(identifier: String, delegate: NewsWebserviceProtocol) {
        self.delegate = delegate
        self.identifier = identifier
    }
    
    
    func getNews(newsIdentifier: String, sortBy: String){
        let config = URLSessionConfiguration.default // Session Configuration
        
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: "http://newsapi.org/v1/articles?source=\(newsIdentifier)&sortBy=\(sortBy)&apiKey=38b335ae1dc54740ba4b01bd03996306")!
        let request = NSMutableURLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
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
                                var newsArray : [News] = []
                                
                                let articles = json["articles"] as! [[String:Any]]
                                
                                for item in articles {
                                    let author: String? = item["author"] as? String
                                    let title: String = item["title"] as! String
                                    let desc: String? = item["description"] as? String
                                    let url: String = item["url"] as! String
                                    let urlToImage: String? = item["urlToImage"] as? String
                                    let publishedAt: String? = item["publishedAt"] as? String
                                    
                                    let news = News(author: author, title: title, desc: desc, url: url, urlToImage: urlToImage, publishedAt: publishedAt)
                                    
                                    newsArray.append(news)
                                }
                                
                                DispatchQueue.main.async { [unowned self] in
                                    self.delegate.newsRetrieved(identifier: self.identifier, news: newsArray)
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
