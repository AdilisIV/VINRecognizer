import UIKit
import GPUImage

class ViewController: UIViewController {
    
    @IBOutlet weak var renderView: RenderView!
    @IBOutlet weak var imageView: UIImageView!

    var picture:PictureInput!
    var testImage = UIImage()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Filtering image for saving
        do {
            let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
            let fileURL = URL(string:"cropedImageFromCamera.png", relativeTo:documentsDir)!
            let data = try? Data(contentsOf: fileURL)
            testImage = UIImage(data: data!)!
            
//            /// Image Output
//            imageView.image = testImage
            
            /// Image Filtering
//            let cropFilter = Crop()
//            let sizeInPixels = Size.init(width: 400.0, height: 48.0)
//            cropFilter.cropSizeInPixels = sizeInPixels
            
            let myfilter2 = AdaptiveThreshold()
            myfilter2.blurRadiusInPixels = 2.0
            
            let highlightsFilter = HighlightsAndShadows()
            highlightsFilter.highlights = 3.0
            
            let exposureFilter = ExposureAdjustment()
            exposureFilter.exposure = 0.9 // 0.9
            
            let contrastFilter = ContrastAdjustment()
            contrastFilter.contrast = 4.0 // 4.0
            
            let saturationFilter = SaturationAdjustment()
            saturationFilter.saturation = 0.0
            
            //let erosionFilter = Erosion() // расширяет темные области
            //let dilationFilter = Dilation() // расширяет светлые области
            
            let grayImage = OpenCV.cvtColorBGR2GRAY(testImage)
            
            let filteredImage = grayImage.filterWithPipeline({ (input, output) in
                input --> exposureFilter --> contrastFilter --> myfilter2 --> output
                input.processImage()
            })
            
            let threshFilteredImage = OpenCV.imageThreshold(filteredImage)
            
            /// Saving Rendered Image
            let pngImage = UIImagePNGRepresentation(threshFilteredImage)!
            do {
                let documentDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = URL(string: "renderedImageTest.png", relativeTo: documentDir)!
                try pngImage.write(to: fileURL, options: .atomic)
                
                /// Showing Rendered Image
                let data = try? Data(contentsOf: fileURL)
                imageView.image = UIImage(data: data!)
                
            } catch {
                print("Couldn't write to file with error: \(error)")
            }
        } catch {
            print("Couldn't read file from url with error: \(error)")
        }

        
        
//        // Filtering image for display
//        picture = PictureInput(image:UIImage(named:"full_CTC.jpg")!)
//        
//        let myfilter2 = AdaptiveThreshold()
//        myfilter2.blurRadiusInPixels = 2.0
//        
//        let highlightsFilter = HighlightsAndShadows()
//        highlightsFilter.highlights = 3.0
//        
//        let exposureFilter = ExposureAdjustment()
//        exposureFilter.exposure = 0.9
//        
//        let contrastFilter = ContrastAdjustment()
//        contrastFilter.contrast = 4.0
//        
//        let saturationFilter = SaturationAdjustment()
//        saturationFilter.saturation = 0.0
//        
//        let smoothToonFilter = SmoothToonFilter()
//        
//        picture --> exposureFilter --> contrastFilter --> saturationFilter --> myfilter2 --> renderView
//        picture.processImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
