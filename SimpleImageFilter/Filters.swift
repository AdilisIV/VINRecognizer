//
//  Filters.swift
//  SimpleImageFilter
//
//  Created by user on 9/7/17.
//  Copyright © 2017 Sunset Lake Software LLC. All rights reserved.
//

import UIKit
import GPUImage

class Filters: NSObject {

    
    func exposureFilter(coeff: Float) -> ExposureAdjustment {
        let filter = ExposureAdjustment()
        filter.exposure = coeff //0.6 1.3
        return filter
    }
    
    func contrastFilter(coeff: Float) -> ContrastAdjustment {
        let filter = ContrastAdjustment()
        filter.contrast = coeff //3.5 4.0
        return filter
    }
    
    func adaptiveThresholdFilter(coeff: Float) -> AdaptiveThreshold {
        let filter = AdaptiveThreshold()
        filter.blurRadiusInPixels = coeff // 2.0
        return filter
    }
    
    let erosionFilter = Erosion() // расширяет темные области
    let dilationFilter = Dilation() // расширяет светлые области
    
    
    public func filteringDisplayImageBold(image: UIImage) -> UIImage {
        let grayImage = OpenCV.cvtColorBGR2GRAY(image)
        
        let filteredImage = grayImage.filterWithPipeline({ (input, output) in
            input --> exposureFilter(coeff: 1.5) --> contrastFilter(coeff: 4.0) --> adaptiveThresholdFilter(coeff: 2.0) --> output
            input.processImage()
        })
        
        let threshFilteredImage = OpenCV.imageThreshold(filteredImage)
        
        return threshFilteredImage
    }
    
    public func filteringDisplayImageDim(image: UIImage) -> UIImage {
        let grayImage = OpenCV.cvtColorBGR2GRAY(image)
        
        let filteredImage = grayImage.filterWithPipeline({ (input, output) in
            input --> exposureFilter(coeff: 0.6) --> contrastFilter(coeff: 4.0) --> adaptiveThresholdFilter(coeff: 2.0) --> output
            input.processImage()
        })
        
        let threshFilteredImage = OpenCV.imageThreshold(filteredImage)
        
        return threshFilteredImage
    }
    
    public func filteringDisplayImageExtraDim(image: UIImage) -> UIImage {
        let grayImage = OpenCV.cvtColorBGR2GRAY(image)
        
        let filteredImage = grayImage.filterWithPipeline({ (input, output) in
            input --> exposureFilter(coeff: 0.7) --> erosionFilter --> adaptiveThresholdFilter(coeff: 2.0) --> output
            input.processImage()
        })
        
        let threshFilteredImage = OpenCV.imageThreshold(filteredImage)
        
        return threshFilteredImage
    }
    
    public func filteringDisplayImagePapper(image: UIImage) -> UIImage {
        
        let filteredImage = image.filterWithPipeline({ (input, output) in
            input --> adaptiveThresholdFilter(coeff: 2.0) --> exposureFilter(coeff: 0.4) --> contrastFilter(coeff: 1.5) --> output
            input.processImage()
        })
        
        let threshFilteredImage = OpenCV.originaDocumentThreshold(filteredImage)
        
        return threshFilteredImage
    }
    
    public func filteringDisplayImagePapperBold(image: UIImage) -> UIImage {
        
        let filteredImage = image.filterWithPipeline({ (input, output) in
            input --> dilationFilter --> adaptiveThresholdFilter(coeff: 1.0) --> contrastFilter(coeff: 4.0) --> output
            input.processImage()
        })
        
        let threshFilteredImage = OpenCV.originaDocumentThreshold(filteredImage)
        
        return threshFilteredImage
    }
    
}
