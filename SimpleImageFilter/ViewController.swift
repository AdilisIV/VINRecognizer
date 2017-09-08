import UIKit
import GPUImage

class ViewController: UIViewController {
    
    @IBOutlet weak var renderView: RenderView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recognizedTextLabel: UILabel!
    
    var picture:PictureInput!
    var testImage = UIImage()
    let filters = Filters()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Filtering image for saving
        do {
            let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
            let fileURL = URL(string:"cropedImageFromCamera.png", relativeTo:documentsDir)!
            let data = try? Data(contentsOf: fileURL)
            testImage = UIImage(data: data!)!
            
            let filteredImage = filters.filteringDisplayImagePapperBold(image: testImage)
            
            /// Saving Rendered Image
            let pngImage = UIImagePNGRepresentation(filteredImage)!
            do {
                let documentDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileURL = URL(string: "renderedImageTest.png", relativeTo: documentDir)!
                try pngImage.write(to: fileURL, options: .atomic)
                
                /// Showing Rendered Image
                let data = UIImage(named: "IMG_1560.png"); //try? Data(contentsOf: fileURL)
                imageView.image = data//UIImage(data: data!)
                
            } catch {
                print("Couldn't write to file with error: \(error)")
            }
        } catch {
            print("Couldn't read file from url with error: \(error)")
        }
        
    }
    
    
    
    @IBAction func recognizeButtonTapped(_ sender: UIButton) {
        /// Racognize Image There
        let imageToRecognize = self.imageView.image!
        recognizedTextLabel.text = TextRecognizer.recognizeImage(imageToRecognize)
        
        //OpenCV.openCVImageRecognize(imageToRecognize)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let imageToSave: UIImage = self.imageView.image!
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, #selector(savePhotoCompletion), nil)
    }
    
    func savePhotoCompletion() {
        print("Image are saved!!!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
