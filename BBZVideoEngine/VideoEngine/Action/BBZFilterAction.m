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

@interface BBZFilterAction ()
@property (nonatomic, strong) BBZMultiImageFilter *multiFilter;
@property (nonatomic, strong) NSMutableArray *arrayNode;
@property (nonatomic, strong) GPUImageFramebuffer *imageFrameBuffer;
@end    

@implementation BBZFilterAction

- (void)dealloc {
    [self.multiFilter removeAllCacheFrameBuffer];
    self.multiFilter = nil;
    self.imageFrameBuffer = nil;
}

- (instancetype)initWithNode:(BBZNode *)node {
    if(self = [super initWithNode:node]) {
        [self createImageFilter];
    }
    return self;
}

+ (BBZFilterAction *)createWithVistualAction:(BBZVistualFilterAction *)vistualAction {
    if(vistualAction.filterAction) {
        return vistualAction.filterAction;
    }
    BBZFilterAction *fitlerAction = [[BBZFilterAction alloc] initWithNode:vistualAction.node];
    fitlerAction.repeatCount = vistualAction.repeatCount;
    fitlerAction.startTime = vistualAction.startTime;
    fitlerAction.duration = vistualAction.duration;
//    fitlerAction.node =
    return fitlerAction;
}

- (void) addVistualAction:(BBZVistualFilterAction *)vistualAction {
    [self.arrayNode addObject:vistualAction.node];
}


- (void)createImageFilter {
    self.multiFilter = [[BBZMultiImageFilter alloc] initWithVertexShaderFromString:self.node.vShaderString fragmentShaderFromString:self.node.fShaderString];
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
    if(self.node.image && !self.imageFrameBuffer) {
         GPUImageFramebuffer *framebuffer = [GPUImageFramebuffer BBZ_frameBufferWithImage2:self.node.image.CGImage];
        self.imageFrameBuffer = framebuffer;
        BBZNodeAnimationParams *params = [self.node paramsAtTime:CMTimeGetSeconds(time)];
        if(params) {
            CGRect rect = [params frame];
            self.multiFilter.vector4ParamValue1 = (GPUVector4){rect.origin.x, rect.origin.y, rect.size.width, rect.size.height};
        }
    }
    
    
//    BBZNodeAnimationParams *params = [self.node paramsAtTime:CMTimeGetSeconds(time)];
//    if(params) {
//         //to do
//    }
    //to do
}

- (void)newFrameAtTime:(CMTime)time {
    if(self.imageFrameBuffer) {
        [self.multiFilter addFrameBuffer:self.imageFrameBuffer];
    }
    
}

- (void)destroySomething {
    runSynchronouslyOnVideoProcessingQueue(^{
        [self.multiFilter removeAllCacheFrameBuffer];
        self.multiFilter = nil;
        self.imageFrameBuffer = nil;
    });
}

@end
