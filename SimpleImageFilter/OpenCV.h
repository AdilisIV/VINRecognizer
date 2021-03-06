//
//  OpenCV.h
//  OpenCVSample_iOS
//
//  Created by Ilia Fedorov on 2015/08/12.
//  Copyright (c) Ski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenCV : NSObject

/// Converts a full color image to grayscale image with using OpenCV.
+ (nonnull UIImage *)cvtColorBGR2GRAY:(nonnull UIImage *)image;

+ (nonnull UIImage *)imageThreshold:(nonnull UIImage *)image;

+ (nonnull NSString *) openCVVersionString;

@end
