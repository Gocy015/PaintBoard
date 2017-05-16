//
//  TodayViewController.swift
//  PaintBoardWidget
//
//  Created by Gocy on 2017/5/16.
//  Copyright © 2017年 Gocy. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var msgLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
        msgLabel.text = "Oops..nothing yet."
        if let latestImage = PaintingManager.default.getLatestImage() {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            imageView.image = latestImage
            msgLabel.text = "Check out your latest painting!"
        }
        
        //TODO: resize image view automatically.
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0
        imageView.layer.cornerRadius = 10
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            self.preferredContentSize = CGSize(width: 0, height: 90)
            UIView.animate(withDuration: 0.25){
                self.imageView.alpha = 0
            }
        default:
            self.preferredContentSize = CGSize(width: 0, height: 220)
            UIView.animate(withDuration: 0.25){
                self.imageView.alpha = 1
            }
        }
    }
}
