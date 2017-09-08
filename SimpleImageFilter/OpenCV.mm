//
//  OpenCV.m
//  OpenCVSample_iOS
//
//  Created by Ilia Fedorov on 2015/08/12.
//  Copyright (c) Ski. All rights reserved.
//

// Put OpenCV include files at the top. Otherwise an error happens.
#import <vector>
#import <string>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/text.hpp>
#import <opencv2/text/ocr.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/core/utility.hpp>
#import <iostream>

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "OpenCV.h"

/// Converts an UIImage to Mat.
/// Orientation of UIImage will be lost.
static void UIImageToMat(UIImage *image, cv::Mat &mat) {

    // Create a pixel buffer.
    NSInteger width = CGImageGetWidth(image.CGImage);
    NSInteger height = CGImageGetHeight(image.CGImage);
    CGImageRef imageRef = image.CGImage;
    cv::Mat mat8uc4 = cv::Mat((int)height, (int)width, CV_8UC4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(mat8uc4.data, mat8uc4.cols, mat8uc4.rows, 8, mat8uc4.step, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Draw all pixels to the buffer.
    cv::Mat mat8uc3 = cv::Mat((int)width, (int)height, CV_8UC3);
    cv::cvtColor(mat8uc4, mat8uc3, CV_RGBA2BGR);
    
    mat = mat8uc3;
}

static void UIDocumentImageToMat(UIImage *image, cv::Mat &mat) {
    
    // Create a pixel buffer.
    NSInteger width = CGImageGetWidth(image.CGImage);
    NSInteger height = CGImageGetHeight(image.CGImage);
    CGImageRef imageRef = image.CGImage;
    cv::Mat mat8uc4 = cv::Mat((int)height, (int)width, CV_8UC4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(mat8uc4.data, mat8uc4.cols, mat8uc4.rows, 8, mat8uc4.step, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Draw all pixels to the buffer.
    cv::Mat mat8uc3 = cv::Mat((int)width, (int)height, CV_8UC1);
    cv::cvtColor(mat8uc4, mat8uc3, CV_RGBA2GRAY);
    
    mat = mat8uc3;
}

/// Converts a Mat to UIImage.
static UIImage *MatToUIImage(cv::Mat &mat) {
    
    // Create a pixel buffer.
    assert(mat.elemSize() == 1 || mat.elemSize() == 3);
    cv::Mat matrgb;
    if (mat.elemSize() == 1) {
        cv::cvtColor(mat, matrgb, CV_GRAY2RGB);
    } else if (mat.elemSize() == 3) {
        cv::cvtColor(mat, matrgb, CV_BGR2RGB);
    }
    
    // Change a image format.
    NSData *data = [NSData dataWithBytes:matrgb.data length:(matrgb.elemSize() * matrgb.total())];
    CGColorSpaceRef colorSpace;
    if (matrgb.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(matrgb.cols, matrgb.rows, 8, 8 * matrgb.elemSize(), matrgb.step.p[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

/// Restore the orientation to image.
static UIImage *RestoreUIImageOrientation(UIImage *processed, UIImage *original) {
    if (processed.imageOrientation == original.imageOrientation) {
        return processed;
    }
    return [UIImage imageWithCGImage:processed.CGImage scale:1.0 orientation:original.imageOrientation];
}


@implementation OpenCV


+ (nonnull UIImage *)cvtColorBGR2GRAY:(nonnull UIImage *)image {
    cv::Mat bgrMat;
    UIImageToMat(image, bgrMat);
    cv::Mat grayMat;
    cv::cvtColor(bgrMat, grayMat, CV_BGR2GRAY);
    UIImage *grayImage = MatToUIImage(grayMat);
    return RestoreUIImageOrientation(grayImage, image);
}



+ (NSString *) openCVImageRecognize:(UIImage *)image {
    cv::Mat bgrMat;
    UIImageToMat(image, bgrMat);
    NSString *outputString = [[NSString alloc] init];
    
    std::string vocabulary = "0123456789ABCDEFGHJKLMNPRSTUVWXYZ";
    std::vector<std::string> lexicon;
    lexicon.push_back(std::string("FX"));
    cv::Mat transition_p;
    cv::text::createOCRHMMTransitionsTable(vocabulary, lexicon, transition_p);
    
    cv::Mat emission_p = cv::Mat::eye(62, 62, CV_64FC1);
    
    cv::text::OCRBeamSearchDecoder ocr;
    ocr.create(cv::text::loadOCRBeamSearchClassifierCNN("OCRBeamSearch_CNN_model_data.xml"), vocabulary, transition_p, emission_p);
    
    std::string output;
    std::vector<Rect> boxes;
    std::vector<std::string> words;
    std::vector<float> confidences;
    
    ocr.run(bgrMat, output);
    std::cout << "OCR output = " << output << ". Decoded!";
    
    return outputString;
}



//+ (NSString *) openCVTextRecognize:(UIImage *)image {
//    cv::Mat bgrMat;
//    UIImageToMat(image, bgrMat);
//    NSString *outputString = [[NSString alloc] init];
//    //cv::text::BaseOCR::run(bgrMat, outputString);
//    cv::text::loadOCRHMMClassifierNM("OCRHMM_knn_model_data.xml");
//    cv::text::OCRHMMDecoder::ClassifierCallback callback;
//    std::vector<int> out_classes;
//    std::vector<double> out_confidences;
//    callback.eval(bgrMat, out_classes, out_confidences);
//    
//    return outputString;
//}

+ (nonnull UIImage *)imageThreshold:(nonnull UIImage *)image {
    cv::Mat bgrMat;
    UIImageToMat(image, bgrMat);
    cv::Mat threshMat;
    cv::threshold(bgrMat, threshMat, 127, 255, CV_THRESH_BINARY);
    UIImage *threshImage = MatToUIImage(threshMat);
    return RestoreUIImageOrientation(threshImage, image);
}


+ (nonnull UIImage *)originaDocumentThreshold:(nonnull UIImage *)image {
    cv::Mat bgrMat;
    UIDocumentImageToMat(image, bgrMat);
    cv::Mat threshMat;
    cv::adaptiveThreshold(bgrMat, threshMat, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 11, 2);
    UIImage *threshImage = MatToUIImage(threshMat);
    
    return RestoreUIImageOrientation(threshImage, image);
}








+(NSString *) openCVVersionString {
    return [NSString stringWithFormat: @"OpenCV Version: %s", CV_VERSION];
}


- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


@end



@implementation TextRecognizer

+ (nonnull NSString *)recognizeImage:(nonnull UIImage *)inputImage {
    
    NSString *tesseractVersion = [G8Tesseract version];
    NSLog(@"Tesseract Version: %@", tesseractVersion);
    
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.engineMode = G8OCREngineModeTesseractOnly;
    tesseract.delegate = self;
    tesseract.charWhitelist = @"0123456789ABCDEFGHJKLMNPRSTUVWXYZ";
    tesseract.image = inputImage.g8_blackAndWhite;
    [tesseract recognize];
    
    NSLog(@"%@", [tesseract recognizedText]);
    
    NSString *text = [[NSString alloc] init];
    text = [tesseract recognizedText];
    
    return text;
}

- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}


@end
