//
//  ViewController.swift
//  pixels
//
//  Created by Caelan Dailey on 8/3/17.
//  Copyright © 2017 Caelan Dailey. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollImage: UIView!
    
    var rPixel: UInt8 = 80
    var gPixel: UInt8 = 80
    var bPixel: UInt8 = 80
    
    let colorPickerHeight:CGFloat = 100
    
    struct PixelData {
        var a: UInt8 = 0
        var r: UInt8 = 0
        var g: UInt8 = 0
        var b: UInt8 = 0
    }
    
    func imageFromBitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
        assert(width > 0)
        
        assert(height > 0)
        
        let pixelDataSize = MemoryLayout<PixelData>.size
        assert(pixelDataSize == 4)
        
        assert(pixels.count == Int(width * height))
        
        let data: Data = pixels.withUnsafeBufferPointer {
            return Data(buffer: $0)
        }
        
        let cfdata = NSData(data: data) as CFData
        let provider: CGDataProvider! = CGDataProvider(data: cfdata)
        if provider == nil {
            print("CGDataProvider is not supposed to be nil")
            return nil
        }
        let cgimage: CGImage! = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * pixelDataSize,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        if cgimage == nil {
            print("CGImage is not supposed to be nil")
            return nil
        }
        return UIImage(cgImage: cgimage)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollImage
    }
    
    func loadPixels() {
        
        
        let ref = Database.database().reference()
        
        
        ref.observe(.value, with: { snapshot in
            
            for view in self.scrollImage.subviews {
                self.scrollImage.willRemoveSubview(view)
            }
            
            let enumerator = snapshot.children
            while let obj = enumerator.nextObject() as? DataSnapshot {
                
                var x = 0
                var y = 0
                var r:UInt8 = 0
                var g:UInt8 = 0
                var b:UInt8 = 0
                
                for cell in obj.children.allObjects as! [DataSnapshot] {
                    switch cell.key {
                
                    case "x": x = cell.value as! Int
                    case "y": y = cell.value as! Int
                    case "r": r = cell.value as! UInt8
                    case "g": g = cell.value as! UInt8
                    case "b": b = cell.value as! UInt8
                    default: break
                    }
                }
                
                let pixel = PixelData(a: 255, r: r, g:g, b: b)
                
                let image = UIImageView()
                image.image = self.imageFromBitmap(pixels: [pixel], width: 1, height: 1)
                image.frame = CGRect(x: x, y: y, width: 1, height: 1)
                
                
                self.scrollImage.addSubview(image)
            }
        })
    }
    func showMoreActions(touch: UITapGestureRecognizer) {
        
        let touchPoint = touch .location(in: self.scrollImage)
        
        addPixel(x: Int(touchPoint.x), y: Int(touchPoint.y))
    }
    
    func addPixel(x: Int, y: Int) {
        
        let itemRef = Database.database().reference().child("\(x),\(y)")
            
        itemRef.child("x").setValue(x)
        itemRef.child("y").setValue(y)
        itemRef.child("r").setValue(rPixel)
        itemRef.child("g").setValue(gPixel)
        itemRef.child("b").setValue(bPixel)
    }
    
    func setupColorPicker() {
        let screenWidth = self.view.frame.width
        
        let view = UIView()
        
        view.backgroundColor = UIColor.clear
        view.frame = CGRect(x: 0, y: self.view.frame.height - colorPickerHeight, width: screenWidth, height: colorPickerHeight)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        let line = UIView()
        line.backgroundColor = UIColor(red: 220, green: 220, blue: 220)
        line.frame  = CGRect(x: 0, y: 0, width: view.frame.size.width,height: 1)
        
        addColorButton(color: 0x000000, view: view, pos: 0) // Black
        addColorButton(color: 0xcccccc, view: view, pos: 2) // Gray
        addColorButton(color: 0xffffff, view: view, pos: 1) // White
        addColorButton(color: 0xFFC0CB, view: view, pos: 3) // Pink
        addColorButton(color: 0xff00ff, view: view, pos: 9) // Purple
        addColorButton(color: 0xff0000, view: view, pos: 5) // Red
        addColorButton(color: 0xffa500, view: view, pos: 6) // Orange
        addColorButton(color: 0x00ff00, view: view, pos: 7) // Green
        addColorButton(color: 0xffff00, view: view, pos: 8) // Yellow
        addColorButton(color: 0x0000ff, view: view, pos: 4) // Blue
        
        view.addSubview(line)
        self.view.addSubview(view)
    }
    
    private func addColorButton(color: Int, view: UIView, pos: Int) {
        
        let button = UIButton()
        let size = 35
        let height = Int(view.frame.size.height)
        let columnCount = 5
        let rowCount = 2
        
        let x = ((pos % columnCount) + 1 ) * ( (Int(self.view.frame.width) - (columnCount*size) )/(columnCount+1)) + (size * (pos % columnCount))
        let yOffset1 = (Int(pos/columnCount) + 1) * (height - rowCount*size) / (rowCount+1)
        let yOffset2 = size * Int(pos / columnCount)
        let y = yOffset1 + yOffset2
        
        button.frame = CGRect(x: x, y: y, width: size, height: size)
        button.backgroundColor = UIColor(rgb: color)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.addTarget(self, action: #selector(setColor), for: .touchUpInside)
        view.addSubview(button)
        
    }
    
    func setColor(sender: UIButton) {
        
        if let color = sender.backgroundColor?.rgb() {
            rPixel = color.red
            gPixel = color.green
            bPixel = color.blue
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupColorPicker()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMoreActions))
        tap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tap)
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 50.0
        scrollView.zoomScale = 1.0
        
        loadPixels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

