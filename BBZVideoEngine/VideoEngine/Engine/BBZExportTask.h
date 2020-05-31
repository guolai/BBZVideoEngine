//
//  BBZExportTask.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTask.h"
#import "BBZVideoModel.h"
#import "BBZEngineSetting.h"




@interface BBZExportTask : BBZTask
@property (nonatomic, strong, readonly)BBZVideoModel *videoModel;
@property (nonatomic, strong) BBZEngineSetting *videoSetting;
@property (nonatomic, strong) NSString *outputFile;
@property (nonatomic, copy) void(^completionBlock)(BOOL sucess, NSError *error);
+ (instancetype)taskWithModel:(BBZVideoModel *)videoModel;
@end

