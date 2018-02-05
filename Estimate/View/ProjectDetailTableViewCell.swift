//
//  ProjectDetailTableViewCell.swift
//  Estimate
//
//  Created by Thong Tran on 1/22/18.
//  Copyright © 2018 Thong Tran. All rights reserved.
//

import UIKit

class ProjectDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var list : List? {
        didSet {
            var price = "0"
            price = String(describing: list!.itemPrice!)
            itemPrice.text = "$" + price
            itemName.text = list?.itemName
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
