//
//  BioTableViewCell.swift
//  test
//
//  Created by Logeshwaran  on 27/09/23.
//

import UIKit

class BioTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
