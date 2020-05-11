//
//  BBZVideoWriterAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoWriterAction.h"

@protocol BBZVideoWriterActionDelegate <NSObject>
//- (void)didDrawFrameBuffer:(SSZGPUFramebuffer *)outputFramebuffer;
@end

@interface BBZVideoWriterAction ()
@property (nonatomic, assign) CMTime updateTime;
@end

@implementation BBZVideoWriterAction

- (void)updateWithTime:(CMTime)time {
    self.updateTime = time;
}



@end
