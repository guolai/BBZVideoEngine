//
//  BBZTransformItem.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/6/15.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTransformItem.h"


@implementation BBZTransformItem

- (instancetype)init {
    if(self = [super init]) {
        _scale = 1.0;
        _tx = 0.0;
        _ty = 0.0;
        _angle = 0.0;
    }
    return self;
}

@end
