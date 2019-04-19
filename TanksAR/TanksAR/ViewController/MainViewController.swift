//
//  MainViewControlllerViewController.swift
//  TanksAR
//
//  Created by Vitaly Antipov on 19/04/2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBAction func onStartTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showGame", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
