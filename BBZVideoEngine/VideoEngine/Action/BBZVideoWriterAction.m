//
//  BBZVideoWriterAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoWriterAction.h"

@protocol BBZVideoWriterActionDelegate <NSObject>
//- (void)didDrawFrameBuffer:(SSZGPUFramebuffer *)outputFramebuffer;
@end

@interface BBZVideoWriterAction ()
@property (nonatomic, assign) CMTime updateTime;
@end

@implementation BBZVideoWriterAction

- (void)updateWithTime:(CMTime)time {
    self.updateTime = time;
}

- (void)lock {
    [super lock];
//    [self buildReader];
//    [self.videoOutPut startProcessing];
}

- (void)destroySomething{
//    [self.videoOutPut endProcessing];
//    [self.reader removeOutput:self.videoOutPut];
//    self.videoOutPut = nil;
//    self.reader = nil;
}

@end
