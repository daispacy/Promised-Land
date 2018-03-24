//
//  TableViewCell.swift
//  Promised Land
//
//  Created by Dai Pham on 3/24/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit

class NoticeCell: UITableViewCell {

    // MARK: - api
    func load(title:String, message:String, isFinish:Bool) {
        lblTitle.text = title
        lblMessage.text = message
        
        lblTitle.alpha = isFinish ? 0.5 : 1
        lblMessage.alpha = isFinish ? 0.5 : 1
    }
    
    // MARK: - private
    private func config() {
        
        selectionStyle = .none
        
        lblTitle.textColor = #colorLiteral(red: 0.6225510039, green: 0.6225510039, blue: 0.6225510039, alpha: 1)
        lblMessage.textColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
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
    @IBOutlet weak var lblMessage: UILabel!
}
