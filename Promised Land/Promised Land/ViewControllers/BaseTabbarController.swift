//
//  BaseTabbarController.swift
//  Promised Land
//
//  Created by Dai Pham on 3/24/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

class BaseTabbarController: UITabBarController {

    // MARK: - api
    func getStation(from team:Team) {
        
        if currentStation != nil {
            print("Mark old region isFinish")
            currentStation!.isFinish = true
            MonitorLocation.shared.stopMonitoring()
            MonitorLocation.shared.clCircularRegions.removeAll()
            if let team = self.team {
                for (i,st) in team.station.enumerated() {
                    if st.id == currentStation!.id {
                        team.station[i] = currentStation!
                        self.team = team
                        Support.setCacheTeam(data: team.toDict())
                        print("set cache success \(team.countStationFinish())")
                        currentStation = nil
                        break
                    }
                }
            }
        }
        
        for station in team.station {
            if station.isFinish {
                continue
            }
            
            if let _ = station.location {
                currentStation = station
                print("prepare next location. start show message")
                guard let st = currentStation else {
                    // should show message end Game
                    break
                }
                self.showMessage(title: st.title, message: st.message,isStart: true)
                break
            }
        }
        
        // go over all region
        if currentStation == nil {
            // should show message end Game
            self.dismiss(animated: false, completion: nil)
            AudioServicesPlayAlertSound(SystemSoundID(1322))
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.banner.transform = .identity
            }, completion: nil)
        }
    }
    
    // MARK: - private
    fileprivate func showMessage(title:String, message:String,isStart:Bool) {
        self.dismiss(animated: false, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name("App:BaseController:ShouldRefreshData"), object: nil)
        let vc = MessageController(nibName: "MessageController", bundle: Bundle.main)
        vc.titleMessage = title
        vc.message = message
        vc.shouldShowStartButton = isStart
        vc.delegate = self
        self.present(vc, animated: false, completion: nil)
    }
    
    private func  listernEvent() {
        
        let appdelegate =  UIApplication.shared.delegate as! AppDelegate
        appdelegate.onWillEnterForceground = {[weak self] in
            guard let _self = self else {return}
            _self.monitorEvent()
        }
        
        appdelegate.onOpenAppFromNotification = {[weak self] in
            guard let _self = self, let team = _self.team else {return}
            _self.getStation(from: team)
        }
    }
    
    private func monitorEvent() {
        MonitorLocation.shared.onDidEnterRegion = {[weak self] in
            guard let _self = self, let team = _self.team else {return}
            _self.getStation(from: team)
        }
    }
    
    private func config() {
        createBanner()
    }
    
    private func createBanner() {
        banner = BannerNoticeView(frame: view.bounds)
        view.addSubview(banner)
        view.bringSubview(toFront: banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        banner.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        banner.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        banner.transform = CGAffineTransform(translationX: 0, y: -banner.frame.size.height)
    }
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        monitorEvent()
        listernEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.team == nil {
            if let json = Support.getCacheTeam, let tt = Team.parseFromJSON(json) {
                self.team = tt
            }
        }
        
        guard let team = self.team else {
            Support.changeRootControllerTo(viewcontroller: UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "teamController"))
            return
        }
        
        getStation(from: team)
    }
    
    // MARK: - closures
    
    // MARK: - properties
    var currentStation:Station?
    var team:Team?
    var banner:BannerNoticeView!
}

// MARK: -
extension BaseTabbarController:MapControllerDelegate {
    func mapControllerShowMessage() {
        guard let station = currentStation else { return }
        self.showMessage(title: station.title, message: station.message, isStart: true)
    }
}

// MARK: -
extension BaseTabbarController:NoticeControllerDelegate,ScoreControllerDelegate {
    func noticeControllerRequestCurrentTeam() -> Team? {
        return self.team
    }
    
    func scoreControllerRequestCurrentTeam() -> Team? {
        return self.team
    }
}

// MARK: -
extension BaseTabbarController:MesssageControllerDelegate {
    
    func messageControllerStart() {
        print("start tracking current station")
        
        guard let station = currentStation, let location = station.location else { return }
        MonitorLocation.shared.stopMonitoring()
        let region = CLCircularRegion(center: CLLocationCoordinate2DMake(location.latitude, location.longitude), radius: 200, identifier: CURRENT_REGION)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        MonitorLocation.shared.clCircularRegions = [region]
        MonitorLocation.shared.startMonitoring()
    }
    
    func messageControllerShouldMinimize() {
        print("minimize question")
        NotificationCenter.default.post(name: NSNotification.Name("App:MapController:ShowQuestionButton"), object: nil)
    }
    
    func messageControllerExitZone() {
        
    }
}
