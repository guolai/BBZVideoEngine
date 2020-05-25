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

@interface BBZInputSourceParam : NSObject
@property (nonatomic, strong) NSArray *arrayFrameBuffer;
@property (nonatomic, assign) BOOL bVideoSource;
@property (nonatomic, assign) GPUMatrix3x3 mat33ParamValue;
@property (nonatomic, assign) GPUVector4 vector4ParamValue;
@end

@protocol BBZInputSourceProtocol <NSObject>

- (BBZInputSourceParam *)inputSourceAtTime:(CMTime)time;

@end

@interface BBZSourceAction : BBZAction<BBZInputSourceProtocol>

@property (nonatomic, strong) BBZBaseAsset *asset;
@property (nonatomic, assign) CGSize renderSize;
@property (nonatomic, assign) CGFloat scale;


@end


