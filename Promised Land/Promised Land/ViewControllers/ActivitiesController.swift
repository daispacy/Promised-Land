//
//  ActivitiesController.swift
//  Promised Land
//
//  Created by Dai Pham on 4/4/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit

class ActivitiesController: UIViewController {

    // MARK: - api
    
    // MARK: - action
    func shouldReloadData(_ sender:NSNotification) {
        load()
    }
    
    // MARK: - private
    private func config() {
        title = "Activities"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ActivitiesCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    private func load() {
        guard let team = delegate?.dataDelegateRequestCurrentTeam() else { return }
        
        activities.removeAll()
        for station in team.station {
            if station.isFinish {
                continue
            } else {
                activities = station.activite
                tableView.reloadData()
                break
            }
        }
        
        if activities.count > 0 {
            tableView.backgroundView = nil
        }
        
        tableView.reloadData()
    }
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldReloadData(_:)), name: NSNotification.Name("App:BaseController:ShouldRefreshData"), object: nil)
        
        config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let label = UILabel(frame: tableView.bounds)
        label.text = "No activities"
        label.textAlignment = .center
        tableView.backgroundView = label
        
        load()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("App:BaseController:ShouldRefreshData"), object: nil)
    }
    
    // MARK: - closures
    
    // MARK: - properties
    var activities:[String] = []
    weak var delegate:DataDelegate?
    
    // MARK: - outlet
    @IBOutlet weak var tableView: UITableView!

}

extension ActivitiesController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ActivitiesCell
        let msg = activities[indexPath.row]
        cell.load(msg)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
