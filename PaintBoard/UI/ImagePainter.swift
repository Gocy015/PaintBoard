//
//  ImagePainter.swift
//  PaintBoard
//
//  Created by Gocy on 2017/5/15.
//  Copyright © 2017年 Gocy. All rights reserved.
//

import UIKit

class ImagePainter: UIView {

    //MARK: - Properties ,UI
    fileprivate let imageView = UIImageView()
    fileprivate let paintLayer = CAShapeLayer()
    fileprivate let defaultLineWidth : CGFloat = 6.0
    
    //MARK: - Propertis ,Data
    var image : UIImage?{
        didSet{
            imageView.image = image
            resizeImageView(size: image?.size ?? .zero)
        }
    }
    var paintedImage : UIImage? {
        get{
            if paintPath == nil{
                return image
            }
            return getPaintedImage()
        }
    }
    private var paintPath : UIBezierPath!
    private(set) var pointsList = [[CGPoint]]()
    private var resizeRatio : CGFloat = 1.0
    
    //MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    convenience init() {
        self.init(frame: .zero)
    }
    private func initialize(){
        self.addSubview(imageView)
        self.layer.addSublayer(paintLayer)
        
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        paintLayer.strokeColor = UIColor.red.cgColor
        paintLayer.fillColor = UIColor.clear.cgColor
        paintLayer.lineWidth = defaultLineWidth
        paintLayer.lineCap = kCALineCapRound
        paintLayer.lineJoin = kCALineJoinRound
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(pan:)))
        imageView.addGestureRecognizer(pan)
        imageView.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        paintLayer.frame = self.bounds
    }
    
    func resetPainting(withData list:[[CGPoint]] = []){
        paintPath = nil
        pointsList.removeAll()
        if list.count > 0{
            paintPath = bezierPath(withPointList: list)
            pointsList = list
        }
        draw()
    }
    
    @discardableResult func tryUndo() -> Bool{
        if pointsList.count <= 0 {
            return false
        }
        pointsList.removeLast()
        paintPath = bezierPath(withPointList: pointsList)
        draw()
        return true
    }
    
    private func resizeImageView(size s:CGSize){
        resizeRatio = 1.0
        var size = s
        let ratio = s.width / s.height
        
        if size.width > self.bounds.size.width { // too wide
            size.width = self.bounds.size.width
            size.height = size.width / ratio
            
            resizeRatio = s.width / self.bounds.size.width
        }
        
        if size.height > self.bounds.size.height{
            size.height = self.bounds.size.height
            size.width = size.height * ratio
            
            resizeRatio = s.height / self.bounds.size.height
        }
        
        imageView.frame = CGRect(x: self.center.x - size.width/2, y: 0, width: size.width, height: size.height)
    }
    
    //MARK: - Gesture
    @objc private func didPan(pan:UIPanGestureRecognizer){
        if pan.state == .began || pan.state == .changed{
            let p = pan.location(in: imageView)
            addPoint(point: p ,stroke: pan.state == .changed)
        }
    }
    
    //MARK: - Paint Logic
    private func addPoint(point:CGPoint ,stroke:Bool){
        if !imageView.frame.contains(point) {
            return
        }
        if paintPath == nil {
            paintPath = UIBezierPath()
        }
        if !stroke {
            paintPath.move(to: point)
//            resizedPaintPath.move(to: CGPoint(x: point.x * resizeRatio ,y : point.y * resizeRatio))
            pointsList.append([point])
        }else{
            paintPath.addLine(to: point)
//            resizedPaintPath.addLine(to: CGPoint(x: point.x * resizeRatio ,y : point.y * resizeRatio))
            if pointsList.count > 0{
                pointsList[pointsList.endIndex - 1].append(point)
            }
        }
        draw()
    }
    
    private func draw(){
        paintLayer.path = paintPath?.cgPath
    }
    
    private func getPaintedImage() -> UIImage?{
        guard let original = image else{
            return nil
        }
        
        guard let resizedPaintPath = bezierPath(withPointList: pointsList ,ratioFactor: resizeRatio) else{
            return nil
        }
        resizedPaintPath.lineJoinStyle = .round
        resizedPaintPath.lineCapStyle = .round
        resizedPaintPath.lineWidth = defaultLineWidth * resizeRatio
        
        UIGraphicsBeginImageContext(original.size)
        original.draw(in: CGRect(x: 0, y: 0, width: original.size.width, height: original.size.height))
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setFillColor(UIColor.clear.cgColor)
        resizedPaintPath.stroke()
        
        let painted = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return painted
    }
    
    
    //MARK : - Helpers
    func bezierPath(withPointList list:[[CGPoint]] ,ratioFactor factor:CGFloat = 1) -> UIBezierPath?{
        let path = UIBezierPath()
        for points in list{
            if points.count < 0 {
                return nil
            }
            path.move(to: CGPoint(x :points.first!.x * factor ,y :points.first!.y * factor))
            
            for index in 1 ..< points.endIndex {
                path.addLine(to:CGPoint(x :points[index].x * factor ,y :points[index].y * factor))
            }
        }
        return path
    }
}
