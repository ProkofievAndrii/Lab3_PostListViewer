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
    
    //MARK: - Variables
    private var isSaved: Bool = false
    private var position: Int = 0
    
    //MARK: - Actions
    @IBAction func bookmarkButtonPressed(_ sender: UIButton) {
        if self.isSaved {
            bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            isSaved = false
        } else {
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            isSaved = true
        }
        print(APIManager.livePosts[position].title)
        APIManager.livePosts[position].saved = isSaved
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let permalink = "reddit.com\(APIManager.livePosts[position].permalink)"
        let activityViewController = UIActivityViewController(activityItems: [permalink as Any], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

//MARK: - UI management
extension PostDetailsVC {
    func adjustUIInfo(using position: Int?) {
        let post = APIManager.livePosts[position ?? 0]
        isSaved = post.saved
        self.position = position ?? 0
        
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
