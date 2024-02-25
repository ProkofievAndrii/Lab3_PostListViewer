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
    
    //MARK: - Constants
    struct Const {
        static let cellReuseId = "post_view_cell"
        static let detailsSegueID = "post_details_segue"
    }
    
    //MARK: - Values & parameters
    struct APIParams {
        static let subreddit = "ios"
        static let limit = 1
    }
    
    private let lastCelectedNumber: Int? = nil
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "r/\(APIParams.subreddit)"
        postTableView.dataSource = self
        postTableView.delegate = self
        postTableView.register(UINib(nibName: "PostViewCell", bundle: nil), forCellReuseIdentifier: Const.cellReuseId)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Const.detailsSegueID: break
//            let nextVC = segue.destination as! PostDetailsVC
//            DispatchQueue.main.async {
//                nextVC.config(with: )
//            }
        default: break
        }
    }
}

//MARK: - UITableViewDataSource
extension PostListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postTableView.dequeueReusableCell(withIdentifier: Const.cellReuseId, for: indexPath) as! PostViewCell
        cell.dataLabel.text = "\(indexPath.row + 1)"
        return cell;
    }
}

//MARK: - UITableViewDelegate
extension PostListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Const.detailsSegueID, sender: nil)
    }
}
