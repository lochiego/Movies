//
//  MovieDetailsViewController.swift
//  MovieViewer
//
//  Created by Eric Gonzalez on 1/28/16.
//  Copyright © 2016 Eric Gonzalez. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
  
  @IBOutlet weak var backdropReflectionView: UIImageView!
  @IBOutlet weak var backdropView: UIImageView!
  @IBOutlet weak var posterView: UIImageView!
  @IBOutlet weak var averageLabel: UILabel!
  @IBOutlet weak var countLabel: UILabel!
  @IBOutlet weak var releaseLabel: UILabel!
  @IBOutlet weak var runtimeLabel: UILabel!
  @IBOutlet weak var castLabel: UILabel!
  @IBOutlet weak var overviewTitleLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  var movie: NSDictionary!
  var movieAltData: NSDictionary?
  var poster: UIImage?
  var credits: [NSDictionary]?
  
  let printFormatter = printedFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.title = movie["title"] as? String
    let average = movie["vote_average"] as? Double
    let count = movie["vote_count"] as? Int
    let overview = movie["overview"] as? String
    let releaseDate = releaseFormatter.dateFromString(movie["release_date"] as! String)!
    
    if let average = average {
      averageLabel.text = "\(average)"
    }
    else {
      averageLabel.text = "N/A"
    }
    if let count = count {
      countLabel.text = "\(count) Votes"
    }
    else {
      countLabel.text = nil
    }
    if let overview = overview {
      overviewLabel.text = overview
    }
    else {
      overviewLabel.text = "Synopsis not available"
    }
    overviewLabel.sizeToFit()
    
    releaseLabel.text = printFormatter.stringFromDate(releaseDate)
    
    posterView.image = poster
    posterView.layer.borderColor = UIColor.blackColor().CGColor
    posterView.layer.borderWidth = 1
    posterView.clipsToBounds = true
    
    // Set up mirror effect
    var transform = backdropReflectionView.layer.transform
    transform = CATransform3DScale(transform, 1, -1, 1)
    backdropReflectionView.layer.transform = transform

    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = backdropReflectionView.bounds;
    gradientLayer.colors = [UIColor(white: 0, alpha: 0).CGColor, UIColor(white: 0, alpha: 1).CGColor]
    gradientLayer.startPoint = CGPoint(x: 0, y: 1)
    gradientLayer.endPoint = CGPoint(x: 0, y: 0)
    
    backdropReflectionView.layer.mask = gradientLayer
    
    loadMovieInfo()
    loadCreditsInfo()
  }
  
  func sizeForContent() -> CGSize
  {
    var contentRect = CGRectZero
    for view in scrollView.subviews {
      contentRect = CGRectUnion(contentRect, view.frame);
    }
    contentRect.size.height += 20 // Padding for synopsis
    return contentRect.size
  }
  
  func fillMovieAltData()
  {
    let runtime = movieAltData!["runtime"] as! Int
    runtimeLabel.text = "\(runtime) min"
    
    if let backgroundPath = movieAltData!["backdrop_path"] as? String {
      let imageUrl = NSURL(string: "http://image.tmdb.org/t/p/w640" + backgroundPath)
      
      let request = NSURLRequest(URL: imageUrl!)
      backdropView.setImageWithURLRequest(request, placeholderImage: nil, success: { (request, response, image) -> Void in
        self.backdropView.alpha = 0
        self.backdropReflectionView.alpha = 0
        
        self.backdropView.image = image
        self.backdropReflectionView.image = image
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
          self.backdropView.alpha = 1
          self.backdropReflectionView.alpha = 1
          }, completion: { (success) in
            let highResUrl = NSURL(string: "http://image.tmdb.org/t/p/w640" + backgroundPath)
            self.backdropView.setImageWithURL(highResUrl!)
        })
        }, failure: nil)
    }
  }
  
  func fillCreditsData()
  {
    var creditString = String()
    if let credits = credits {
      for role in credits {
        creditString += role["name"]! as! String + ", "
      }
      creditString = creditString.substringToIndex(creditString.endIndex.predecessor().predecessor())
    }
    
    castLabel.text = creditString
    castLabel.sizeToFit()
    
    let offset = castLabel.frame.height - 46
    overviewTitleLabel.frame.origin.y += offset
    overviewLabel.frame.origin.y += offset
    
    scrollView.contentSize = sizeForContent()
  }
  
  func loadMovieInfo()
  {
    let url = NSURL(string: "\(baseUrl)\(movie["id"]!)?api_key=\(apiKey)")
    let request = NSURLRequest(
      URL: url!,
      cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
      timeoutInterval: 10)
    
    let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
      completionHandler: { (dataOrNil, response, error) in
        if let data = dataOrNil {
          if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
            data, options:[]) as? NSDictionary {
              print("response: \(responseDictionary)")
              
              self.movieAltData = responseDictionary
              
              self.fillMovieAltData()
          }
        }
        else {
          let alert = UIAlertController(title: "Warning", message: "You're out of range. Get to the Internet and try again.", preferredStyle: .Alert)
          alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (_) -> Void in
            self.loadMovieInfo()
          }))
          alert.addAction(UIAlertAction(title: "Give Up", style: .Destructive, handler: { (_) -> Void in
            exit(1)
          }))
          self.presentViewController(alert, animated: true, completion: nil)
        }
    })
    task.resume()
  }
  
  func loadCreditsInfo() {
    let url = NSURL(string: "\(baseUrl)\(movie["id"]!)/credits?api_key=\(apiKey)")
    let request = NSURLRequest(
      URL: url!,
      cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
      timeoutInterval: 10)
    
    let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
      completionHandler: { (dataOrNil, response, error) in
        if let data = dataOrNil {
          if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
            data, options:[]) as? NSDictionary {
              //                            print("response: \(responseDictionary)")
              
              self.credits = responseDictionary["cast"] as? [NSDictionary]
              self.fillCreditsData()
          }
        }
        else {
          let alert = UIAlertController(title: "Warning", message: "You're out of range. Get to the Internet and try again.", preferredStyle: .Alert)
          alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (_) -> Void in
            self.loadMovieInfo()
          }))
          alert.addAction(UIAlertAction(title: "Give Up", style: .Destructive, handler: { (_) -> Void in
            exit(1)
          }))
          self.presentViewController(alert, animated: true, completion: nil)
        }
    })
    task.resume()
    
  }
  
}

private func printedFormatter() -> NSDateFormatter
{
  let formatter = NSDateFormatter()
  formatter.dateStyle = .MediumStyle// Format = "MMM dd, yy"
  return formatter
}
