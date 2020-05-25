//
//  BBZInputFilterAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/5/5.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZInputFilterAction.h"
#import "BBZVideoInputFilter.h"

@interface BBZInputFilterAction ()
@property (nonatomic, strong) BBZMultiImageFilter *multiFilter;
@end


@implementation BBZInputFilterAction

- (void)createImageFilter {
    self.multiFilter = [[BBZMultiImageFilter alloc] init];
}

- (BBZMultiImageFilter *)filter {
    return self.multiFilter;
}


- (void)updateWithTime:(CMTime)time {
    
}

- (void)newFrameAtTime:(CMTime)time {
    
}


@end
