//
//  APIManager.swift
//  Lab3_PostListViewer
//
//  Created by Andrii Prokofiev on 25.02.2024.
//

import Foundation

class APIManager {
    
    //MARK: - Variables
    static var apiManager = APIManager()
    
    static var livePosts: [RedditPost] = []
    static var defaultPosts: [RedditPost] = []
    static var lastCelectedPost: RedditPost? = nil
    
    //MARK: - API structures
    struct RedditResponse: Codable {
        let kind: String
        let data: RedditData
    }
    
    struct RedditData: Codable {
        let children: [RedditChild]
        let after: String
    }
    
    struct RedditChild: Codable {
        let data: RedditPost
    }
    
    struct RedditPost: Codable {
        let author_fullname: String?
        let created_utc: TimeInterval
        let domain: String
        var saved: Bool
        let title: String
        let ups: Int
        let downs: Int
        let num_comments: Int
        let url_overridden_by_dest: URL?
        let permalink: String
        
        //Position of post in live/default array
        var livePosition: Int?
        var defaultPosition: Int?
    }
    
    //MARK: - Inner request
    func fetchData(_ subreddit: String, _ limit: Int, _ after: String?, completion: @escaping ([RedditPost]?) -> Void) {
        var urlString = "https://www.reddit.com/r/\(subreddit)/top.json?limit=\(limit)"
        
        if let after = after { urlString += "&after=\(after)" }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let redditResponse = try decoder.decode(RedditResponse.self, from: data)
                PostListVC.APIParams.after = redditResponse.data.after
                let posts = redditResponse.data.children.map { $0.data }
                completion(posts)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    //API request
    static func loadNewPosts(_ subreddit: String,_ limit: Int,_ after: String?) {
        apiManager.fetchData(subreddit, limit, after) { posts in
            if let posts = posts { APIManager.livePosts.append(contentsOf: posts) }
            else { print("Failed to fetch posts") }
        }
    }
}
