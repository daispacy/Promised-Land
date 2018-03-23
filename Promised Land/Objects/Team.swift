//
//  Team.swift
//  Promised Land
//
//  Created by Dai Pham on 3/22/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Team: NSObject {
    var team_id: String = ""
    var team_name: String = ""
    var team_photo: String = ""
    var station: [Station] = []
    
    var snapshot:DataSnapshot?
    
    func toDict() -> JSON {
        if let snap = snapshot, let json = snap.value as? JSON {
            var dict = json
            var stations:[JSON] = []
            for station in station {
                stations.append(station.toDict())
            }
            dict["Station"] = stations
            return dict
        }
        return [:]
    }
}

extension Team {
    class func parse(_ snapshot:DataSnapshot) -> Team? {
        let team = Team()
        
        team.snapshot = snapshot
        
        guard let dictionary = snapshot.value as? JSON else { return nil}
        
        if let data = dictionary["Team_ID"] as? String {
            team.team_id = data
        }
        
        if let data = dictionary["Team_Name"] as? String {
            team.team_name = data
        }
        
        if let data = dictionary["Team_Photo"] as? String {
            team.team_photo = data
        }
        
        var listStation:[Station] = []
        if snapshot.hasChild("Station") {
            for snap in snapshot.childSnapshot(forPath: "Station").children {
                if let station = Station.parse(snap as! DataSnapshot) {
                    listStation.append(station)
                }
            }
        }
        team.station = listStation.sorted(by: {$0.id < $1.id})
        
        return team
    }
    
    class func parseFromJSON(_ dictionary:JSON) -> Team? {
        
        let team = Team()
        
        if let data = dictionary["Team_ID"] as? String {
            team.team_id = data
        }
        
        if let data = dictionary["Team_Name"] as? String {
            team.team_name = data
        }
        
        if let data = dictionary["Team_Photo"] as? String {
            team.team_photo = data
        }
        
        if let data = dictionary["Station"] as? [JSON] {
            team.station = []
            for st in data {
                if let station = Station.parseFromJSON(st) {
                    team.station.append(station)
                }
            }
        }
        
        return team
    }
}
