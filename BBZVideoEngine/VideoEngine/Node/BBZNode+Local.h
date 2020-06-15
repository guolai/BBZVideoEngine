//
//  BBZNode+Local.h
//  BBZVideoEngine
//
//  Created by bob on 2020/5/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZNode.h"
#import "BBZTransformItem.h"

typedef NS_ENUM(NSInteger, BBZNodeType) {
    BBZNodeTransformDefault = 0,
    BBZNodeTransformSource,
    BBZNodeBlendImage,
    BBZNodeBlendVideo,
    BBZNodeBlendVideoAndImage,
};





@interface BBZNode (Local)

+ (instancetype)createLocalNode:(BBZNodeType)type duration:(NSUInteger)duration;
- (void)buildBlendFrame:(CGRect)frame;

- (void)buildTransfromSourceFrom:(BBZTransformItem *)fromItem to:(BBZTransformItem *)fromItem;
- (void)buildTransfromSourceScaleFrom:(double)fromScale toScale:(double)toScale;

@end


