//
//  BBZMaskVideoFilter.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/11/2.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZMaskVideoFilter.h"

@implementation BBZMaskVideoFilter


- (void)willEndRender {
    [self removeAllCacheFrameBuffer];
}

@end
