//
//  PostListVC.swift
//  Lab3_PostListViewer
//
//  Created by Andrii Prokofiev on 24.02.2024.
//

import UIKit

class PostListVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet private weak var postTableView: UITableView!
    @IBOutlet private weak var bookmarkFilterButton: UIBarButtonItem!
    @IBOutlet private weak var searchBar: UISearchBar!
    private var tableHeaderView: UIView?
    
    //MARK: - Constants and parameters
    
    //Constants used in navigation
    struct Const {
        static let cellReuseId = "post_view_cell"
        static let detailsSegueID = "post_details_segue"
    }
    
    //Parameters used in API data fetching
    struct APIParams {
        static let subreddit = "deadbydaylight"
        static let limit = 10
        static var after: String? = nil
    }
    
    //MARK: - Variables
    private var currentlyLoadingNewPosts = false
    private var showingDefaultPosts = true
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        configSearchBar()
        UserDefaultsManager.loadDefaultPosts()
        APIManager.loadNewPosts(APIParams.subreddit, APIParams.limit, APIParams.after)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - Actions
    @IBAction func filterButtonPressed(_ sender: Any) {
        guard !currentlyLoadingNewPosts else { return }
        //Filter button image updates
        if showingDefaultPosts {
            bookmarkFilterButton.image = UIImage(systemName: "bookmark")
            showingDefaultPosts = false
        } else {
            bookmarkFilterButton.image = UIImage(systemName: "bookmark.fill")
            showingDefaultPosts = true
        }
        updateSearchBar()
        //Reloading table view using dufferent data array
        postTableView.reloadData()
    }
    
    
    //MARK: - Paging
    func loadNewPage() async {
        currentlyLoadingNewPosts = true
        //Load new portion of posts and save in an array
        APIManager.loadNewPosts(APIParams.subreddit, APIParams.limit, APIParams.after)
        DispatchQueue.main.async {
            //Reload table view using updateddata
            self.postTableView.reloadData()
            self.currentlyLoadingNewPosts = false
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Const.detailsSegueID:
            let nextVC = segue.destination as! PostDetailsVC
            DispatchQueue.main.async {
                nextVC.adjustUIInfo(using: APIManager.lastCelectedPost!, self.showingDefaultPosts)
            }
        default: break
        }
    }
}

//MARK: - SearchBar config functions
extension PostListVC {
    private func configSearchBar() {
        searchBar.delegate = self
        searchBar.isHidden = !showingDefaultPosts
        tableHeaderView = postTableView.tableHeaderView
    }
}

//MARK: - Table/Cell config functions
extension PostListVC {
    private func configTableView() {
        postTableView.dataSource = self
        postTableView.delegate = self
        postTableView.register(UINib(nibName: "PostViewCell", bundle: nil), forCellReuseIdentifier: Const.cellReuseId)
        self.navigationItem.title = "r/\(APIParams.subreddit)"
    }
    
    private func configureDefaultCell(_ cell: PostViewCell) -> PostViewCell {
        let placeholderText = "Loading.."
        cell.dataLabel.text = placeholderText
        cell.titleLabel.text = placeholderText
        cell.ratingLabel.text = placeholderText
        cell.commentLabel.text = placeholderText
        cell.postImageView.image = UIImage(named: "image_placeholder")
        cell.bookmarkImageView.image = UIImage(systemName: "bookmark")
        return cell
    }
    
    private func configureCompleteCell(_ cell: PostViewCell, row: Int) -> PostViewCell {
        //Defining current post
        var currPost: APIManager.RedditPost
        if showingDefaultPosts {
            currPost = APIManager.defaultPosts[row]
            APIManager.defaultPosts[row].defaultPosition = row
        } else {
            currPost = APIManager.livePosts[row]
            APIManager.livePosts[row].livePosition = row
        }
        
        //labels configauration
        let formattedDate = configureCorrectDate(interval: currPost.created_utc)
        let dataLabelText = "u/\(currPost.author_fullname ?? "Unknown") · \(formattedDate)h · \(currPost.domain)"
        cell.dataLabel.text = dataLabelText
        cell.titleLabel.text = "\(currPost.title)"
        cell.ratingLabel.text = "\(currPost.ups - currPost.downs)"
        cell.commentLabel.text = "\(currPost.num_comments)"
        let bookmarkImage = currPost.saved ? "bookmark.fill" : "bookmark"
        //images configuration
        cell.bookmarkImageView.image = UIImage(systemName: bookmarkImage)
        let url = currPost.url_overridden_by_dest
        if url != nil {
            DispatchQueue.main.async {
                cell.postImageView.sd_setImage(with: url)
            }
        } else { cell.postImageView.image = UIImage(named: "image_placeholder") }
        return cell;
    }
}

//MARK: - Util functions
extension PostListVC {
    private func updateSearchBar() {
        searchBar.isHidden = !showingDefaultPosts
        if let headerView = tableHeaderView {
            postTableView.tableHeaderView = showingDefaultPosts ? headerView : UIView(frame: CGRect(x: 0, y: 0, width: postTableView.bounds.width, height: 0))
        }
    }
    
    private func filterSavedPosts(_ searchText: String) {
        APIManager.defaultPosts = searchText.isEmpty ?
        APIManager.defaultPostsCopy : APIManager.defaultPosts.filter { post in
            return post.title.lowercased().contains(searchText.lowercased())
        }
        postTableView.reloadData()
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

//MARK: - UISearchBarDelegate
extension PostListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterSavedPosts(searchText)
    }
}

//MARK: - UITableViewDataSource
extension PostListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var quantity = 0
        if showingDefaultPosts { quantity = APIManager.defaultPosts.count }
        else { quantity = APIManager.livePosts.count }
        return quantity;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = postTableView.dequeueReusableCell(withIdentifier: Const.cellReuseId, for: indexPath) as! PostViewCell
        
        if showingDefaultPosts {
            if APIManager.defaultPosts.isEmpty { cell = configureDefaultCell(cell) }
            else { cell = configureCompleteCell(cell, row: indexPath.row) }
        } else {
            if APIManager.livePosts.isEmpty { cell = configureDefaultCell(cell) }
            else { cell = configureCompleteCell(cell, row: indexPath.row) }
        }
        
        return cell;
    }
}

//MARK: - UITableViewDelegate
extension PostListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showingDefaultPosts { APIManager.lastCelectedPost = APIManager.defaultPosts[indexPath.row]}
        else { APIManager.lastCelectedPost = APIManager.livePosts[indexPath.row] }
        self.performSegue(withIdentifier: Const.detailsSegueID, sender: nil)
    }
    
    //If couple posts to bottom left, load new posts and update page
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset_Y = scrollView.contentOffset.y
        let height = scrollView.contentSize.height
        
        if offset_Y >= height - 330*4 && !currentlyLoadingNewPosts && !showingDefaultPosts {
            Task {
                await loadNewPage()
            }
        }
    }
}
