//
//  MessageTableViewCell.swift
//  Messenger
//
//  Created by Suspect on 13.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.messageView.layer.cornerRadius = 10.0
        
        self.messageLabel.numberOfLines = 0
        self.messageLabel.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
