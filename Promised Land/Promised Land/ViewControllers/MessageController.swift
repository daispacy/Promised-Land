//
//  MessageController.swift
//  Promised Land
//
//  Created by Dai Pham on 3/21/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit

class MessageController: UIViewController {

    // MARK: - api

    // MARK: - action
    func tapAction(_ sender:UITapGestureRecognizer) {
        onDissmiss?()
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - private
    private func config() {
        
        view.alpha = 0
        vwBG.alpha = 0
        
        vwContent.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        vwContent.layer.shadowOffset = CGSize(width:0.5, height:4.0)
        vwContent.layer.shadowOpacity = 0.5
        vwContent.layer.shadowRadius = 5.0
        vwContent.layer.cornerRadius = 5
        
        lblTitle.font = UIFont.boldSystemFont(ofSize: 18)
        lblTitle.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        lblMessage.font = UIFont.systemFont(ofSize: 16)
        lblMessage.textColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        
        if let title = titleMessage {
            lblTitle.text = title
        }
        
        if let title = message {
            lblMessage.text = title
        }
    }
    
    // MARK: - init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        
        MonitorLocation.shared.onDidExitRegion = {[weak self] in
            guard let _self = self else {return}
            _self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 1
            self.view.transform = .identity
        })
        
        UIView.animate(withDuration: 0.2, animations: {
            self.vwBG.alpha = 1
            self.view.transform = .identity
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        vwBG.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vwBG.removeGestureRecognizer(tapGesture)
    }
    
    // MARK: - closures
    var onDissmiss:(()->Void)?
    
    // MARK: - properties
    var tapGesture:UITapGestureRecognizer!
    var titleMessage:String? = nil
    var message:String? = nil
    
    // MARK: - outlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var vwContent: UIView!
    @IBOutlet weak var vwBG: UIView!
    
}
