//
//  NewsCollectionViewController.swift
//  News
//
//  Created by Subhadeep Pal on 18/02/17.
//  Copyright © 2017 Subhadeep Pal. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

private let reuseIdentifier = "newsCell"

class NewsCollectionViewController: UICollectionViewController, NewsWebserviceProtocol, ImageLoaderProtocol {

    var newsArray : [News] = []
    
    var source: Source?
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 20.0, right: 0.0)
    
    fileprivate let itemsPerRow: CGFloat = 1
    
    var newsWebservice : NewsWebservice!
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet var activityIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        newsWebservice = NewsWebservice(identifier: "newsWebservice", delegate: self)
        addRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let source = source {
            self.title = source.name
            newsWebservice.getNews(newsIdentifier: source.id, sortBy: source.sortBysAvailable.first!)
            activityIndicatorView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(activityIndicatorView)
        }
        
    }

    
    func addRefreshControl() {
        refreshControl.tintColor = themeColor
        refreshControl.addTarget(self, action: #selector(NewsCollectionViewController.refreshTapped), for: UIControlEvents.valueChanged)
        self.collectionView?.addSubview(refreshControl)
        self.collectionView?.alwaysBounceVertical = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return newsArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NewsCollectionViewCell
    
        let news = newsArray[indexPath.row]
        
        cell.titleLabel.text = news.title
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            cell.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: 1.5)
        }
        
        cell.contentView.clipsToBounds = true
        
        cell.newsImage.alpha = 1
        
        if let urlToImage = news.urlToImage{
            
            if let image = ImageLoader.cache.object(forKey: urlToImage as AnyObject) as? Data{
                let cachedImage = UIImage(data: image)
                cell.newsImage.image = cachedImage
            } else {
                let imageLoader = ImageLoader(delegate: self, indexPath: indexPath)
                imageLoader.imageFromUrl(urlString: urlToImage)
                cell.newsImage.alpha = 0
            }
        }
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if #available(iOS 9.0, *) {
            let safariVC = SFSafariViewController(url: URL(string: newsArray[indexPath.row].url)!)
            safariVC.title = newsArray[indexPath.row].title
            
            self.present(safariVC, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: newsArray[indexPath.row].url)!)
        }
    }
    
    func newsRetrieved(identifier: String, news: [News]) {
        self.newsArray = news
        collectionView?.reloadData()
        
        if identifier == "refreshNews" {
            refreshControl.endRefreshing()
        } else {
            self.activityIndicatorView.removeFromSuperview()
        }
    }
    
    func errorInWebService(errorMessage: String, title: String) {
        showErrorAlert(message: errorMessage, title: title)
        activityIndicatorView.removeFromSuperview()
    }
    
    func showErrorAlert(message: String, title: String){
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alertView.addAction(alertAction)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    func imageLoaded(image: UIImage, forIndexPath indexPath: IndexPath) {
        collectionView?.reloadItems(at: [indexPath])
    }

    func refreshTapped(){
        guard let source = self.source else {
            return
        }
        newsWebservice = NewsWebservice(identifier: "refreshNews", delegate: self)
        newsWebservice.getNews(newsIdentifier: source.id, sortBy: source.sortBysAvailable.first!)
    }
}

extension NewsCollectionViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            return CGSize(width: widthPerItem, height: 200)
        } else {
            return CGSize(width: widthPerItem, height: 400)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
}
