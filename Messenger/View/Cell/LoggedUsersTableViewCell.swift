//
//  LoggedUsersTableViewCell.swift
//  Messenger
//
//  Created by Suspect on 13.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit

class LoggedUsersTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
