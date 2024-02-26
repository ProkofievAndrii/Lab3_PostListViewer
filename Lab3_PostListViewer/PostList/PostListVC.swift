//
//  PostListVC.swift
//  Lab3_PostListViewer
//
//  Created by Andrii Prokofiev on 24.02.2024.
//

import UIKit

class PostListVC: UIViewController {

    //MARK: - Outlet
    @IBOutlet private weak var postTableView: UITableView!
    @IBOutlet private weak var bookmarkFilterButton: UIBarButtonItem!
    
    //MARK: - Constants
    struct Const {
        static let cellReuseId = "post_view_cell"
        static let detailsSegueID = "post_details_segue"
    }
    
    //MARK: - Values & parameters
    struct APIParams {
        static let subreddit = "ios"
        static let limit = 20
        static var after: String? = nil
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        self.navigationItem.title = "r/\(APIParams.subreddit)"

        APIManager.apiManager.fetchData(APIParams.subreddit, APIParams.limit, APIParams.after) { posts in
            if let posts = posts {
                APIManager.posts = posts
                DispatchQueue.main.async {
                    self.postTableView.reloadData()
                }
            } else { print("Failed to fetch posts") }
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Const.detailsSegueID:
            let nextVC = segue.destination as! PostDetailsVC
            DispatchQueue.main.async {
                nextVC.adjustUIInfo(post: APIManager.lastCelectedPost ?? APIManager.posts[0])
            }
        default: break
        }
    }
    
    //MARK: - Table configuration functions
    private func configTableView() {
        postTableView.dataSource = self
        postTableView.delegate = self
        postTableView.register(UINib(nibName: "PostViewCell", bundle: nil), forCellReuseIdentifier: Const.cellReuseId)
    }
    
    private func configureDefaultCell(_ cell: PostViewCell) -> PostViewCell {
        let placeholderText = "Loading.."
        cell.dataLabel.text = placeholderText
        cell.dataLabel.text = placeholderText
        cell.ratingLabel.text = placeholderText
        cell.commentLabel.text = placeholderText
        cell.postImageView.image = UIImage(named: "image_placeholder")
        return cell
    }
    
    private func configureCompleteCell(_ cell: PostViewCell, row: Int) -> PostViewCell {
        let currPost = APIManager.posts[row]
        let currentDate = Date()
        let timePassedSincePosted = currentDate.addingTimeInterval(-currPost.created_utc)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh"
        dateFormatter.timeZone = TimeZone.current
        let formattedDate = dateFormatter.string(from: timePassedSincePosted)
        
        let labelText = "u/\(currPost.author_fullname ?? "Unknown") · \(formattedDate)h · \(currPost.domain)"
        cell.dataLabel.text = labelText
        cell.titleLabel.text = "\(currPost.title)"
        cell.ratingLabel.text = "\(currPost.ups - currPost.downs)"
        cell.commentLabel.text = "\(currPost.num_comments)"
        
        let url = currPost.url_overridden_by_dest
        if url != nil {
            DispatchQueue.main.async {
                cell.postImageView.sd_setImage(with: url)
            }
        } else {
            cell.postImageView.image = UIImage(named: "image_placeholder")
        }
        return cell;
    }
}

//MARK: - UITableViewDataSource
extension PostListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIParams.limit;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = postTableView.dequeueReusableCell(withIdentifier: Const.cellReuseId, for: indexPath) as! PostViewCell
        if APIManager.posts.isEmpty { cell = configureDefaultCell(cell) }
        else { cell = configureCompleteCell(cell, row: indexPath.row) }
        return cell;
    }
}

//MARK: - UITableViewDelegate
extension PostListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        APIManager.lastCelectedPost = APIManager.posts[indexPath.row]
        self.performSegue(withIdentifier: Const.detailsSegueID, sender: nil)
    }
}
