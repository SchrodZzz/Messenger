//
//  DialogsTableViewCell.swift
//  Messenger
//
//  Created by Suspect on 04.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit

class DialogsTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var friendAvatar: UIImageView!
    @IBOutlet weak var friendLoginLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
