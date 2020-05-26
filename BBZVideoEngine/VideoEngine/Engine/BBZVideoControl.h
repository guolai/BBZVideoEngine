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
extern const int BBZScheduleTimeScale;

typedef NS_ENUM(NSInteger, BBZEngineScheduleMode) {
    BBZEngineScheduleModeRecord,
    BBZEngineScheduleModePlay,
    BBZEngineScheduleModeExport,
    BBZEngineScheduleModeImageGenerator,
};


@protocol BBZVideoWriteControl <NSObject>
- (void)didWriteVideoFrame;
- (void)didWriteAudioFrame;
@end

@protocol BBZPlayActionProtocol <NSObject>

- (void)updateWithTime:(CMTime)time;
- (void)newFrameAtTime:(CMTime)time;

@end

@protocol BBZActionChainProtocol <NSObject>

- (id)filter;
- (void)connectToAction:(id<BBZActionChainProtocol>)toAction;

@end

