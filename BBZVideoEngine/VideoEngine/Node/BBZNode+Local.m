//
//  BBZNode+Local.m
//  BBZVideoEngine
//
//  Created by bob on 2020/5/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZNode+Local.h"
#import "BBZTransformSourceNode.h"
#import "BBZAction.h"

@implementation BBZNode (Local)

+ (instancetype)createLocalNode:(BBZNodeType)type beginTime:(double)beginTime endTime:(double)endTime {
    BBZNode *node = [[BBZNode alloc] init];
    node.begin = beginTime / (BBZVideoDurationScale * 1.0);
    node.end = endTime / (BBZVideoDurationScale * 1.0);
    switch (type) {
        case BBZNodeTransformSource: {
            node.name = @"transformsource";
        }
            break;
        case BBZNodeBlendImage: {
            node.name = @"blendimage";
        }
            break;
        case BBZNodeBlendVideo: {
            node.name = @"blendvideo";
        }
            break;
        case BBZNodeBlendVideoAndImage: {
            node.name = @"blendvideoandimage";
        }
            break;
        default:
            break;
    }
    return node;
}

- (void)buildBlendFrame:(CGRect)frame {
    BBZNodeAnimation *animation = [[BBZNodeAnimation alloc] init];
    animation.begin = 0.0;
    animation.end = self.end - self.begin;
    BBZNodeAnimationParams *begin = [[BBZNodeAnimationParams alloc] init];
    begin.param1 = frame.origin.x;
    begin.param2 = frame.origin.y;
    begin.param3 = frame.size.width;
    begin.param4 = frame.size.height;
    animation.param_begin = begin;
    animation.param_end = [begin copy];
    self.animations  = @[animation];
}



@end
