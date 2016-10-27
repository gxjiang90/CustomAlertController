//
//  ViewController.swift
//  CTAlertViewControl
//
//  Created by JiangGuoxi on 16/5/25.
//  Copyright © 2016年 JiangGuoxi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        let b1 = UIButton()
        b1.frame = CGRectMake(100, 100, 100, 40)
        b1.backgroundColor = UIColor.blueColor()
        view.addSubview(b1)
        b1.addAction({[weak self] (con) in
                self?.click()
            }, forControlEvents: .TouchUpInside)
        
        
    }

    func click() {
        let alert = CTAlertController(title: "这是个标题", message: "这是一个message", preferredStyle: .Alert)
        alert.addAction(CTAlertAction(title: "按钮1", style: .Destructive, handler: { (action) in
            print("按钮1click")
        }))
        alert.addAction(CTAlertAction(title: "取消", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    


}

