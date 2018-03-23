//
//  MessageController.swift
//  Promised Land
//
//  Created by Dai Pham on 3/21/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import AVFoundation

protocol MesssageControllerDelegate:class {
    func messageControllerStart()
    func messageControllerShouldMinimize()
    func messageControllerExitZone()
}

class MessageController: UIViewController {

    // MARK: - api

    // MARK: - action
    func touchStart(_ sender:UIButton) {
        delegate?.messageControllerShouldMinimize()
        dismiss(animated: false, completion: nil)
    }
    
    func tapAction(_ sender:UITapGestureRecognizer) {
        delegate?.messageControllerShouldMinimize()
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - private
    private func config() {
        
        view.alpha = 0
        
        imageBG.isUserInteractionEnabled = true
        
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
            _self.delegate?.messageControllerExitZone()
            _self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioServicesPlayAlertSound(SystemSoundID(1322))
        
        self.view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 1
            self.view.transform = .identity
        })
        
        delegate?.messageControllerStart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        imageBG.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageBG.removeGestureRecognizer(tapGesture)
    }
    
    // MARK: - closures
    
    // MARK: - properties
    weak var delegate:MesssageControllerDelegate?
    var tapGesture:UITapGestureRecognizer!
    var titleMessage:String? = nil
    var message:String? = nil
    var shouldShowStartButton:Bool = true
    
    // MARK: - outlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!    
    @IBOutlet weak var imageBG: UIImageView!
}
