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
let baseUrl = "https://api.themoviedb.org/3/movie/"

var session: NSURLSession!

class MoviesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  var endpoint: String!
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var sortButton: UIBarButtonItem!
  
  var movies: [NSDictionary]?
  
  var alert: UIAlertController!
  var refresh: UIRefreshControl!
  
  var firstLaunch = true
  
  var activeComparer = releaseCompare
  
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
    layoutToggle.layer.backgroundColor = UIColor.whiteColor().CGColor
    
    self.pollMovieData({
      self.dismissViewControllerAnimated(true, completion: nil)
      self.firstLaunch = false
    })
    
    let width = collectionView.frame.width / 2
    gridSize = CGSize(width: width, height: width * 1.5)
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
  
  @IBAction func displayFilter()
  {
    let alert = UIAlertController(title: nil, message: "Sort by", preferredStyle: .ActionSheet)
    alert.addAction(UIAlertAction(title: "Release Date", style: .Default, handler: { (_) -> Void in
      if self.movies != nil {
        self.activeComparer = releaseCompare
        self.movies!.sortInPlace(self.activeComparer)
        self.collectionView.reloadData()
      }
    }))
    alert.addAction(UIAlertAction(title: "Rating", style: .Default, handler: { (_) -> Void in
      if self.movies != nil {
        self.activeComparer = ratingCompare
        self.movies!.sortInPlace(self.activeComparer)
        self.collectionView.reloadData()
      }
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  
  func pollMovieData(completion:(()->())?)
  {
    let request = NSURLRequest(
      URL: NSURL(string: "\(baseUrl)\(endpoint)?api_key=\(apiKey)")!,
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
                                          print(responseDictionary)
              self.movies = (responseDictionary["results"] as? [NSDictionary])?.sort(self.activeComparer)
              self.collectionView.reloadData()
          }
        }
        else {
          let alert = UIAlertController(title: "Warning", message: "You're out of range. Get to the Internet and try again.", preferredStyle: .Alert)
          alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (_) -> Void in
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
  
  var gridSize: CGSize!
  let tableSize = CGSize(width: 320, height: 180)
  var tableLayout: Bool = false

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return tableLayout ? tableSize : gridSize
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let movie = movies![indexPath.row]
    let rating = movie["vote_average"] as! Double
    
    var cell: MovieCell!
    if tableLayout {
      cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieTableCell", forIndexPath: indexPath) as! MovieCell
      
      let title = movie["title"] as! String
      let overview = movie["overview"] as! String
      
      cell.titleLabel.text = title
      cell.overviewLabel.text = overview
      cell.ratingLabel.text = rating > 0 ? "\(rating)" : "N/A"
    }
    else {
      cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieGridCell", forIndexPath: indexPath) as! MovieCell
    }
    
    let view = UIView(frame: cell.frame)
    view.backgroundColor = UIColor ( red: 0.502, green: 0.502, blue: 0.0, alpha: 1.0 )
    cell.selectedBackgroundView = view
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    if let posterPath = movie["poster_path"] as? String {
      let imageUrl = NSURL(string: baseUrl + posterPath)
      let request = NSURLRequest(URL: imageUrl!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30)
      cell.posterView.setImageWithURLRequest(request, placeholderImage: nil, success: { (_, _, image) -> Void in
        cell.posterView.alpha = 0
        cell.posterView.image = image
        UIView.animateWithDuration(0.4, animations: { () -> Void in
          cell.posterView.alpha = 1
        })
        }, failure: { (_, _, _) -> Void in
          cell.posterView.image = nil
      })
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
    self.collectionView.reloadData()
    
    self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Top, animated: true)
    
    let newImage = UIImage(named: tableLayout ? "GridButton" : "TableButton")
    layoutToggle.setImage(newImage, forState: .Normal)
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    
    // Pass the selected object to the new view
    let cell = sender as! MovieCell
    let index = collectionView.indexPathForCell(cell)
    let movie = movies![index!.item]
    
    let detailsController = segue.destinationViewController as! MovieDetailsViewController
    detailsController.movie = movie
    detailsController.poster = cell.posterView.image
  }
}

func releaseDateFormatter() -> NSDateFormatter {
  let formatter = NSDateFormatter()
  formatter.dateFormat = "yyyy-MM-dd"
  return formatter
}

let releaseFormatter = releaseDateFormatter()

private func releaseCompare(movie1: NSDictionary, movie2: NSDictionary) -> Bool {
  let date1 = releaseFormatter.dateFromString(movie1["release_date"] as! String)
  let date2 = releaseFormatter.dateFromString(movie2["release_date"] as! String)
  return date1!.timeIntervalSince1970 > date2!.timeIntervalSince1970
}

private func ratingCompare(movie1: NSDictionary, movie2: NSDictionary) -> Bool {
  let rating1 = movie1["vote_average"] as! Double
  let rating2 = movie2["vote_average"] as! Double
  return rating1 > rating2
}
