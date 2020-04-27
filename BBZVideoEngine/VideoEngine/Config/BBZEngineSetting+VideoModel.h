//
//  BBZEngineSetting+VideoModel.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/26.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZEngineSetting.h"
#import "BBZVideoModel.h"

@interface BBZEngineSetting (VideoModel)
- (BBZEngineSetting *)buildVideoSettings:(BBZVideoModel *)videoModel;
@end


