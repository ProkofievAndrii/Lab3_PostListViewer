////
////  UserDefailtManager.swift
////  Lab3_PostListViewer
////
////  Created by Andrii Prokofiev on 27.02.2024.
////
//
//import Foundation
//
//extension UserDefaults {
//    static var savedPostsKey = "savedPostsKey"
//
//    func savePosts(_ posts: [APIManager.RedditPost]) {
//        do {
//            let encoder = JSONEncoder()
//            let encodedData = try encoder.encode(posts)
//            set(encodedData, forKey: UserDefaults.savedPostsKey)
//        } catch {
//            print("Error encoding posts: \(error.localizedDescription)")
//        }
//    }
//
//    func loadPosts() -> [APIManager.RedditPost] {
//        guard let savedData = data(forKey: UserDefaults.savedPostsKey) else {
//            return []
//        }
//
//        do {
//            let decoder = JSONDecoder()
//            let posts = try decoder.decode([APIManager.RedditPost].self, from: savedData)
//            return posts
//        } catch {
//            print("Error decoding posts: \(error.localizedDescription)")
//            return []
//        }
//    }
//}
