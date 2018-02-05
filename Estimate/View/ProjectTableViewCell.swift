//
//  ProjectTableViewCell.swift
//  Estimate
//
//  Created by Thong Tran on 1/22/18.
//  Copyright © 2018 Thong Tran. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var projectId: UILabel!
    
    var project: Project?{
        didSet {
            projectName.text = project?.projectName
            projectId.text = project?.projectId
            dateLabel.text = project?.day
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
 
    
}
