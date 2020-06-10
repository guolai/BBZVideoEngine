//
//  BBZAudioFilterLayer.h
//  BBZVideoEngine
//
//  Created by bob on 2020/4/29.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZFilterLayer.h"
#import "BBZAudioAction.h"

@interface BBZAudioFilterLayer : BBZFilterLayer
@property (nonatomic, strong) BBZAudioAction *audioAction;
@end
