//
//  BBZEngineContext.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/28.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZEngineContext.h"

@implementation BBZEngineContext
+ (instancetype)contextWithVideoSettings:(BBZEngineSetting *)videoSettings
{
    BBZEngineContext *context = [[BBZEngineContext alloc] init];
    context.videoSettings = videoSettings;
    return context;
}

- (CGSize)renderSize
{
    return self.videoSettings.videoSize;
}

@end
