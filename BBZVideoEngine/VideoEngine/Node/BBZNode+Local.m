//
//  BBZNode+Local.m
//  BBZVideoEngine
//
//  Created by bob on 2020/5/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZNode+Local.h"

@implementation BBZNode (Local)

+ (instancetype)createLocalNode:(BBZNodeType)type {
    BBZNode *node = nil;
    switch (type) {
        case BBZNodeTransformSource: {
            
        }
            break;
        case BBZNodeBlendImage: {
            
        }
            break;
        case BBZNodeBlendVideo: {
            
        }
            break;
        case BBZNodeBlendVideoAndImage: {
            
        }
            break;
        default:
            break;
    }
    return node;
}

@end
