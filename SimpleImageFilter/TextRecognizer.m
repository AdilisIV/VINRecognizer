//
//  TextRecognizer.m
//  SimpleImageFilter
//
//  Created by user on 9/7/17.
//  Copyright © 2017 Ski. All rights reserved.
//

//#import <Foundation/Foundation.h>
//#import "TextRecognizer.h"
//
//@implementation TextRecognizer
//
//+ (nonnull NSString *)recognizedText:(nonnull UIImage *)inputImage {
//    
//    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
//    tesseract.delegate = self;
//    tesseract.charWhitelist = @"0123456789ABCDEFGHJKLMNPRSTUVWXYZ";
//    tesseract.image = inputImage.g8_blackAndWhite;
//    [tesseract recognize];
//    
//    NSLog(@"%@", [tesseract recognizedText]);
//    
//    NSString *text = [[NSString alloc] init];
//    text = [tesseract recognizedText];
//    
//    return text;
//}
//
//- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
//    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
//}
//
//- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
//    return NO;  // return YES, if you need to interrupt tesseract before it finishes
//}
//
//
//@end
