//
//  BBZNode.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BBZFilterTransformSource;
extern NSString *const BBZFilterBlendImage;
extern NSString *const BBZFilterBlendVideo;
extern NSString *const BBZFilterBlendVideoAndImage;
extern NSString *const BBZFilterTransition;
extern NSString *const BBZFilterSplice;
extern NSString *const BBZFilterLut;




@interface BBZNodeAnimationParams : NSObject <NSCopying>
@property (nonatomic, assign) CGFloat param1;
@property (nonatomic, assign) CGFloat param2;
@property (nonatomic, assign) CGFloat param3;
@property (nonatomic, assign) CGFloat param4;
@property (nonatomic, assign) CGFloat param5;
@property (nonatomic, assign) CGFloat param6;
@property (nonatomic, assign) CGFloat param7;
@property (nonatomic, assign) CGFloat param8;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end

@interface BBZNodeAnimation : NSObject<NSCopying>
@property (nonatomic, assign) double begin;
@property (nonatomic, assign) double end;
@property (nonatomic, strong) BBZNodeAnimationParams *param_begin;
@property (nonatomic, strong) BBZNodeAnimationParams *param_end;

- (instancetype)initWithDictionary:(NSDictionary *)dic;



@end

@interface BBZNode : NSObject
/*
 <action begin="0.00" end="10.00" name="blend" repeat="1" attenment="mask.mp4" order="1"/>
 <action begin="0.000" end="0.3" name="image" fshader="heichang.glsl">
*/
@property (nonatomic, assign) double begin;
@property (nonatomic, assign) double end;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) NSInteger repeat;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fShader;
@property (nonatomic, strong) NSString *vShader;
@property (nonatomic, strong, readonly) NSString *vShaderString;
@property (nonatomic, strong, readonly) NSString *fShaderString;
@property (nonatomic, strong) NSString *scale_mode;
@property (nonatomic, strong) NSString *attenmentFile;
@property (nonatomic, strong, readonly) NSString *filePath;
@property (nonatomic, strong) NSArray<BBZNodeAnimation *> *animations;



//
@property (nonatomic, assign) BOOL bRGB;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSArray *images;
//@property (nonatomic, assign) double offset;

- (instancetype)initWithDictionary:(NSDictionary *)dic withFilePath:(NSString *)filePath;

- (BBZNodeAnimationParams *)paramsAtTime:(double)time;

- (CMTime)relativeTimeFromActionTime:(CMTime)actionTime;

@end


