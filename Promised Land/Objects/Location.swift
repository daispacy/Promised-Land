//
//  Location.swift
//  Promised Land
//
//  Created by Dai Pham on 3/22/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Location: NSObject {
    var name: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var snapshot:DataSnapshot?
    
    func toDict() -> JSON {
        if let snap = snapshot, let json = snap.value as? JSON {
            return json
        }
        return [:]
    }
}

extension Location {
    class func parse(_ snapshot:DataSnapshot) -> Location? {
        
        guard let dictionary = snapshot.value as? JSON else { return nil}
        guard let name = dictionary["Name"] as? String else { return nil }
        
        let team = Location()
        team.snapshot = snapshot
        team.name = name
        
        if let data = dictionary["Latitude"] as? String {
            team.latitude = Double(data)!
        } else if let data = dictionary["Latitude"] as? Double {
            team.latitude = data
        }
        
        if let data = dictionary["Longitude"] as? String {
            team.longitude = Double(data)!
        } else if let data = dictionary["Longitude"] as? Double {
            team.longitude = data
        }
        
        return team
    }
    
    class func parseFromJSON(_ dictionary:JSON) -> Location? {
        
        guard let name = dictionary["Name"] as? String else { return nil }
        
        let team = Location()
        team.name = name
        
        if let data = dictionary["Latitude"] as? String {
            team.latitude = Double(data)!
        } else if let data = dictionary["Latitude"] as? Double {
            team.latitude = data
        }
        
        if let data = dictionary["Longitude"] as? String {
            team.longitude = Double(data)!
        } else if let data = dictionary["Longitude"] as? Double {
            team.longitude = data
        }
        
        return team
    }
}
