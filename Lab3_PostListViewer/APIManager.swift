//
//  APIManager.swift
//  Lab3_PostListViewer
//
//  Created by Andrii Prokofiev on 25.02.2024.
//

import Foundation

class APIManager {
    
    static var posts: [RedditPost] = []
    static var lastCelectedPost: APIManager.RedditPost?
    
    struct RedditResponse: Codable {
        let kind: String
        let data: RedditData
    }

    struct RedditData: Codable {
        let children: [RedditChild]
    }

    struct RedditChild: Codable {
        let data: RedditPost
    }

    struct RedditPost: Codable {
        let author_fullname: String?
        let created_utc: TimeInterval
        let domain: String
        let saved: Bool
        let title: String
        let ups: Int
        let downs: Int
        let num_comments: Int
        let url_overridden_by_dest: URL?
    }

    func fetchData(_ subreddit: String, _ limit: Int, _ after: String?, completion: @escaping ([RedditPost]?) -> Void) {
        guard let url = URL(string: "https://www.reddit.com/r/\(subreddit)/top.json?limit=\(limit)")
        else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else { completion(nil); return }
            
            do {
                let decoder = JSONDecoder()
                let redditResponse = try decoder.decode(RedditResponse.self, from: data)
                let posts = redditResponse.data.children.map { $0.data }
                completion(posts)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    static public var apiManager = APIManager()
}
