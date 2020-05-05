//
//  BBZVideoSourceAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZSourceAction.h"


@interface BBZVideoSourceAction : BBZSourceAction
- (CMSampleBufferRef)samplebufferAtTime:(CMTime)time;
@end


