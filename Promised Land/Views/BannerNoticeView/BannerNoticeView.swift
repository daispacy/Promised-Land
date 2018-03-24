//
//  BannerNoticeView.swift
//  Promised Land
//
//  Created by Dai Pham on 3/25/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit

class BannerNoticeView: UIView {

    // MARK: - api
    
    // MARK: - action
    func newGame(_ sender:UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "welcomeController") as! WelcomeController
        Support.changeRootControllerTo(viewcontroller: vc, animated: true, nil)
    }
    
    // MARK: - private
    private func config() {
        lblMessage.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        lblMessage.text = "Congratulations to the team on goal"
        
        btnNewgame.setTitle("New Team", for: UIControlState())
        btnNewgame.layer.masksToBounds = true
        btnNewgame.layer.cornerRadius = 5
        
        btnNewgame.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControlState())
        btnNewgame.addTarget(self, action: #selector(newGame(_:)), for: .touchUpInside)
    }
    
    private func loadNib() {
        Bundle.main.loadNibNamed("BannerNoticeView", owner: self, options: nil)
        self.addSubview(self.view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        config()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    // MARK: - closures
    
    // MARK: - properties
    
    // MARK: - outlet
    @IBOutlet weak var view:UIView!
    @IBOutlet weak var btnNewgame: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    
}
