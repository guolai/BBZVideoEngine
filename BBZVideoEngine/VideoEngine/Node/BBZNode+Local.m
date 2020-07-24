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

+ (instancetype)createLocalNode:(BBZNodeType)type duration:(NSUInteger)duration {
    BBZNode *node = [[BBZNode alloc] init];
    node.begin = 0;
    node.end = duration / (BBZVideoDurationScale * 1.0);
    switch (type) {
        case BBZNodeTransformSource: {
            node.name = BBZFilterTransformSource;
        }
            break;
        case BBZNodeBlendImage: {
            node.name = BBZFilterBlendImage;
        }
            break;
        case BBZNodeBlendVideo: {
            node.name = BBZFilterBlendVideo;
        }
            break;
        case BBZNodeBlendVideoAndImage: {
            node.name = BBZFilterBlendVideoAndImage;
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



- (void)buildTransfromSourceFrom:(BBZTransformItem *)fromItem to:(BBZTransformItem *)toItem {
    BBZNodeAnimation *animation = [[BBZNodeAnimation alloc] init];
    animation.begin = 0.0;
    animation.end = self.end - self.begin;
    BBZNodeAnimationParams *begin = [[BBZNodeAnimationParams alloc] init];
    begin.param1 = fromItem.scale;
    begin.param2 = fromItem.tx;
    begin.param3 = fromItem.ty;
    begin.param4 = fromItem.angle;
    BBZNodeAnimationParams *end = [[BBZNodeAnimationParams alloc] init];
    end.param1 = toItem.scale;
    end.param2 = toItem.tx;
    end.param3 = toItem.ty;
    end.param4 = toItem.angle;
    animation.param_begin = begin;
    animation.param_end = end;
    self.animations  = @[animation];
}

- (void)buildTransfromSourceScaleFrom:(double)fromScale toScale:(double)toScale {
    BBZNodeAnimation *animation = [[BBZNodeAnimation alloc] init];
    animation.begin = 0.0;
    animation.end = self.end - self.begin;
    BBZNodeAnimationParams *begin = [[BBZNodeAnimationParams alloc] init];
    begin.param1 = fromScale;
    BBZNodeAnimationParams *end = [[BBZNodeAnimationParams alloc] init];
    end.param1 = toScale;
    animation.param_begin = begin;
    animation.param_end = end;
    self.animations  = @[animation];
}



@end
