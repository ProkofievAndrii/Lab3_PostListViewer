//
//  PostInfoVC.swift
//  Lab3_PostListViewer
//
//  Created by Andrii Prokofiev on 24.02.2024.
//

import UIKit
import SDWebImage

class PostDetailsVC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet private weak var dataLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bookmarkButton: UIButton!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var commentsLabel: UILabel!
    @IBOutlet private weak var shareButton: UIButton!
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaultsManager.saveDefaultPosts()
    }

    
    //MARK: - Variables
    private var isSaved: Bool = false
    private var showingDefaultPosts: Bool = true
    private var livePosition: Int = 0
    private var defaultPosition: Int?
    
    //MARK: - Actions
    @IBAction func bookmarkButtonPressed(_ sender: UIButton) {
        //Buton image handling
        bookmarkButton.setImage(UIImage(systemName: isSaved ? "bookmark" : "bookmark.fill"), for: .normal)
        isSaved.toggle()
        
        APIManager.livePosts[livePosition].saved = isSaved
        if showingDefaultPosts {
            if isSaved {
                //Adding post to default array
                APIManager.defaultPosts.append(APIManager.livePosts[livePosition])
                let lastDefaultPosition = APIManager.defaultPosts.count - 1
                //Update value of its position to both live and default arrays
                APIManager.livePosts[livePosition].defaultPosition = lastDefaultPosition
                APIManager.defaultPosts[lastDefaultPosition].defaultPosition = lastDefaultPosition
            } else {
                //Removing post from default array
                APIManager.defaultPosts = removeAndShift(defaultPosition ?? 0)
                //Updating live position for live only since default was removed
                APIManager.livePosts[livePosition].defaultPosition = nil
            }
        } else {
            if isSaved {
                //Adding post to default array
                APIManager.defaultPosts.append(APIManager.livePosts[livePosition])
                let lastDefaultPosition = APIManager.defaultPosts.count - 1
                //Update value of its position to both live and default arrays
                APIManager.livePosts[livePosition].defaultPosition = lastDefaultPosition
                APIManager.defaultPosts[lastDefaultPosition].defaultPosition = lastDefaultPosition
            } else {
                //Removing post from default array
                APIManager.defaultPosts = removeAndShift(defaultPosition ?? 0)
                //Updating live position for live only since default was removed
                APIManager.livePosts[livePosition].defaultPosition = nil
            }
        }
        APIManager.defaultPostsCopy = APIManager.defaultPosts
        UserDefaultsManager.saveDefaultPosts()
    }
    
    //Copying link to currentPost via UIActivityController
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let permalink = "reddit.com\(isSaved ? APIManager.defaultPosts[livePosition].permalink : APIManager.livePosts[livePosition].permalink)"
        let activityViewController = UIActivityViewController(activityItems: [permalink as Any], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

//MARK: - Util functions
extension PostDetailsVC {
    func removeAndShift(_ index: Int) -> [APIManager.RedditPost]{
        var editedPosts = APIManager.defaultPosts
        guard index >= 0 && index < APIManager.defaultPosts.count else { return [] }
        editedPosts.remove(at: index)
        
        if index < editedPosts.count {
            editedPosts = Array(editedPosts[..<index]) + Array(editedPosts[index...])
        }
        for i in 0..<editedPosts.count {
            if editedPosts[i].defaultPosition != i { editedPosts[i].defaultPosition = i }
        }
        return editedPosts
    }
}

//MARK: - UI management
extension PostDetailsVC {
    func adjustUIInfo(using post: APIManager.RedditPost,_ showingDefaultPosts: Bool) {
        //Variables transfered
        self.isSaved = post.saved
        self.showingDefaultPosts = showingDefaultPosts
        self.livePosition = post.livePosition ?? 0
        self.defaultPosition = post.defaultPosition
        
        //Distributing post parameters to separately configure ui elements
        adjustDataLabel(post.author_fullname, post.created_utc, post.domain)
        adjustTitleLabel(post.title)
        adjustRatingLabel(post.ups, post.downs)
        adjustCommentLabel(post.num_comments)
        adjustBookmarkButton(post.saved)
        adjustImageView(post.url_overridden_by_dest)
    }
    
    private func adjustDataLabel(_ nickname: String?, _ createdInterval: TimeInterval, _ domain: String) {
        let currentDate = Date()
        let timePassedSincePosted = currentDate.addingTimeInterval(-createdInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh"
        dateFormatter.timeZone = TimeZone.current
        let formattedDate = dateFormatter.string(from: timePassedSincePosted)
        
        let labelText = "u/\(nickname ?? "Unknown") · \(formattedDate)h · \(domain)"
        self.dataLabel.text = labelText
    }
    
    private func adjustTitleLabel(_ title: String) {
        self.titleLabel.text = title
        self.titleLabel.numberOfLines = 1 + title.count / 42
    }
    
    private func adjustRatingLabel(_ ups: Int, _ downs: Int) {
        let rating = ups - downs
        self.ratingLabel.text = "\(rating)"
    }
    
    private func adjustCommentLabel(_ comments: Int) {
        self.commentsLabel.text = "\(comments)"
    }
    
    private func adjustBookmarkButton(_ isSaved: Bool) {
        let systemName = (isSaved) ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: systemName), for: .normal)
    }
    
    private func adjustImageView(_ url: URL?) {
        if url != nil {
            DispatchQueue.main.async {
                self.postImageView.sd_setImage(with: url)
            }
        } else { self.postImageView.image = UIImage(named: "image_placeholder") }
    }
}
