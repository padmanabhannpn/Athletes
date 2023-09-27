//
//  MedalTableViewCell.swift
//  test
//
//  Created by Logeshwaran  on 27/09/23.
//

import UIKit

class MedalTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLable: UILabel!
    
    @IBOutlet weak var goldView: UIView!
    @IBOutlet weak var silverView: UIView!
    @IBOutlet weak var bronzeViewe: UIView!
    
    @IBOutlet weak var goldLable: UILabel!
    @IBOutlet weak var silverLable: UILabel!
    @IBOutlet weak var bronzeLable: UILabel!
    
    @IBOutlet weak var goldImg: UIImageView!
    @IBOutlet weak var silverImg: UIImageView!
    @IBOutlet weak var bronzeImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
