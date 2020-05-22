//
//  BBZAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZNode.h"
#import "BBZVideoControl.h"

extern const int BBZVideoTimeScale;
extern const int BBZVideoDurationScale;
extern const int BBZScheduleTimeScale;


@interface BBZAction : NSObject <BBZPlayActionProtocol>
@property (nonatomic, assign) NSUInteger startTime;
@property (nonatomic, assign) NSUInteger duration;
@property (nonatomic, assign) NSInteger repeatCount;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign, readonly) CMTime startCMTime;
@property (nonatomic, assign, readonly) CMTime durationCMTime;

@property (nonatomic, strong, readonly) BBZNode *node;



- (instancetype)initWithNode:(BBZNode *)node;

- (void)lock;
- (void)unlock;
- (void)disableReferenceCounting;
- (void)enableReferenceCounting;
- (void)destroySomething;

- (NSUInteger)endTime;

@end


