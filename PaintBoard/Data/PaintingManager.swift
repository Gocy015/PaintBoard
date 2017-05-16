//
//  PaintingManager.swift
//  PaintBoard
//
//  Created by Gocy on 2017/5/16.
//  Copyright © 2017年 Gocy. All rights reserved.
//

import Foundation
import UIKit

class PaintingManager{
    //MARK : - Singleton
    private init(){
        
    }
    
    static private let sharedManager = PaintingManager()
    
    open class var `default` : PaintingManager{
        get{
            return sharedManager
        }
    }
    
    let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.gocy.Paintboard")!
    
    func storeLatest(image :UIImage){
        guard let jpegData = UIImageJPEGRepresentation(image, 0.8) else{
            return
        }
        let jpegUrl = url.appendingPathComponent("latest.jpeg")
        do{
            try jpegData.write(to: jpegUrl, options: .atomic)
        } catch{
            NSLog("\(error)")
        }
    }
    
    func getLatestImage() -> UIImage?{
        let jpegUrl = url.appendingPathComponent("latest.jpeg")
        
        let jpegData : Data?
        do{
            jpegData = try Data(contentsOf: jpegUrl)
        }catch {
            jpegData = nil
        }
        
        let image : UIImage?
        if let data = jpegData {
            image = UIImage(data: data)
        }else{
            image = nil
        }
        
        return image
    }
}
