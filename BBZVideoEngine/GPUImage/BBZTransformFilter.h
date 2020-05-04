//
//  BBZTransformFilter.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/4.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZMultiImageFilter.h"

typedef NS_ENUM(NSInteger, BBZTransformType) {
    BBZTransformTypeImage,
    BBZTransformTypeVideo,
};

/*
 使用transform有三种场景
 1.视频输入
 2.image输入
 3.中间滤镜使用
 */
@interface BBZTransformFilter : BBZMultiImageFilter

- (instancetype)initWithTransfromType:(BBZTransformType)type;
@property (nonatomic, assign) BOOL bUseBackGroundImage;
@property (nonatomic, strong) GPUImageFramebuffer *bgFrameBuffer;
@property (nonatomic, assign, readonly) BBZTransformType type;
@property (nonatomic, assign) CGSize renderSize;
@property (nonatomic, assign) CGAffineTransform affineTransform;
@property (nonatomic, assign) CATransform3D transform3D;
@property (nonatomic, assign) BOOL ignoreAspectRatio;

- (void)renderVideo:(CMSampleBufferRef)sampleBuffer;
- (void)renderImage:(GPUImageFramebuffer *)imageFrameBuffer;


@end

