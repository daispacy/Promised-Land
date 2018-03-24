//
//  ScoreController.swift
//  Promised Land
//
//  Created by Dai Pham on 3/25/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import Firebase

protocol ScoreControllerDelegate:class {
    func scoreControllerRequestCurrentTeam()->Team?
}


class ScoreController: UIViewController {

    // MARK: - api
    
    // MARK: - private
    private func config() {
        lblsubscore.font = UIFont.systemFont(ofSize: 16)
        lblsubscore.text = "Your team score"
        
        lblScore.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        lblScore.font = UIFont.boldSystemFont(ofSize: 40)
        lblScore.text = "0"
    }
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let team = delegate?.scoreControllerRequestCurrentTeam() else { return }
        
        ref.child("Teams").observe(.value, with: { (snapshot) in
            var score = 0
            for snap in snapshot.children  {
                if let s = snap as? DataSnapshot, let t = Team.parse(s) {
                    if t.team_id == team.team_id {
                        for s in t.station {
                            score = score + s.score
                        }
                    }
                }
            }
            self.lblScore.text = "\(score)"
        }, withCancel: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let team = delegate?.scoreControllerRequestCurrentTeam() else { return }
        ref.child("Teams").child(team.team_id).removeAllObservers()
    }
    
    // MARK: - closures
    
    // MARK: - properties
    var ref: DatabaseReference!
    weak var delegate:ScoreControllerDelegate?
    
    // MARK: - outlet
    @IBOutlet weak var lblsubscore: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    
}
