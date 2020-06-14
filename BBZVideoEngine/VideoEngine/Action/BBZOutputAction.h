//
//  BBZOutputAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZAction.h"
#import "BBZBaseAsset.h"
#import "BBZAudioAction.h"

//#import "GPUImageFramebuffer.h"
//#import "GPUImageFilter.h"

//@protocol BBZOutputSourceProtocol <NSObject>
//- (void)outputFrameBuffer:(GPUImageFramebuffer *)outputFramebuffer atTime:(CMTime)time;
//@end

@interface BBZOutputAction : BBZAction<BBZActionChainProtocol>
@property (nonatomic, weak) id<BBZInputAudioProtocol> inputAudioProtocol;
@property (nonatomic, copy) BBZExportCompletionBlock completeBlock;
@property (nonatomic, assign) BOOL hasAudioTrack;
- (void)didReachEndTime;

//@property (nonatomic, strong, readonly) GPUImageFilter *filter;
@end

