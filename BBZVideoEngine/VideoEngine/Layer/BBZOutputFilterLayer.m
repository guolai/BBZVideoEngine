//
//  BBZOutputFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZOutputFilterLayer.h"
#import "BBZVideoWriterAction.h"
#import "BBZNode+Local.h"

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
        BBZNode *node = nil;
        if(self.model.maskImage) {
            node = [BBZNode createLocalNode:BBZNodeBlendImage duration:inputBuilder.startTime];
            [node buildBlendFrame:CGRectMake(self.context.renderSize.width - 40.0 - 50.0, self.context.renderSize.height - 40.0 - 50.0, 40.0, 40.0)];
            node.images = self.model.maskImage;
        }
        
        BBZVideoWriterAction *action = [[BBZVideoWriterAction alloc] initWithVideoSetting:self.context.videoSettings outputFile:self.outputFile node:node];
        action.writerControl = self;
        action.duration = inputBuilder.startTime;
        action.startTime = 0;
        action.renderSize = self.context.renderSize;
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

- (void)setCompleteBlock:(BBZExportCompletionBlock)completeBlock {
     self.outputAction.completeBlock = completeBlock;
}

- (BBZExportCompletionBlock)completeBlock {
    return self.outputAction.completeBlock;
}

@end
