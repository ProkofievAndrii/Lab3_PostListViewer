//
//  PostViewCell.swift
//  Lab3_PostListViewer
//
//  Created by Andrii Prokofiev on 24.02.2024.
//

import UIKit

class PostViewCell: UITableViewCell {

    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var bookmarkImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var upsImageView: UIImageView!
    @IBOutlet weak var upsLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
//    func config(with data: Int) {
//        self.inputViewController?.performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
//    }
}
