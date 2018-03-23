//
//  ImageViewController.swift
//  Promised Land
//
//  Created by Dai Pham on 3/23/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    // MARK: - api
    
    // MARK: - act
    func touchPlay(_ sender:UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "teamController") as! TeamsController
        let nv = UINavigationController(rootViewController: vc)
        Support.changeRootControllerTo(viewcontroller: nv, animated: true, nil)
    }
    
    // MARK: - private
    private func config() {
        if let imageUrl = self.imageUrl {
            view.startLoading(activityIndicatorStyle: .gray, false)
            imageView.loadImageUsingCacheWithURLString(imageUrl, size: UIScreen.main.bounds.size, placeHolder: nil, false, {[weak self] image in
                guard let _self = self else {return}
                _self.view.stopLoading()
                })
        }
        
        btnPlay.layer.masksToBounds = true
        btnPlay.layer.cornerRadius = 4
        btnPlay.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        btnPlay.isHidden = !isShowButtonPlay
        btnPlay.addTarget(self, action: #selector(touchPlay(_:)), for: .touchUpInside)
    }
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
    }
    
    // MARK: - closures
    
    // MARK: - properties
    var imageUrl:String?
    var isShowButtonPlay:Bool = false
    
    // MARK: - outlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    
}
