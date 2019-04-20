//
//  MainViewControlllerViewController.swift
//  TanksAR
//
//  Created by Vitaly Antipov on 19/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MainViewController: UIViewController, MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        self.dismiss(animated: false, completion: { self.performSegue(withIdentifier: "showGame", sender: nil) })
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func peerConnected() {
        self.performSegue(withIdentifier: "showGame", sender: nil)
        
    }

    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var indicate: UIActivityIndicatorView!
    @IBOutlet weak var labelConnecting: UITextField!
    
    @IBAction func onStartStopTapped(_ sender: Any) {
        if startStopButton.titleLabel?.text == "START" {
            startStopButton.setTitle("STOP", for: .normal)
            indicate.hidesWhenStopped = true
            indicate.startAnimating()
            joinButton.isHidden = true
            labelConnecting.isHidden = false
            
        }
        else {
            startStopButton.setTitle("START", for: .normal)
            indicate.hidesWhenStopped = true
            joinButton.isHidden = false
            indicate.stopAnimating()
            labelConnecting.isHidden = true
            
        }
        TanksService.shared().startAdvertising()
        self.performSegue(withIdentifier: "showGame", sender: nil)
    }
    @IBAction func onJoinTapped(_ sender: Any) {
        let viewController = TanksService.shared().makeBrowserViewController()
        viewController.delegate = self
        self.present(viewController, animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(peerConnected), name: Notification.Name.peerConnecting, object: nil)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
