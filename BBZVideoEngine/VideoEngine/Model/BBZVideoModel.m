//
//  BBZVideoModel.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoModel.h"

@implementation BBZVideoModel
- (instancetype)init {
    if(self = [super init]){
        _identifier = [NSString stringWithFormat:@"Model%.6f-%li",[NSDate timeIntervalSinceReferenceDate], (NSInteger)arc4random()];
    }
    return self;
}
@end
