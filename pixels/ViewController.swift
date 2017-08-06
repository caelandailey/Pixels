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
    
    let pixelSize = 2
    
    //var pixels = [PixelData]()
    
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
            
            let enumerator = snapshot.children
            while let obj = enumerator.nextObject() as? DataSnapshot {

                var x = 0
                var y = 0
                var size = 1
                
                    for cell in obj.children.allObjects as! [DataSnapshot] {
                        print (cell)
                    switch cell.key {
                        case "color": break
                        case "x": x = cell.value as! Int
                        case "y": y = cell.value as! Int
                        case "size": size = cell.value as! Int
                    default: break
                    }
                }
            
                let color = UIColor(red: 155, green: 155, blue: 155)
                if let rgbColor = color.rgb() {
                    
                    
                    
                    var pixels = [PixelData]()
                    let pixel = PixelData(a: 255, r: rgbColor.red, g:rgbColor.green, b: rgbColor.blue)
                    
                    for _ in 1...size*size {
                        
                        pixels.append(pixel)
                    }
                    
                    
                    
                    
                    let image = UIImageView()
                    image.image = self.imageFromBitmap(pixels: pixels, width: size, height: size)
                    image.frame = CGRect(x: x, y: y, width: size, height: size)
                    self.scrollImage.addSubview(image)
                }

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
        itemRef.child("size").setValue(pixelSize)
        itemRef.child("color").setValue(121212)
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(showMoreActions))
        tap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tap)
        
        scrollView.contentSize = CGSize(width: 50*50, height: 50*50)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 50.0
        scrollView.zoomScale = 1.0
        
        loadPixels()
        
      
        
//        let red = PixelData(a: 255, r: 255, g: 0, b: 0)
//        let green = PixelData(a: 255, r: 0, g: 255, b: 0)
//        let blue = PixelData(a: 255, r: 0, g: 0, b: 255)
//        
//        for _ in 1...900 {
//            pixels.append(red)
//        }
//        for _ in 1...300 {
//            pixels.append(green)
//        }
//        for _ in 1...300 {
//            pixels.append(blue)
//        }
        
//        for i in 1...50 {
//            let image = UIImageView()
//            print(pixels.count)
//            image.image = imageFromBitmap(pixels: pixels, width: 30, height: 30)
//            image.frame = CGRect(x: i*50, y: i*50, width: 30, height: 30)
//            scrollImage.addSubview(image)
//        }
//        
        //scrollView.addSubview(scrollImage)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

