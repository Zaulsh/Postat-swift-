//
//  PreView.swift
//  postaat
//
//  Created by Macbook Pro on 10/17/20.
//  Copyright © 2020 ahmed abdelhameed. All rights reserved.
//

import UIKit

class PreView: UIView {
    
    @IBOutlet weak var lblViewAll: UILabel!
    @IBOutlet weak var uivViewAll: UIView!
    
    @IBOutlet weak var atiProgress01: UIActivityIndicatorView!
    @IBOutlet weak var atiProgress02: UIActivityIndicatorView!
    @IBOutlet weak var atiProgress03: UIActivityIndicatorView!
    @IBOutlet weak var atiProgress04: UIActivityIndicatorView!
    
    @IBOutlet weak var uivUser: UIView!
    @IBOutlet weak var uivUserLogo: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblViewAll.layer.cornerRadius = 16.0
        uivViewAll.layer.cornerRadius = 16.0
        
        atiProgress01.startAnimating()
        atiProgress02.startAnimating()
        atiProgress03.startAnimating()
        atiProgress04.startAnimating()
        
        uivUser.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        uivUser.layer.shadowOpacity = 0.3
        uivUser.layer.shadowRadius = 3.0
        uivUser.layer.masksToBounds = false
        
        uivUserLogo.layer.cornerRadius = 25.0
        uivUserLogo.layer.borderWidth = 1.0
        uivUserLogo.layer.borderColor = UIColor(named: "color_green")?.cgColor
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
