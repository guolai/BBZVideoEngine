//
//  BBZVideoControl.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/27.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTask.h"

extern const int BBZVideoTimeScale;
extern const int BBZVideoDurationScale;

typedef NS_ENUM(NSInteger, BBZEngineScheduleMode) {
    BBZEngineScheduleModeRecord,
    BBZEngineScheduleModePlay,
    BBZEngineScheduleModeExport,
    BBZEngineScheduleModeImageGenerator,
};


@protocol BBZVideoControl <NSObject>



@end
