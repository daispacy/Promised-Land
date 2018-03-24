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
                        let noticeVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "noticeController") as! NoticeController
                        let nvNoticeVC = UINavigationController(rootViewController: noticeVC)
                        
                        let scoreVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "scoreController") as! ScoreController
                        
                        let itemMap = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "map").resizeImageWith(newSize: CGSize(width: 40, height: 40)).tint(with: #colorLiteral(red: 0.4352941215, green: 0.4431372583, blue: 0.4745098054, alpha: 1)), selectedImage:#imageLiteral(resourceName: "map").resizeImageWith(newSize: CGSize(width: 40, height: 40)).tint(with: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)))
                        mapVC.tabBarItem  = itemMap
                        
                        let itemMessage = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "question").resizeImageWith(newSize: CGSize(width: 40, height: 40)).tint(with: #colorLiteral(red: 0.4352941215, green: 0.4431372583, blue: 0.4745098054, alpha: 1)), selectedImage:#imageLiteral(resourceName: "question").resizeImageWith(newSize: CGSize(width: 40, height: 40)).tint(with: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)))
                        nvNoticeVC.tabBarItem  = itemMessage
                        
                        let itemGoal = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "goal").resizeImageWith(newSize: CGSize(width: 35, height: 35)).tint(with: #colorLiteral(red: 0.4352941215, green: 0.4431372583, blue: 0.4745098054, alpha: 1)), selectedImage:#imageLiteral(resourceName: "goal").resizeImageWith(newSize: CGSize(width: 35, height: 35)).tint(with: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)))
                        scoreVC.tabBarItem  = itemGoal
                        
                        let tc = BaseTabbarController()
                        mapVC.delegate = tc
                        noticeVC.delegate = tc
                        scoreVC.delegate = tc
                        
                        if #available(iOS 11.0, *) {
                            if UI_USER_INTERFACE_IDIOM() != .pad {
                                mapVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
                                nvNoticeVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
                                scoreVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
                            }
                        } else {
                            mapVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
                            nvNoticeVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
                            scoreVC.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
                        }
                        
                        mapVC.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear], for: UIControlState())
                        nvNoticeVC.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear], for: UIControlState())
                        scoreVC.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear], for: UIControlState())
                        
                        tc.setViewControllers([mapVC,nvNoticeVC,scoreVC], animated: true)
                        Support.changeRootControllerTo(viewcontroller: tc, animated: true, nil)
                    }
                })
            }
        }
    }
}
