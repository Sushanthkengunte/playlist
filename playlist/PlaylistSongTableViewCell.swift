//
//  PlaylistSongTableViewCell.swift
//  playlist
//
//  Created by Sushanth on 6/15/17.
//  Copyright © 2017 SuProject. All rights reserved.
//

import UIKit

class PlaylistSongTableViewCell: UITableViewCell {

    @IBOutlet weak var SongsList: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
