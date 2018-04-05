//
//  Station.swift
//  Promised Land
//
//  Created by Dai Pham on 3/22/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Station: NSObject {
    var title: String = ""
    var message: String = ""
    var photo_url: String = ""
    var score: Int = 0
    var id: Int = 0
    var activite: [String] = []
    var location:Location?
    var isFinish:Bool = false
    
    var snapshot:DataSnapshot?
    
    func toDict() -> JSON {
        if let snap = snapshot, let json = snap.value as? JSON {
            var dict = json
            dict["isFinish"] = isFinish
            if let dictionary = snap.childSnapshot(forPath: "Activite").value as? JSON {
                var activite:[String] = []
                for v in dictionary.values {
                    if let data = v as? String {
                        activite.append(data)
                    }
                }
                if activite.count > 0 {dict["activite"] = activite}
            }
            if let location = self.location {
                dict["Location"] = location.toDict()
            }
            return dict
        }
        return [:]
    }
}

extension Station {
    class func parse(_ snapshot:DataSnapshot) -> Station? {
        
        guard let dictionary = snapshot.value as? JSON else { return nil }
        
        guard let title = dictionary["Title"] as? String else { return nil }
        
        let team = Station()
        team.snapshot = snapshot
        
        team.title = title
        
        if let data = dictionary["Message"] as? String {
            team.message = data
        }
        
        if let data = dictionary["Photo_url"] as? String {
            team.photo_url = data
        }
        
        if let dictionary = snapshot.childSnapshot(forPath: "Activite").value as? JSON {
            team.activite = []
            for v in dictionary.values {
                if let data = v as? String {
                    team.activite.append(data)
                }
            }
        }
        
        if let data = dictionary["Station_ID"] as? String {
            team.id = Int(data)!
        } else if let data = dictionary["Station_ID"] as? Int {
            team.id = data
        }
        
        if let data = dictionary["Score"] as? String {
            team.score = Int(data)!
        } else if let data = dictionary["Score"] as? Int {
            team.score = data
        }
        team.location = Location.parse(snapshot.childSnapshot(forPath: "Location"))
        
        return team
    }
    
    class func parseFromJSON(_ dictionary:JSON) -> Station? {
        
        guard let title = dictionary["Title"] as? String else { return nil }
        
        let team = Station()
        
        team.title = title
        
        if let data = dictionary["Message"] as? String {
            team.message = data
        }
        
        if let data = dictionary["Photo_url"] as? String {
            team.photo_url = data
        }
        
        if let data = dictionary["Station_ID"] as? String {
            team.id = Int(data)!
        } else if let data = dictionary["Station_ID"] as? Int {
            team.id = data
        }
        
        if let data = dictionary["Score"] as? String {
            team.score = Int(data)!
        } else if let data = dictionary["Score"] as? Int {
            team.score = data
        }
        
        if let data = dictionary["Location"] as? JSON {
            team.location = Location.parseFromJSON(data)
        }
        
        if let data = dictionary["activite"] as? [String] {
            team.activite = data
        }
        
        if let data = dictionary["isFinish"] as? Bool {
            team.isFinish = data
        }
        
        return team
    }
}
