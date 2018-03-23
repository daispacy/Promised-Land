//
//  Server.swift
//  Promised Land
//
//  Created by Dai Pham on 3/22/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import Firebase

class Server: NSObject {

    class func getListTeams(_ completion:((Any?, DatabaseReference)->Void)?) {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        ref.child("Welcome").observeSingleEvent(of: .value) { (snapshot) in
            
        }
        _ = ref.child("Welcome").observe(.value, with: { snapshot in
            for (team) in snapshot.children.enumerated() {
                print(team)
                completion?(team,ref)
            }
            
        })
    }
    
}
