//
//  HomeCollectionViewController.swift
//  News
//
//  Created by Subhadeep Pal on 18/02/17.
//  Copyright © 2017 Subhadeep Pal. All rights reserved.
//

import UIKit



class HomeCollectionViewController: UICollectionViewController, ImageLoaderProtocol {
    
    private let reuseIdentifier = "homeCell"
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 30.0, right: 10.0)
    
    fileprivate var itemsPerRow: CGFloat = 3
    
    var keys : [String] = []
    var sourceDict = [String:[Source]]()
    var refreshControl = UIRefreshControl()
    
    var sourcesWebService : SourcesWebservice!

    @IBOutlet var activityIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        print(UIScreen.main.bounds.size.height)
        
        if(UIDevice.current.userInterfaceIdiom == .phone)
        {
            
            // 5.5 inch Screen
            if (UIScreen.main.bounds.size.height == 736.0)
            {
                itemsPerRow = 4.0
            }
            // 4.7 inch Screen
            else if (UIScreen.main.bounds.size.height == 667.0)
            {
                itemsPerRow = 3.0
            }
            else{
                itemsPerRow = 3.0
            }
        }
        else
        {
            itemsPerRow = 6.0
        }
    
        addRefreshControl()
    }
    
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = themeColor
        refreshControl.addTarget(self, action: #selector(HomeCollectionViewController.refreshTapped), for: UIControlEvents.valueChanged)
        self.collectionView?.addSubview(refreshControl)
        self.collectionView?.alwaysBounceVertical = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(sourceDict.keys.isEmpty){
            sourcesWebService = SourcesWebservice(identifier: "getSources", delegate: self)
            sourcesWebService.getSources()
            activityIndicatorView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(activityIndicatorView)
        }
        
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
        return sourceDict.keys.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        let key = keys[section]
        guard let numberOfItems = sourceDict[key]?.count  else {
            return 0
        }
        return numberOfItems
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeCollectionViewCell
    
        // Configure the cell
        var source: Source!
        
        let key = keys[indexPath.section]
        
        source = sourceDict[key]?[indexPath.item]
        
        
        cell.nameLabel.text = source.name
        
        if let image = ImageLoader.cache.object(forKey: source.urlsToLogos["medium"]! as AnyObject) as? Data{
            let cachedImage = UIImage(data: image)
            cell.iconImageView.image = cachedImage
        } else {
            let imageLoader = ImageLoader(delegate: self, indexPath: indexPath)
            imageLoader.imageFromUrl(urlString: source.urlsToLogos["medium"]!)
            cell.iconImageView.image = #imageLiteral(resourceName: "sample")
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let key = keys[indexPath.section]
        
        let source = sourceDict[key]?[indexPath.item]
        
        self.performSegue(withIdentifier: "sourceSelectedSegue", sender: source)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as! HeaderCollectionReusableView
        
        headerView.categoryTitleLabel.text = keys[indexPath.section].capitalized
        
        
        dropShadowOnVIew(view: headerView.backgroundView, size: 4, x: 0, y: 0, opacity: 0.1)
        return headerView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sourceSelectedSegue" {
            let destinationVC = segue.destination as! NewsCollectionViewController
            destinationVC.source = sender as? Source
        }
    }
    
    func imageLoaded(image: UIImage, forIndexPath indexPath: IndexPath) {
        collectionView?.reloadItems(at: [indexPath])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func dropShadowOnVIew(view: UIView, size: CGFloat, x: CGFloat, y: CGFloat, opacity: Float){
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: x, height: y)
        view.layer.shadowRadius = size
        view.layer.shadowOpacity = opacity
    }
    
    func refreshTapped(){
        sourcesWebService = SourcesWebservice(identifier: "refreshSources", delegate: self)
        sourcesWebService.getSources()
    }
}

extension HomeCollectionViewController: SourcesProtocol{
    
    func sourcesRetrieved(identifier: String, sources: [Source]) {
        sourceDict = createDictionaryForChannels(sources: sources)
        keys = Array<String>(sourceDict.keys)
        keys.sort(by: <)
        self.collectionView!.reloadData()
        
        if identifier == "refreshSources" {
            self.refreshControl.endRefreshing()
        } else {
            self.activityIndicatorView.removeFromSuperview()
        }
    }
    
    func createDictionaryForChannels (sources: [Source]) -> [String:[Source]] {
        
        var sourceDict = [String:[Source]]()
        for item in sources {
            if sourceDict.keys.contains(item.category){
                sourceDict[item.category]?.append(item)
            } else {
                sourceDict[item.category] = [item]
            }
        }
        return sourceDict
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
}

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = UIScreen.main.bounds.size.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}

