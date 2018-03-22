//
//  Support.swift
//  Promised Land
//
//  Created by Dai Pham on 3/23/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit

class Support: NSObject {
    
    class func changeRootControllerTo(viewcontroller:UIViewController, animated:Bool? = false,_ complete:((Bool)->Void)? = nil) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        var duration:Double  = 0
        if let animate = animated {
            if animate {duration = 0.3}
        }
        
        if let window = appdelegate.window {
            UIView.transition(with: window, duration: duration, options: .transitionCrossDissolve, animations: {
                window.rootViewController?.view.removeFromSuperview()
                window.rootViewController = nil
                window.rootViewController = viewcontroller
                window.makeKeyAndVisible()
                appdelegate.window = window
            }, completion:complete)
        }
    }
    
    class func notice(title:String, message:String,vc:UIViewController,_ buttons:[String] = ["ok".localized().uppercased()],_ action:((UIAlertAction)->Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        for (i,btnTitle) in buttons.enumerated() {
            if i > 2 {break}
            var type:UIAlertActionStyle = .cancel
            if i == 0 {
                type = .default
            } else if i == 1 {
                type = .destructive
            }
            ac.addAction(UIAlertAction(title: btnTitle, style: type, handler: action))
        }
        vc.present(ac, animated: true)
    }
    
    class var getCacheTeam: JSON? {
        if(UserDefaults.standard.data(forKey: "AppConfig:Cached:Team") != nil) {
            if let listT = NSKeyedUnarchiver.unarchiveObject(with:UserDefaults.standard.value(forKey: "AppConfig:Cached:Team") as! Data) as? JSON {
                return listT
            }
            
        }
        return nil
    }
    
    class func setCacheTeam(data:JSON?) {
        guard let data = data else {
            UserDefaults.standard.removeObject(forKey: "AppConfig:Cached:Team")
            UserDefaults.standard.synchronize()
            return
        }
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:data), forKey: "AppConfig:Cached:Team")
        UserDefaults.standard.synchronize()
    }
}
