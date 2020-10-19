//
//  SplashVC.swift
//  postaat
//
//  Created by ahmed abdelhameed on 5/12/20.
//  Copyright © 2020 ahmed abdelhameed. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

        override func viewDidLoad() {
            super.viewDidLoad()
            Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(self.splashTimeOut(sender:)), userInfo: nil, repeats: false)
            // Do any additional setup after loading the view.
        }

    @objc func splashTimeOut(sender : Timer){
        AppDelegate.sharedInstance().window?.rootViewController = UINavigationController(rootViewController: ViewController())
        }
    

 

}
