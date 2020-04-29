//
//  BBZVideoFilterLayer.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZVideoFilterLayer.h"

@interface BBZVideoNodesBuilder : NSObject
@property (nonatomic, assign) NSUInteger groupIndex;
@property (nonatomic, assign) NSUInteger assetIndex;
@property (nonatomic, assign) double startTime;
@property (nonatomic, strong) NSArray<BBZNode* > *groupNodes;
@end


@implementation BBZVideoFilterLayer

- (void)buildTimelineNodes {
    
    if(self.model.transitonModel.spliceGroups.count == 0 && self.model.transitonModel.transitionGroups.count == 0) {
        [self buildTimelineNodeWithoutTrasntion];
    }
}

- (void)buildTimelineNodeWithoutTrasntion {
    for (BBZBaseAsset *baseAsset in self.model.assetItems) {
        if(baseAsset.mediaType == BBZBaseAssetMediaTypeImage) {
            
        } else if(baseAsset.mediaType == BBZBaseAssetMediaTypeVideo) {
            
        }
    }
}

- (void)buildTimelineNodeWithTrasntion {
//    BBZVideoNodesBuilder *builder = [[BBZVideoNodesBuilder alloc] init];
//    NSMutableArray *retArray = [NSMutableArray array];
}

@end
