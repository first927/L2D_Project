//
//  MyCourseTableViewCell.swift
//  L2D
//
//  Created by Watcharagorn mayomthong on 7/27/2560 BE.
//  Copyright © 2560 Watcharagorn mayomthong. All rights reserved.
//

import UIKit

class MyCourseTableViewCell: UITableViewCell {
    
    
//    @IBOutlet weak var header_btn: UIButton!
//    @IBOutlet weak var MyCollectionView: UICollectionView!
    
    @IBOutlet weak var content_container: UIView!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseDetail: UILabel!
    @IBOutlet weak var instructorName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        content_container.layer.shadowColor = UIColor.black.cgColor
        content_container.layer.shadowOffset = CGSize(width:0, height:0)
        content_container.layer.shadowOpacity = 0.8
        content_container.layer.shadowRadius = 4
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
