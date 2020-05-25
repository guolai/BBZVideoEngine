//
//  BBZOutputAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZAction.h"
#import "BBZBaseAsset.h"
#import "GPUImageFramebuffer.h"

//@protocol BBZOutputSourceProtocol <NSObject>
//- (void)outputFrameBuffer:(GPUImageFramebuffer *)outputFramebuffer atTime:(CMTime)time;
//@end

@interface BBZOutputAction : BBZAction /*<BBZOutputSourceProtocol>*/
@end

