//
//  BBZInputFilterAction.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/5.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZFilterAction.h"
#import "BBZSourceAction.h"

@interface BBZInputFilterAction : BBZFilterAction
//@property (nonatomic, assign) BOOL bRGBTexture;

@property (nonatomic, weak) id<BBZInputSourceProtocol> firstInputSource;
//@property (nonatomic, weak) id<BBZInputSourceProtocol> secondInputSource;
//@property (nonatomic, assign) CGAffineTransform transform;
//@property (nonatomic, weak) id<BBZInputSourceProtocol> thirdInputSource;
//@property (nonatomic, weak) id<BBZInputSourceProtocol> fourthInputSource;

- (void)processAVSourceAtTime:(CMTime)time;

@end

