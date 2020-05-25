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



@interface BBZVideoWriterAction () <BBZVideoOutputFilterDelegate, BBZVideoWriteControl>
@property (nonatomic, assign) CMTime updateTime;
@property (nonatomic, strong) BBZAssetWriter *writer;
@property (nonatomic, copy) NSString *strOutputFile;
@property (nonatomic, copy) NSDictionary *videoSettings;
@property (nonatomic, copy) NSDictionary *audioSettings;
@property (nonatomic, strong) BBZVideoOutputFilter *outputFilter;
@end

@implementation BBZVideoWriterAction

- (instancetype)initWithVideoSetting:(BBZEngineSetting *)videoSetting outputFile:(NSString *)strOutputFile {
    if(self = [super init]) {
        self.videoSettings = videoSetting.videoOutputSettings;
        self.audioSettings = videoSetting.audioOutputSettings;
        self.strOutputFile = strOutputFile;
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
    
    self.outputFilter = [[BBZVideoOutputFilter alloc] init];
    self.outputFilter.delegate = self;
    self.writer = [[BBZAssetWriter alloc] initWithOutputFile:self.strOutputFile size:videoSize fileType:AVFileTypeMPEG4];
    self.writer.videoOutputSettings = self.videoSettings;
    self.writer.audioOutputSettings = self.audioSettings;
    self.writer.hasAudioTrack = YES;
    self.writer.writeControl = self;
    __weak typeof(self) weakSelf = self;
    self.writer.completionBlock = ^(BOOL sucess, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf didFinishWritingVideoWithError:error async:YES];
    };

}



- (void)updateWithTime:(CMTime)time {
    self.updateTime = time;
}

- (void)lock {
    [super lock];
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.strOutputFile]){
        [[NSFileManager defaultManager] removeItemAtPath:self.strOutputFile error:&error];
    }
    [self buildWriter];
    [self.writer startWriting];
}

- (void)destroySomething{
    [self.writer cancleWriting];
    self.writer = nil;
}

- (void)didFinishWritingVideoWithError:(NSError *)error async:(BOOL)async {
    if (async) {
        BBZRunAsynchronouslyOnTaskQueue(^{
            if (self.completionBlock) {
                self.completionBlock((error ? nil : self.strOutputFile), error);
            }
        });
    }  else {
        BBZRunSynchronouslyOnTaskQueue(^{
            if (self.completionBlock) {
                self.completionBlock((error ? nil : self.strOutputFile), error);
            }
        });
    }
}

#pragma mark - Delegate
- (void)didDrawFrameBuffer:(GPUImageFramebuffer *)outputFramebuffer time:(CMTime)time{
    [self.writer writeSyncVideoPixelBuffer:outputFramebuffer.pixelBuffer withPresentationTime:time];
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

@end
