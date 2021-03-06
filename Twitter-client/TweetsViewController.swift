//
//  TweetsViewController.swift
//  Twitter-client
//
//  Created by Xiomara on 10/30/16.
//  Copyright © 2016 Xiomara. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {

    static let sharedInstance = TweetsViewController()
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet]!
    var refreshControl: UIRefreshControl!
    var isMoreDataLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.getHomeTimeLine()
        
        refreshControl = UIRefreshControl(frame: CGRect.zero)
        refreshControl.addTarget(self,
            action: #selector(refreshAction),
            for: .allEvents
        )
        
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getHomeTimeLine()
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)!
            let tweet = tweets[indexPath.row]
            
            let detailsViewController = segue.destination as! TweetDetailsViewController
            detailsViewController.tweet = tweet
        }
    }
    
    @IBAction func onTapProfileImage(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileController") as! ProfileViewController
        
        if let tag = sender.view?.tag {
            let tweet = tweets[tag]
            profileVC.currentUser = tweet.user
            
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    @IBAction func onSignOutButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.logout()
    }
    
    // MARK: - Selector Methods
    func refreshAction(sender: AnyObject) {
        self.getHomeTimeLine()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Helper Methods
    func getHomeTimeLine() {
        TwitterClient.sharedInstance?.homeTimeLine(success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
        }, failure: { (error) in
            print("Error: \(error.localizedDescription)")
        })
    }
}

// MARK: - TableView Methods
extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        
        let tweet = tweets[indexPath.row]
        cell.tweetText.text = tweet.text
        cell.username.text = tweet.user?.name
        
        if let screenName = tweet.user?.screenName {
            cell.screenName.text = "@\(screenName)"
        }
        
        if let profileURL = tweet.user?.profileURL {
            cell.profileImageView.setImageWith(profileURL as URL)
            cell.profileImageView.tag = indexPath.row
        }
        
        //if let time = tweet.timestamp {
        //    let formatter = DateFormatter()
        //    let hours = time.timeIntervalSinceNow
        //    
        //    cell.timestamp.text = formatter.string(from: time.timeIntervalSinceNow as Date)
        //}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ScrollView Methods
extension TweetsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isMoreDataLoading {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                TwitterClient.sharedInstance?.reloadHome(
                tweetID: tweets.last!.id!,
                success: { tweets in
                    for tweet in tweets {
                        self.tweets.append(tweet)
                    }
                    
                    self.isMoreDataLoading = false
                    self.tableView.reloadData()
                    
                }, failure: { error in
                    print(error.localizedDescription)
                })
            }
        }
    }
}





