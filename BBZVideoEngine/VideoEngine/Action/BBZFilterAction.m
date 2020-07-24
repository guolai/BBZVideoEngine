//
//  BBZFilterAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZFilterAction.h"
#import "BBZMultiImageFilter.h"
#import "GPUImageFramebuffer+BBZ.h"
#import "BBZNodeAnimationParams+property.h"
#import "BBZFilterMixer.h"

@interface BBZFilterAction ()
@property (nonatomic, strong) BBZMultiImageFilter *multiFilter;
@property (nonatomic, strong) NSMutableArray *arrayNode;
@property (nonatomic, strong) NSMutableArray *maskImages;
@end    

@implementation BBZFilterAction

- (void)dealloc {
    [self.multiFilter removeAllCacheFrameBuffer];
    self.multiFilter = nil;
    self.maskImages = nil;
}

- (instancetype)initWithNode:(BBZNode *)node {
    if(self = [super initWithNode:node]) {
        self.maskImages = [NSMutableArray  array];
        self.arrayNode = [NSMutableArray array];
        [self createImageFilter];
    }
    return self;
}

+ (BBZFilterAction *)createWithVistualAction:(BBZVistualFilterAction *)vistualAction {
    if(vistualAction.filterAction) {
        return vistualAction.filterAction;
    }
    BBZFilterAction *fitlerAction = [[BBZFilterAction alloc] initWithNode:vistualAction.node];
    fitlerAction.renderSize = vistualAction.renderSize;
    fitlerAction.repeatCount = vistualAction.repeatCount;
    fitlerAction.startTime = vistualAction.startTime;
    fitlerAction.duration = vistualAction.duration;
//    fitlerAction.node =
    return fitlerAction;
}


- (void)addVistualAction:(BBZVistualFilterAction *)vistualAction {
    [self.arrayNode addObject:vistualAction.node];
}

- (void)addVistualNode:(BBZNode *)otherNode {
    [self.arrayNode addObject:otherNode];
}

//- (void)upateOffsetTime:(NSInteger)offset {
//    double dOffset = offset/(BBZVideoDurationScale * 1.0);
//    self.node.offset = dOffset;
//    for (BBZNode *node in self.arrayNode) {
//        node.offset = dOffset;
//    }
//    // to do test
//}


- (void)createImageFilter {
    BBZFilterMixer *mixer = [BBZFilterMixer filterMixerWithNodes:@[self.node]];
    self.multiFilter = [[BBZMultiImageFilter alloc] initWithVertexShaderFromString:mixer.vShaderString fragmentShaderFromString:mixer.fShaderString];
    self.multiFilter.debugName = self.node.name;
    if([self.node.name isEqualToString:BBZFilterTransition]) {
        self.multiFilter.fenceCount = 2;
    }
}

- (void)removeConnects {
    [self.multiFilter removeAllTargets];
}

- (id)filter {
    return self.multiFilter;
}


- (void)connectToAction:(id<BBZActionChainProtocol>)toAction {
    [self.multiFilter addTarget:[toAction filter]];
}


#pragma mark - time
- (void)updateWithTime:(CMTime)time {
 /*
  time 为真实时间
  node里面 时间为放大了100倍的时间，需要进行换算 ，然后计算 node当前值
  */
  
    NSTimeInterval relativeTime = [self relativeTimeFrom:time];
    BBZNodeAnimationParams *params = [self.node paramsAtTime:relativeTime];
    if(!params) {
        if([self.node.name isEqualToString:BBZFilterBlendImage] ||
           [self.node.name isEqualToString:BBZFilterTransition]) {
            NSAssert(false, @"error");
        }
        return;
    }
    if(!self.node.name) {
        NSAssert(false, @"error");
        return;
    }
    if([self.node.name isEqualToString:BBZFilterBlendImage]) {
        if(self.node.images.count > 0 && self.maskImages.count == 0) {
            for (UIImage *image in self.node.images) {
                GPUImageFramebuffer *framebuffer = [GPUImageFramebuffer BBZ_frameBufferWithImage2:image.CGImage];
                [self.maskImages addObject:framebuffer];
            }
            CGRect rect = [params frame];
            runAsynchronouslyOnVideoProcessingQueue(^{
                self.multiFilter.vector4ParamValue1 = (GPUVector4){rect.origin.x/self.renderSize.width, rect.origin.y/self.renderSize.height, rect.size.width/self.renderSize.width, rect.size.height/self.renderSize.height};
            });
        }
    } else {
        runAsynchronouslyOnVideoProcessingQueue(^{
            self.multiFilter.vector4ParamValue1 =(GPUVector4){params.param1, params.param2, params.param3, params.param4};
            BBZINFO(@"updateWithTime %f, %f, %f, %f %@", params.param1, params.param2, params.param3, params.param4, self.node.name);
        });
        
    }

}

- (void)newFrameAtTime:(CMTime)time {

}


- (void)destroySomething {
    runSynchronouslyOnVideoProcessingQueue(^{
        [self.multiFilter removeAllCacheFrameBuffer];
        self.multiFilter = nil;
        self.maskImages = nil;
    });
}

@end
