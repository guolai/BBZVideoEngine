//
//  BBZEngineContext.h
//  BBZVideoEngine
//
//  Created by bob on 2020/4/28.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZEngineSetting.h"
#import "BBZVideoControl.h"


@interface BBZEngineContext : NSObject
@property (nonatomic, strong) BBZEngineSetting *videoSettings;
@property (nonatomic, assign) BBZEngineScheduleMode scheduleMode;
@property (nonatomic, assign, readonly) CGSize renderSize;


+ (instancetype)contextWithVideoSettings:(BBZEngineSetting *)videoSettings;


@end
