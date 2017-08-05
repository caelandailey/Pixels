//
//  ViewController.swift
//  pixels
//
//  Created by Caelan Dailey on 8/3/17.
//  Copyright © 2017 Caelan Dailey. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollImage: UIView!
    
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
    
//    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
//        // 1
//        let pointInView = recognizer.location(in: scrollImage)
//        
//        // 2
//        var newZoomScale = scrollView.zoomScale * 1.5
//        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
//        
//        // 3
//        let scrollViewSize = scrollView.bounds.size
//        let w = scrollViewSize.width / newZoomScale
//        let h = scrollViewSize.height / newZoomScale
//        let x = pointInView.x - (w / 2.0)
//        let y = pointInView.y - (h / 2.0)
//        
//        let rectToZoomTo = CGRect(x:x, y:y, width:w,height: h);
//        
//        // 4
//        scrollView.zoom(to: rectToZoomTo, animated: true)
//    }
//    
//    func centerScrollViewContents() {
//        let boundsSize = scrollView.bounds.size
//        var contentsFrame = scrollImage.frame
//        
//        if contentsFrame.size.width < boundsSize.width {
//            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
//        } else {
//            contentsFrame.origin.x = 0.0
//        }
//        
//        if contentsFrame.size.height < boundsSize.height {
//            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
//        } else {
//            contentsFrame.origin.y = 0.0
//        }
//        
//        scrollImage.frame = contentsFrame
//    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: 50*50, height: 50*50)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 50.0
        scrollView.zoomScale = 1.0
        
//        // 3
//        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewDoubleTapped(recognizer:)))
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        doubleTapRecognizer.numberOfTouchesRequired = 1
//        scrollView.addGestureRecognizer(doubleTapRecognizer)
//        
//        // 4
//        let scrollViewFrame = scrollView.frame
//        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
//        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
//        let minScale = min(scaleWidth, scaleHeight);
//        scrollView.minimumZoomScale = minScale;
//        
//        // 5
//        scrollView.maximumZoomScale = 1.0
//        scrollView.zoomScale = minScale;
//        
//        // 6
//        centerScrollViewContents()
       

        
        var pixels = [PixelData]()
        
        let red = PixelData(a: 255, r: 255, g: 0, b: 0)
        let green = PixelData(a: 255, r: 0, g: 255, b: 0)
        let blue = PixelData(a: 255, r: 0, g: 0, b: 255)
        
        for _ in 1...9 {
            pixels.append(red)
        }
//        for _ in 1...300 {
//            pixels.append(green)
//        }
//        for _ in 1...300 {
//            pixels.append(blue)
//        }
        
        for i in 1...50 {
            let image = UIImageView()
            image.image = imageFromBitmap(pixels: pixels, width: 3, height: 3)
            image.frame = CGRect(x: i*50, y: i*50, width: 3, height: 3)
            scrollImage.addSubview(image)
        }
        
        scrollView.addSubview(scrollImage)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

