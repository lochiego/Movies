//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Eric Gonzalez on 1/23/16.
//  Copyright © 2016 Eric Gonzalez. All rights reserved.
//

import UIKit
import AFNetworking

let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"

let urlString = "https://api.themoviedb.org/3/movie/"

var session: NSURLSession!

class MoviesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let nowPlayingUrl = NSURL(string: "\(urlString)now_playing?api_key=\(apiKey)")

    @IBOutlet weak var collectionView: UICollectionView!
    var movies: [NSDictionary]?
    
    var alert: UIAlertController!
    var refresh: UIRefreshControl!
    
    var firstLaunch = true
    
    @IBOutlet weak var layoutToggle: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: Selector("refreshData"), forControlEvents: .ValueChanged)
        collectionView.addSubview(refresh)
        collectionView.alwaysBounceVertical = true
        
        layoutToggle.clipsToBounds = true
        layoutToggle.layer.cornerRadius = 22
        
        self.pollMovieData({
            self.dismissViewControllerAnimated(true, completion: nil)
            self.firstLaunch = false
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        if firstLaunch {
            alert = UIAlertController(title: nil, message: "Getting movie data...", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData()
    {
        pollMovieData({
            self.refresh.endRefreshing()
        })
    }
    
    func pollMovieData(completion:(()->())?)
    {
        let request = NSURLRequest(
            URL: nowPlayingUrl!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let completion = completion {
                    completion()
                }
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
//                            print("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.collectionView.reloadData()
                    }
                }
                else {
                    let alert = UIAlertController(title: "Warning", message: "You're out of range. Get to the Internet and try again.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Hunt", style: .Default, handler: { (_) -> Void in
                        self.pollMovieData(nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Give Up", style: .Destructive, handler: { (_) -> Void in
                        exit(1)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
        task.resume()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if let movies = movies {
            return movies.count
        }
        return 0
    }
    
    let gridSize = CGSize(width: 150, height: 225)
    let tableSize = CGSize(width: 320, height: 180)
    var tableLayout: Bool = false
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return tableLayout ? tableSize : gridSize
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let rating = movie["vote_average"] as! Double
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.ratingLabel.text = rating > 0 ? "\(rating)" : "N/A"
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        else {
            cell.posterView.image = nil
        }
        
        return cell
    }
    
    @IBAction func toggleLayout(sender: AnyObject) {
        tableLayout = !tableLayout
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        let detailsController = segue.destinationViewController as! MovieDetailsViewController

        // Pass the selected object to the new view controller.
        let index = collectionView.indexPathsForSelectedItems()?.first!
        let movie = movies![index!.item]
        detailsController.movie = movie
        detailsController.poster = (collectionView.cellForItemAtIndexPath(index!) as! MovieCell).posterView.image
    }
}
