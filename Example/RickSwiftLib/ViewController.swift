//
//  ViewController.swift
//  RickSwiftLib
//
//  Created by woshiwwy16@126.com on 02/17/2020.
//  Copyright (c) 2020 woshiwwy16@126.com. All rights reserved.
//

import UIKit
import RickSwiftLib

class ViewController: UIViewController {
    
    lazy var testView: UIView! = {
        let view = UIView()
        self.view.addSubview(view)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        testView.frame = CGRect(x: self.view.originX, y: self.view.originY, width: DeviceSize.width, height: DeviceSize.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

