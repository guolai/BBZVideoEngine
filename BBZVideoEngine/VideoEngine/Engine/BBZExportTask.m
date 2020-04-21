//
//  BBZExportTask.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZExportTask.h"

@implementation BBZExportTask
@synthesize videoModel = _videoModel;

- (instancetype)initWithModel:(BBZVideoModel *)videoModel {
    if(self = [super init]) {
        _videoModel = videoModel;
    }
    return self;
}

+ (instancetype)taskWithModel:(BBZVideoModel *)videoModel {
    BBZExportTask *exportTask = [[BBZExportTask alloc] initWithModel:videoModel];
    return exportTask;
}
@end
