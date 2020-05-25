//
//  BBZSourceAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//


#import "BBZAction.h"
#import "BBZBaseAsset.h"
#import "GPUImageFramebuffer.h"
#import "GPUImageFilter.h"

@interface BBZOutputSourceParam : NSObject
@property (nonatomic, strong) NSArray *arrayFrameBuffer;
@property (nonatomic, assign) BOOL bVideoSource;
@property (nonatomic, assign) GPUMatrix3x3 mat33ParamValue;
@property (nonatomic, assign) GPUVector4 vector4ParamValue;
@end

@protocol BBZOutputSourceProtocol <NSObject>

- (BBZOutputSourceParam *)outputSourceAtTime:(CMTime)time;

@end

@interface BBZSourceAction : BBZAction<BBZOutputSourceProtocol>

@property (nonatomic, strong) BBZBaseAsset *asset;
@property (nonatomic, assign) CGSize renderSize;
@property (nonatomic, assign) CGFloat scale;


@end


