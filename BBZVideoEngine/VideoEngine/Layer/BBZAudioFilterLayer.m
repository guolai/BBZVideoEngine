//
//  BBZAudioFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZAudioFilterLayer.h"
#import "BBZAudioReaderAction.h"

@implementation BBZAudioFilterLayer
- (BBZActionBuilderResult *)buildTimelineNodes:(BBZActionBuilderResult *)inputBuilder {
    NSAssert(self.model.assetItems.count > 0, @"must have at least one asset");
    BBZActionBuilderResult *builder = nil;
    if(self.model.filterModel.filterGroups.count > 0) {
        builder = [self buildAudioTimeLine:inputBuilder];
    }
    return builder;
}

- (BBZActionBuilderResult *)buildAudioTimeLine:(BBZActionBuilderResult *)inputBuilderResult {
    
    BBZActionBuilderResult *builder = [[BBZActionBuilderResult alloc] init];
    builder.startTime = inputBuilderResult.startTime;
    builder.groupIndex = 0;
    
    builder.groupActions = [NSArray array];
    return builder;
    
}
@end
