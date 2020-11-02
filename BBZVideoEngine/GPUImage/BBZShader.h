//
//  BBZShader.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/28.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BBZShader : NSObject
//vertex
+ (NSString *)vertextShader;

+ (NSString *)vertextTransfromShader;


//fragment
+ (NSString *)fragmentPassthroughShader;

+ (NSString *)fragmentYUV420FTransfromShader;

+ (NSString *)fragmentRGBTransfromShader;

+ (NSString *)fragmentFBFectchYUV420FTransfromShader;

+ (NSString *)fragmentFBFectchRGBTransfromShader;

+ (NSString *)fragmentMaskBlendShader;

+ (NSString *)fragmentMaskBlendVideoShader;

+ (NSString *)fragmentLutShader;

@end


