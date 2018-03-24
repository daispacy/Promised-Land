//
//  NoticeController.swift
//  Promised Land
//
//  Created by Dai Pham on 3/24/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit

protocol NoticeControllerDelegate:class {
    func noticeControllerRequestCurrentTeam()->Team?
}

class NoticeController: UIViewController {

    // MARK: - api
    
    // MARK: - action
    func shouldReloadData(_ sender:NSNotification) {
        load()
    }
    
    // MARK: - private
    private func config() {
        
        title = "Your Messages"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NoticeCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    private func load() {
        guard let team = delegate?.noticeControllerRequestCurrentTeam() else { return }
        
        notices.removeAll()
        for station in team.station {
            if station.isFinish {
                notices.append(station)
            } else {
                notices.append(station)
                break
            }
        }
        
        if notices.count > 0 {
            notices = notices.reversed()
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
        label.text = "No messages"
        tableView.backgroundView = label
        
        load()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("App:BaseController:ShouldRefreshData"), object: nil)
    }
    
    // MARK: - closures
    
    // MARK: - properties
    var notices:[Station] = []
    weak var delegate:NoticeControllerDelegate?
    
    // MARK: - outlet
    @IBOutlet weak var tableView: UITableView!
    
}

extension NoticeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NoticeCell
        let station = notices[indexPath.row]
        cell.load(title: station.title, message: station.message, isFinish: station.isFinish)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
