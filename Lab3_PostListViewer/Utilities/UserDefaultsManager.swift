//
//  UserDefailtManager.swift
//  Lab3_PostListViewer
//
//  Created by Andrii Prokofiev on 27.02.2024.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private init() {}

    static func saveDefaultPosts() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(APIManager.defaultPostsCopy) {
            UserDefaults.standard.set(encodedData, forKey: "defaultPostsCopy")
        }
    }

    static func loadDefaultPosts() {
        if let savedData = UserDefaults.standard.data(forKey: "defaultPostsCopy") {
            let decoder = JSONDecoder()
            if let loadedPosts = try? decoder.decode([APIManager.RedditPost].self, from: savedData) {
                APIManager.defaultPosts = loadedPosts
                APIManager.defaultPostsCopy = loadedPosts
            }
        }
    }
}
