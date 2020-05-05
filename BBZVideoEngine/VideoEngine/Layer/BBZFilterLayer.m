//
//  BBZFilterLayer.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZFilterLayer.h"

@implementation BBZActionBuilderResult
@end

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

- (BBZActionBuilderResult *)buildTimelineNodes:(BBZActionBuilderResult *)inputBuilder {
    return nil;
}

@end



