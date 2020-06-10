//
//  BBZAudioAction.h
//  BBZVideoEngine
//
//  Created by bob on 2020/6/10.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZAction.h"

@interface BBZInputAudioParam : NSObject
@property (nonatomic, assign) CMSampleBufferRef sampleBuffer;
@property (nonatomic, assign) CMTime time;
@end

@protocol BBZInputAudioProtocol <NSObject>

- (BBZInputAudioParam *)inputAudioAtTime:(CMTime)time;

@end

@interface BBZAudioAction : BBZAction<BBZInputAudioProtocol>
@property (nonatomic, strong) AVComposition *asset;
@property (nonatomic, assign) CMTimeRange playTimeRange;
@property (nonatomic, strong) NSDictionary *audioSetting;

@end
