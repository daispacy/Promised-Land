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

    class func getListTeams(_ completion:((Any?)->Void)?) {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        _ = ref.child("Teams").observe(.value, with: { snapshot in
            for (i,team) in snapshot.children.enumerated() {
                print(team)
                completion?(team)
            }
            
        })
    }
    
}
