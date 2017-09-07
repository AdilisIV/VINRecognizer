//
//  VersionViewController.swift
//  OpenCVSample_iOS
//
//  Created by user on 8/29/17.
//  Copyright © 2017 Ski. All rights reserved.
//

import UIKit

class VersionViewController: UIViewController {
    
    @IBOutlet weak var openVCVersionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        openVCVersionLabel.text = OpenCV.openCVVersionString()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
