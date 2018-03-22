//
//  TeamsController.swift
//  Promised Land
//
//  Created by Dai Pham on 3/22/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseUI

class TeamsController: UIViewController {

    // MARK: - api
    
    // MARK: - private
    private func getQuery() -> DatabaseQuery {
        return self.ref.child("Teams")
    }
    
    private func config() {
        
        tableView.register(UINib(nibName: "TeamsCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        
        ref = Database.database().reference()
        
        dataSource = FUITableViewDataSource(query: getQuery()) { (tableView, indexPath, snap) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TeamsCell
            if let team = Team.parse(snap) {
                cell.load(team: team)
            }
            return cell
        }
        
        dataSource?.bind(to: tableView)
        tableView.delegate = self
    }
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select your team"
        
        config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        getQuery().removeAllObservers()
    }
    
    // MARK: - closures
    
    // MARK: - properties
    var ref: DatabaseReference!
    var dataSource: FUITableViewDataSource?
    
    // MARK: - outlet
    @IBOutlet weak var tableView: UITableView!
}

extension TeamsController:UITableViewDelegate    {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let dataSource = dataSource {
            if let team = Team.parse(dataSource.snapshot(at: indexPath.row)) {
                Support.notice(title: "", message: "Would you like to choose \"\(team.team_name)\" team. Remember that you will not be able to choose again.", vc: self,["No","Yes"], { (action) in
                    if action.title == "Yes" {
                        Support.setCacheTeam(data: team.toDict())
                        let mapVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "mapController") as! MapController
                        Support.changeRootControllerTo(viewcontroller: mapVC, animated: true, nil)
                    }
                })
            }
        }
    }
}
