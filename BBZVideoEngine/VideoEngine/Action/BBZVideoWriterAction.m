//
//  BBZVideoWriterAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoWriterAction.h"
#import "BBZAssetWriter.h"
#import "BBZQueueManager.h"
#import <Foundation/NSFileManager.h>
#import "BBZVideoOutputFilter.h"
#import "BBZFilterMixer.h"
#import "BBZShader.h"
#import "GPUImageFramebuffer+BBZ.h"
#import "BBZNodeAnimationParams+property.h"


@interface BBZVideoWriterAction () <BBZVideoOutputFilterDelegate, BBZVideoWriteControl>
@property (nonatomic, assign) CMTime updateTime;
@property (nonatomic, strong) BBZAssetWriter *writer;
@property (nonatomic, copy) NSString *strOutputFile;
@property (nonatomic, copy) NSDictionary *videoSettings;
@property (nonatomic, copy) NSDictionary *audioSettings;
@property (nonatomic, strong) BBZVideoOutputFilter *outputFilter;
@property (nonatomic, strong) NSMutableArray *maskImages;
@end

@implementation BBZVideoWriterAction

- (void)dealloc {
    [self.outputFilter removeAllCacheFrameBuffer];
    self.outputFilter = nil;
    self.maskImages = nil;
    [self.writer cancleWriting];
    self.writer = nil;
}


- (instancetype)initWithVideoSetting:(BBZEngineSetting *)videoSetting
                          outputFile:(NSString *)strOutputFile
                                node:(BBZNode *)node{
    if(self = [super initWithNode:node]) {
        self.videoSettings = videoSetting.videoOutputSettings;
        self.audioSettings = videoSetting.audioOutputSettings;
        self.strOutputFile = strOutputFile;
        self.maskImages = [NSMutableArray  array];
        [self createImageFilter];
 
    }
    return self;
}



- (void)buildWriter {
    NSNumber *width = self.videoSettings[AVVideoWidthKey];
    NSNumber *height = self.videoSettings[AVVideoHeightKey];
    if ((width == nil) || (height == nil)) {
        return [self didFinishWritingVideoWithError:[NSError errorWithDomain:@"无效的分辨率" code:-1 userInfo:nil] async:YES];
    }
    
    CGSize videoSize = CGSizeMake([width doubleValue], [height doubleValue]);
    if ((videoSize.width < 1) || (videoSize.height < 1)) {
        return [self didFinishWritingVideoWithError:[NSError errorWithDomain:@"无效的分辨率" code:-1 userInfo:nil] async:YES];
    }
    
    self.writer = [[BBZAssetWriter alloc] initWithOutputFile:self.strOutputFile size:videoSize fileType:AVFileTypeMPEG4];
    self.writer.videoOutputSettings = self.videoSettings;
    self.writer.audioOutputSettings = self.audioSettings;
    self.writer.hasAudioTrack = self.hasAudioTrack;
    self.writer.writeControl = self;
    __weak typeof(self) weakSelf = self;
    self.writer.completionBlock = ^(BOOL sucess, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf didFinishWritingVideoWithError:error async:YES];
    };

}



- (void)updateWithTime:(CMTime)time {
    self.updateTime = time;
    if(!self.node) {
        return;
    }
    NSTimeInterval relativeTime = [self relativeTimeFrom:time];
    BBZNodeAnimationParams *params = [self.node paramsAtTime:relativeTime];
    if(!params) {
        if([self.node.name isEqualToString:BBZFilterBlendImage]) {
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
            runSynchronouslyOnVideoProcessingQueue(^{
                self.outputFilter.vector4ParamValue1 = (GPUVector4){rect.origin.x/self.renderSize.width, rect.origin.y/self.renderSize.height, rect.size.width/self.renderSize.width, rect.size.height/self.renderSize.height};
            });
        }
    } else {
//        runAsynchronouslyOnVideoProcessingQueue(^{
//            self.multiFilter.vector4ParamValue1 =(GPUVector4){params.param1, params.param2, params.param3, params.param4};
//        });
        NSAssert(false, @"error");
    }
}

