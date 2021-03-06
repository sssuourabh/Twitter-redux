//
//  Tweet.swift
//  Twitter-client
//
//  Created by Xiomara on 10/29/16.
//  Copyright © 2016 Xiomara. All rights reserved.
//

import UIKit

class Tweet: NSObject {

    var text: String?
    var timestamp: NSDate?
    var mediaURL: NSURL?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var favorited: Bool?
    var retweeted: Bool?
    var inReplyTo: Int?
    var id: Int?
    
    var user: User?
    
    var userMentions: [NSDictionary]?
    
    init(dictionary: NSDictionary) {
        text = dictionary["text"] as? String
        id = dictionary["id"] as? Int
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favourites_count"] as? Int) ?? 0
        
        favorited = dictionary["favorited"] as? Bool
        retweeted = dictionary["retweeted"] as? Bool
        
        inReplyTo = dictionary["in_reply_to_status_id"] as? Int
        userMentions = dictionary["user_mentions"] as? [NSDictionary]
        
        let timestampString = dictionary["created_at"] as? String
        let formatter = DateFormatter()
        formatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        
        if let timestampString = timestampString {
            timestamp = formatter.date(from: timestampString) as NSDate?
        }
        
        if let userDict = dictionary["user"] as? NSDictionary {
            user = User(dictionary: userDict)
        }
        
        if let entities = dictionary["entities"] as? NSDictionary {
            if let media = entities["media"] as? NSDictionary {
                mediaURL = NSURL(string: media["media_url"] as! String)
            }
        }
        
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
    
}
