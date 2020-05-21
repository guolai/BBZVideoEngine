//
//  BBZCompositonDirector.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTask.h"
#import "BBZVideoModel.h"
#import "BBZEngineSetting.h"
#import "BBZSchedule.h"
#import "BBZFilterMixer.h"

@protocol BBZSegmentActionDelegate <NSObject>

- (NSArray *)layerActionTreesBeforeTimePoint:(NSUInteger)timePoint;

@end


@interface BBZCompositonDirector : BBZTask <BBZScheduleObserver>
@property (nonatomic, weak) id<BBZSegmentActionDelegate> segmentDelegate;
@property (nonatomic, strong) NSArray *timePointsArray;

@end

