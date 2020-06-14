//
//  BBZOutputFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZOutputFilterLayer.h"
#import "BBZVideoWriterAction.h"

@interface BBZOutputFilterLayer ()<BBZVideoWriteControl>


@end

@implementation BBZOutputFilterLayer

- (BBZActionBuilderResult *)buildTimelineNodes:(BBZActionBuilderResult *)inputBuilder {
    NSAssert(self.model.assetItems.count > 0, @"must have at least one asset");
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = 0;
    builder.groupIndex = 0;
    NSMutableArray *retArray = [NSMutableArray array];
    if(self.context.scheduleMode == BBZEngineScheduleModeExport) {
        BBZVideoWriterAction *action = [[BBZVideoWriterAction alloc] initWithVideoSetting:self.context.videoSettings outputFile:self.outputFile];
        action.writerControl = self;
        action.duration = inputBuilder.startTime;
        action.startTime = builder.startTime;
        action.order = builder.groupIndex;
        builder.groupIndex++;
        builder.assetIndex++;
        BBZActionTree *actionTree = [BBZActionTree createActionTreeWithAction:action];
        self.outputAction = action;
        [retArray addObject:actionTree];
    } else {
        NSAssert(false, @"error");
    }
    builder.groupActions = retArray;
    return builder;
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

- (void)didReachEndTime {
    [self.outputAction didReachEndTime];
}

- (void)setCompletionBlock:(void (^)(BOOL, NSError *))completionBlock {
    self.outputAction.completeBlock = completionBlock;
}

- (BBZExportCompletionBlock)completeBlock {
    return self.outputAction.completeBlock;
}

@end
