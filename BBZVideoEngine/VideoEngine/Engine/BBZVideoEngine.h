//
//  BBZVideoEngine.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/27.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZTask.h"
#import "BBZVideoModel.h"
#import "BBZEngineContext.h"
#import "BBZVideoControl.h"


@interface BBZVideoEngine : BBZTask
@property (nonatomic, strong, readonly) BBZVideoModel *videoModel;
@property (nonatomic, strong, readonly) BBZEngineContext *context;
@property (nonatomic, strong, readonly) NSString *outputFile;
@property (nonatomic, copy) BBZExportCompletionBlock completeBlock;
@property (nonatomic, copy) BBZExportProgressBlock progressBlock;

- (void)resume;

+ (instancetype)videoEngineWithModel:(BBZVideoModel *)model
                      context:(BBZEngineContext *)context
                         outputFile:(NSString *)outputFile;

- (CGFloat)videoModelCombinedDuration;

@end

