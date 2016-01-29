//
//  MovieDetailsViewController.swift
//  MovieViewer
//
//  Created by Eric Gonzalez on 1/28/16.
//  Copyright © 2016 Eric Gonzalez. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var movie: NSDictionary!
    var poster: UIImage!
    var credits: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = movie["title"] as? String
        let average = movie["vote_average"] as? Double
        let count = movie["vote_count"] as? Int
        
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
        
        posterView.image = poster
        
        loadMovieInfo()
    }
    
    func loadMovieInfo()
    {
        let url = NSURL(string: "\(urlString)\(movie["id"])/credits?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                            self.credits = responseDictionary["results"] as? NSDictionary
                    }
                }
                else {
                    let alert = UIAlertController(title: "Warning", message: "You're out of range. Get to the Internet and try again.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Hunt", style: .Default, handler: { (_) -> Void in
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
