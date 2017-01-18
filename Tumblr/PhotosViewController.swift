//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Huang Edison on 1/8/17.
//  Copyright © 2017 Edison. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var photoTableView: UITableView!
    var posts: [NSDictionary]?
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var rowsLoaded = 0
    var photosIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        photoTableView.dataSource = self
        photoTableView.delegate = self
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        photoTableView.insertSubview(refreshControl, at: 0)
        
        
        // add the infinite scroll indicator
        let frame = CGRect(x: 0, y: photoTableView.contentSize.height, width: photoTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        photoTableView.addSubview(loadingMoreView!)
        
        var insets = photoTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        photoTableView.contentInset = insets

        
        updatePhotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("tableview cell called")
        
        guard let posts = self.posts else{
            return 0
        }
        
        
//        if (rowsLoaded + 3 <= posts.count){
//            rowsLoaded += 3
//        } else {
//            rowsLoaded = posts.count
//        }
        
        //return posts.count
        //return rowsLoaded
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! photoCell
        self.photosIndexPath = indexPath
        
        let post = posts![indexPath.row]
        if let photos = post["photos"] as? [NSDictionary] {
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                cell.cellImage.setImageWith(imageUrl)
            }
        }
        
        
        return cell
    }
    
    func updatePhotos() {
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        //print("responseDictionary: \(responseDictionary)")
                        
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        
                        // This is where you will store the returned array of posts in your posts property
                        self.posts = responseFieldDictionary["posts"] as? [NSDictionary]
                        
                        self.isMoreDataLoading = false
                        
//                        if (self.rowsLoaded + 3 <= self.posts!.count){
//                            self.rowsLoaded += 3
//                        } else {
//                            self.rowsLoaded = self.posts!.count
//                        }
                        self.loadingMoreView?.stopAnimating()
                        
                        self.photoTableView.reloadData()


                    }
                }
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
       let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        let task : URLSessionDataTask =
            session.dataTask(
                with: request,
                completionHandler: { (dataOrNil, response, error) in
                    
                    // ... Use the new data to update the data source ...
                    if let data = dataOrNil {
                        if let responseDictionary = try! JSONSerialization.jsonObject(
                            with: data, options: []) as? NSDictionary {
                            
                            let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
 
                            self.posts = responseFieldDictionary["posts"] as? [NSDictionary]
                            
                            self.photoTableView.reloadData()
                            refreshControl.endRefreshing()
                            self.isMoreDataLoading = false

                        }
                    }
                    
            }
        )
        task.resume()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //print("content view height: ", photoTableView.contentSize.height)
        
        if( !isMoreDataLoading ) {
            
            let scrollViewContentHeight = photoTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - photoTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && photoTableView.isDragging) {
                isMoreDataLoading = true
                
                let frame = CGRect(x: 0, y: photoTableView.contentSize.height, width: photoTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                updatePhotos()
            }
            
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let photoCell = sender as! photoCell
        
        let indexCell = photoTableView.indexPath(for: photoCell)
        let post = posts![indexCell!.row]
        
        let photoDetailViewController = segue.destination as! PhotoDetailViewController
        
        photoDetailViewController.post = post
        
        photoTableView.deselectRow(at: indexCell!, animated: true)
    }
}



class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}
