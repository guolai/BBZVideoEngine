//
//  BBZExportTask.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZExportTask.h"
#import "BBZQueueManager.h"
#import "BBZEngineSetting+VideoModel.h"
#import "BBZEngineContext.h"
#import "BBZVideoEngine.h"

@interface BBZExportTask ()
@property (nonatomic, strong) NSString *exportFilePath;
@property (nonatomic, strong) BBZVideoEngine *videoEngine;
@property (nonatomic, strong) BBZEngineContext *context;
//@property (nonatomic, assign) dispatch_queue_t queue;
@end

@implementation BBZExportTask
@synthesize videoModel = _videoModel;

- (instancetype)initWithModel:(BBZVideoModel *)videoModel {
    if(self = [super init]) {
        _videoModel = videoModel;
        NSString *tmpDir =  [NSString stringWithFormat:@"%@/tmp", _videoModel.videoResourceDir];
        [NSFileManager createDirIfNeed:tmpDir];
        _exportFilePath = [NSString stringWithFormat:@"%@/output.mp4", tmpDir];
//        _queue = [BBZQueueManager exportQueue];
    }
    return self;
}

+ (instancetype)taskWithModel:(BBZVideoModel *)videoModel {
    BBZExportTask *exportTask = [[BBZExportTask alloc] initWithModel:videoModel];
    return exportTask;
}

- (BOOL)start {
    __block BOOL bRet = NO;
    BBZRunSynchronouslyOnExportQueue(^{
        if(self.state == BBZTaskStateFinish) {
            BBZINFO(@"export task is finish");
        } else  if(self.state == BBZTaskStateRunning){
            BBZINFO(@"export task is runnig");
        } else {
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.outputFile]) {
                [[NSFileManager defaultManager] removeItemAtPath:self.outputFile error:NULL];
            }
            self.state = BBZTaskStateRunning;
            bRet = YES;
            if(!self.videoSetting) {
                self.videoSetting = [[BBZEngineSetting alloc] buildVideoSettings:self.videoModel];
            }
            BBZEngineContext *context = [BBZEngineContext contextWithVideoSettings:self.videoSetting];
            context.scheduleMode = BBZEngineScheduleModeExport;
            self.context = context;
            BBZRunAsynchronouslyOnExportQueue(^{
                self.videoEngine = [BBZVideoEngine videoEngineWithModel:self.videoModel context:self.context outputFile:self.outputFile];
//                __weak typeof(self) weakself = self;
                self.videoEngine.completeBlock = self.completeBlock;
                self.videoEngine.progressBlock = self.progressBlock;
                [self.videoEngine start];
            });
        }
    });
    return bRet;
}

- (BOOL)pause {
    __block BOOL bRet = NO;
    BBZRunSynchronouslyOnExportQueue(^{
        if(self.state == BBZTaskStateRunning) {
            bRet = YES;
            self.state = BBZTaskStatePause;
            BBZRunAsynchronouslyOnExportQueue(^{
                
            });
        } else  if(self.state == BBZTaskStatePause){
            BBZINFO(@"export task is paused");
        } else {
          
            BBZINFO(@"export task is not runnig");
        }
    });
    return bRet;
}

- (BOOL)cancel {
    __block BOOL bRet = NO;
    BBZRunSynchronouslyOnExportQueue(^{
        if(self.state == BBZTaskStateRunning) {
            bRet = YES;
            self.state = BBZTaskStateCancel;
            // to do cancel
        } else  if(self.state == BBZTaskStateCancel){
            BBZINFO(@"export task is cancel");
        } else {
            BBZINFO(@"export task is not runnig");
        }
    });
    return bRet;
}

- (void)completeWithError:(NSError *)error {
   
}

- (void)updateProgress:(float)progress {
    self.progress = progress;
}

- (NSString *)outputFile {
    if(_outputFile.length == 0) {
        return self.exportFilePath;
    }
    return _outputFile;
}
@end
