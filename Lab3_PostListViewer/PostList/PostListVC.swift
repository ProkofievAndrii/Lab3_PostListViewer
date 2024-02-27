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
        static let subreddit = "deadbydaylight"
        static let limit = 10
        static var after: String? = nil
    }
    private var loadingNewPosts = false
    private var showingDefaultPosts = false
    
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        self.navigationItem.title = "r/\(APIParams.subreddit)"
        Task {
            await loadNextPage()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - Actions
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    
    //MARK: - Paging
    func loadNextPage() async {
        loadingNewPosts = true
        APIManager.apiManager.fetchData(APIParams.subreddit, APIParams.limit, APIParams.after) { posts in
            if let posts = posts {
                APIManager.livePosts.append(contentsOf: posts)
                DispatchQueue.main.async {
                    self.postTableView.reloadData()
                    self.loadingNewPosts = false
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
                nextVC.adjustUIInfo(using: APIManager.lastCelectedPosition ?? 0)
            }
        default: break
        }
    }
    
    //MARK: - Table/Cell configuration functions
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
        cell.bookmarkImageView.image = UIImage(systemName: "bookmark")
        return cell
    }
    
    private func configureCompleteCell(_ cell: PostViewCell, row: Int) -> PostViewCell {
        let currPost = APIManager.livePosts[row]
        
        let formattedDate = configureCorrectDate(interval: currPost.created_utc)
        let dataLabelText = "u/\(currPost.author_fullname ?? "Unknown") · \(formattedDate)h · \(currPost.domain)"
        cell.dataLabel.text = dataLabelText
        cell.titleLabel.text = "\(currPost.title)"
        cell.ratingLabel.text = "\(currPost.ups - currPost.downs)"
        cell.commentLabel.text = "\(currPost.num_comments)"
        let bookmarkImage = currPost.saved ? "bookmark.fill" : "bookmark"
        cell.bookmarkImageView.image = UIImage(systemName: bookmarkImage)
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
    
    private func configureCorrectDate(interval: TimeInterval) -> String{
        let currentDate = Date()
        let timePassedSincePosted = currentDate.addingTimeInterval(-interval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh"
        dateFormatter.timeZone = TimeZone.current
        let formattedDate = dateFormatter.string(from: timePassedSincePosted)
        return "\(formattedDate)"
    }
}

//MARK: - UITableViewDataSource
extension PostListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIManager.livePosts.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = postTableView.dequeueReusableCell(withIdentifier: Const.cellReuseId, for: indexPath) as! PostViewCell
        if APIManager.livePosts.isEmpty { cell = configureDefaultCell(cell) }
        else { cell = configureCompleteCell(cell, row: indexPath.row) }
        return cell;
    }
}

//MARK: - UITableViewDelegate
extension PostListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        APIManager.lastCelectedPosition = indexPath.row
        self.performSegue(withIdentifier: Const.detailsSegueID, sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset_Y = scrollView.contentOffset.y
        let height = scrollView.contentSize.height
        
        if offset_Y >= height - 330*4 && !loadingNewPosts {
            Task {
                await loadNextPage()
            }
        }
    }
}
