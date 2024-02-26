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
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        dataLabel.text = nil
        bookmarkImage.image = nil
        titleLabel.text = nil
        postImageView.image = nil
        ratingLabel.text = nil
        commentLabel.text = nil
    }
}
