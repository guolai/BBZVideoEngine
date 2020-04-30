//
//  BBZFilterLayer.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZFilterLayer.h"


@interface BBZFilterLayer ()
@property (nonatomic, strong) BBZVideoModel *model;
@property (nonatomic, strong) BBZEngineContext *context;
@end

@implementation BBZFilterLayer
- (instancetype)initWithModel:(BBZVideoModel *)model context:(BBZEngineContext *)context {
    if(self = [super init]) {
        _model = model;
        _context = context;
    }
    return self;
}

- (void)buildTimelineNodes {
    
}

@end


@implementation BBZActionBuilderResult


@end
