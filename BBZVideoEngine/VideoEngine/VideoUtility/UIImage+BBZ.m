//
//  UIImage+BBZ.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/6/8.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "UIImage+BBZ.h"

@implementation UIImage (BBZ)
+ (UIImage *)imageWithData:(NSData *)data toSize:(CGSize )size {
    CGFloat maxSize = MAX(size.width, size.height);
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    NSDictionary *options = @{(__bridge id)kCGImageSourceCreateThumbnailFromImageAlways:(__bridge id)kCFBooleanTrue,
                              (__bridge id)kCGImageSourceThumbnailMaxPixelSize:[NSNumber numberWithFloat:maxSize]};
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CFRelease(sourceRef);
    return image;
    
}
@end
