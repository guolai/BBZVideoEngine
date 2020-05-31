//
//  BBZVideoWriterAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZOutputAction.h"
#import "BBZEngineSetting.h"

@interface BBZVideoWriterAction : BBZOutputAction 

@property (nonatomic, weak) id<BBZVideoWriteControl> writerControl;


- (instancetype)initWithVideoSetting:(BBZEngineSetting *)videoSetting outputFile:(NSString *)strOutputFile;

@end


