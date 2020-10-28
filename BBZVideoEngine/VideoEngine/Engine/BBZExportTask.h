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
#import "BBZVideoControl.h"


@interface BBZExportTask : BBZTask
@property (nonatomic, strong, readonly)BBZVideoModel *videoModel;
@property (nonatomic, strong) BBZEngineSetting *videoSetting;
/*输出文件有两种来源
 1.外部指定的
 2.内部自己创建的（没有外部指定的将使用内部指定）,可以使用bShouldRemoveFileAfterCompleted来在dealloc的时候进行自动清除缓存
 
*/
@property (nonatomic, strong) NSString *outputFile;
@property (nonatomic, assign) BOOL bShouldRemoveFileAfterCompleted;
@property (nonatomic, copy) BBZExportCompletionBlock completeBlock;
@property (nonatomic, copy) BBZExportProgressBlock progressBlock;

+ (instancetype)taskWithModel:(BBZVideoModel *)videoModel;
@end

