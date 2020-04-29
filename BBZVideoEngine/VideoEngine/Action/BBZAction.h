//
//  BBZAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZNode.h"

@interface BBZAction : NSObject
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) NSInteger repeatCount;

@property (nonatomic, strong) BBZNode *node;


- (void)updateWithTime:(CGFloat)time;
- (void)seekToTime:(CGFloat)time;


- (void)lock;
- (void)unlock;
- (void)disableReferenceCounting;
- (void)enableReferenceCounting;
- (void)destroySomething;

@end


