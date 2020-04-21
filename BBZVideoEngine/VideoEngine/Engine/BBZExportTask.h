//
//  BBZExportTask.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTask.h"
#import "BBZVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BBZExportTask : BBZTask
@property (nonatomic, strong, readonly)BBZVideoModel *videoModel;

+ (instancetype)taskWithModel:(BBZVideoModel *)videoModel;
@end

NS_ASSUME_NONNULL_END
