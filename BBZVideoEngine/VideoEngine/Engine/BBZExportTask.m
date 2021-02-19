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
@property (nonatomic, assign) BOOL bShouldResume;
@property (nonatomic, assign) UIApplicationState appState;
//@property (nonatomic, assign) dispatch_queue_t queue;
@end

@implementation BBZExportTask
@synthesize videoModel = _videoModel;

- (void)dealloc {
    if(self.bShouldRemoveFileAfterCompleted || self.outputFile != self.exportFilePath) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.exportFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.exportFilePath error:NULL];
            BBZINFO(@"BBZExportTask remove exportFile %@", self.exportFilePath);
        }
    }
    [self removeObserverNotification];
}

- (instancetype)initWithModel:(BBZVideoModel *)videoModel {
    if(self = [super init]) {
        _videoModel = videoModel;
        NSString *tmpDir =  [NSString stringWithFormat:@"%@/tmp", _videoModel.videoResourceDir];
        [NSFileManager createDirIfNeed:tmpDir];
        _exportFilePath = [NSString stringWithFormat:@"%@/output.mp4", tmpDir];
//        _queue = [BBZQueueManager exportQueue];
        [self addObserverNotification];
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
            if (self.appState != UIApplicationStateActive) {
                self.bShouldResume = YES;
                return;
            }
            self.state = BBZTaskStateRunning;
            bRet = YES;
            if(!self.videoSetting) {
                self.videoSetting = [BBZEngineSetting buildVideoSettings:self.videoModel];
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

- (void)resume {
    BBZRunAsynchronouslyOnExportQueue(^{
        if(self.state == BBZTaskStatePause) {
             [self.videoEngine resume];
            self.state = BBZTaskStateRunning;
        } else {
            [self start];
        }
        
    });
}

- (BOOL)pause {
    __block BOOL bRet = NO;
//    BBZRunAsynchronouslyOnExportQueue(^{
        if(self.state == BBZTaskStateRunning) {
            bRet = YES;
            self.state = BBZTaskStatePause;
            [self.videoEngine pause];
        } else  if(self.state == BBZTaskStatePause){
            BBZINFO(@"export task is paused");
        } else {
          
            BBZINFO(@"export task is not runnig");
        }
//    });
    return bRet;
}

- (BOOL)cancel {
    __block BOOL bRet = NO;
    BBZRunAsynchronouslyOnExportQueue(^{
        if(self.state == BBZTaskStateRunning) {
            bRet = YES;
            self.state = BBZTaskStateCancel;
            [self.videoEngine cancel];
            // to do cancel
        } else  if(self.state == BBZTaskStateCancel){
            BBZINFO(@"export task is cancel");
        } else {
            BBZINFO(@"export task is not runnig");
        }
    });
    [self removeObserverNotification];
    return bRet;
}

- (void)completeWithError:(NSError *)error {
   [self removeObserverNotification];
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

#pragma mark - Private

- (void)addObserverNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)removeObserverNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)applicationWillEnterForeground {
    self.appState = [UIApplication sharedApplication].applicationState;
}

- (void)applicationDidEnterBackground {
    self.appState = [UIApplication sharedApplication].applicationState;
}

- (void)applicationDidBecomeActive {
    self.appState = [UIApplication sharedApplication].applicationState;
    if(self.bShouldResume) {
        [self resume];
        self.bShouldResume = NO;
    }
}

- (void)applicationWillResignActive {
    self.appState = [UIApplication sharedApplication].applicationState;
    if(self.state == BBZTaskStateRunning) {
        self.bShouldResume = YES;
        [self pause];
    } else {
        self.bShouldResume = NO;
    }
}


@end