- (void)newFrameAtTime:(CMTime)time {
    runAsynchronouslyOnVideoProcessingQueue(^{
        if(self.maskImages.count > 0) {
            [self.outputFilter removeAllCacheFrameBuffer];
            NSInteger index = ((time.value/BBZScheduleTimeScale) * 100)%self.maskImages.count;
            [self.outputFilter addFrameBuffer:[self.maskImages objectAtIndex:index]];
            BBZINFO(@" currentTime blendimage = %.4f", CMTimeGetSeconds(time));
        }
        else {
            if([self.node.name isEqualToString:BBZFilterBlendImage]) {
                NSAssert(false, @"error");
            }
        }
    });
    if(self.hasAudioTrack && self.inputAudioProtocol) {
        BBZInputAudioParam *inputAudio = [self.inputAudioProtocol inputAudioAtTime:time];
        if(inputAudio.sampleBuffer) {
            [self.writer writeAudioFrameBuffer:inputAudio.sampleBuffer];
        }
    }
}

- (void)lock {
    [super lock];
//    runAsynchronouslyOnVideoProcessingQueue(^{
        if(!self.writer) {
            NSError *error;
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.strOutputFile]){
                [[NSFileManager defaultManager] removeItemAtPath:self.strOutputFile error:&error];
            }
            [self buildWriter];
            [self.writer startWriting];
            self.outputFilter.videoPixelBufferAdaptor = self.writer.videoPixelBufferAdaptor;
        }
//    });
   
    
}

- (void)destroySomething{
   
}

- (void)didFinishWritingVideoWithError:(NSError *)error async:(BOOL)async {
    BBZINFO(@"-----------%@", self.strOutputFile);
    if (async) {
        BBZRunAsynchronouslyOnTaskQueue(^{
            if (self.completeBlock) {
                self.completeBlock((error ? NO : YES), error);
            }
            [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
        });
    }  else {
        BBZRunSynchronouslyOnTaskQueue(^{
            if (self.completeBlock) {
                self.completeBlock((error ? NO : YES), error);
            }
            [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
        });
    }
}

- (void)didReachEndTime {
    runSynchronouslyOnVideoProcessingQueue(^{
        [self.writer finishWriting];
    });
}

#pragma mark - Delegate
- (void)didDrawFrameBuffer:(GPUImageFramebuffer *)outputFramebuffer time:(CMTime)time{
    [self.writer writeSyncVideoPixelBuffer:outputFramebuffer.pixelBuffer withPresentationTime:time];
}

- (void)didDrawPixelBuffer:(CVPixelBufferRef )pixelBuffer time:(CMTime)time {
    [self.writer writeSyncVideoPixelBuffer:pixelBuffer withPresentationTime:time];
}


- (void)didWriteVideoFrame {
    if([self.writerControl respondsToSelector:@selector(didWriteVideoFrame)]) {
        [self.writerControl didWriteVideoFrame];
    }
}
- (void)didWriteAudioFrame {
    if([self.writerControl respondsToSelector:@selector(didWriteAudioFrame)]) {
        [self.writerControl didWriteAudioFrame];
    }
}


#pragma mark - Filter

- (void)createImageFilter {
    if(self.node) {
        BBZFilterMixer *mixer = [BBZFilterMixer filterMixerWithNodes:@[self.node]];
        self.outputFilter = [[BBZVideoOutputFilter alloc] initWithVertexShaderFromString:mixer.vShaderString fragmentShaderFromString:mixer.fShaderString];
    } else {
        self.outputFilter = [[BBZVideoOutputFilter alloc] initWithVertexShaderFromString:[BBZShader vertextShader] fragmentShaderFromString:[BBZShader fragmentPassthroughShader]];
    }
    self.outputFilter.delegate = self;
}

- (void)removeConnects {
    [self.outputFilter removeAllTargets];
}

- (id)filter {
    return self.outputFilter;
}

- (void)connectToAction:(id<BBZActionChainProtocol>)toAction {
    [self.outputFilter addTarget:[toAction filter]];
}

@end
