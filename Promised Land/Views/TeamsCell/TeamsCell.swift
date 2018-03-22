//
//  TeamsCell.swift
//  Promised Land
//
//  Created by Dai Pham on 3/23/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit

class TeamsCell: UITableViewCell {

    // MARK: - api
    func load(team:Team) {
        self.team = team
        photo.loadImageUsingCacheWithURLString(team.team_photo)
        lblName.text = team.team_name
    }
    
    // MARK: - private
    private func config() {
        
    }
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        
        config()
    }
    
    override func prepareForReuse() {
        photo.image = nil
        team = nil
    }
    
    // MARK: - closures
    
    // MARK: - properties
    var team:Team?
    
    // MARK: - outlet
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
}
