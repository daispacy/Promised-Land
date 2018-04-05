//
//  TableViewCell.swift
//  Promised Land
//
//  Created by Dai Pham on 3/24/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit

class ActivitiesCell: UITableViewCell {

    // MARK: - api
    func load(_ title:String) {
        lblTitle.text = title
    }
    
    // MARK: - private
    private func config() {
        
        selectionStyle = .none
        
        lblTitle.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        
        config()
    }
    
    // MARK: - closures
    
    // MARK: - properties
    
    // MARK: - outlet
    @IBOutlet weak var lblTitle: UILabel!
}
