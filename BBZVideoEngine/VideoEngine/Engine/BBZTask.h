//
//  BBZTask.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BBZTaskState) {
    BBZTaskStateIdel = 0,
    BBZTaskStateRunning,
    BBZTaskStatePause,
    BBZTaskStateCancel,
    BBZTaskStateFinish,
};

NS_ASSUME_NONNULL_BEGIN

@class BBZTask;

typedef void (^BBZTaskUpdateProgressBlock)(BBZTask *task, float progress);
typedef void (^BBZTaskCompleteBlock)(BBZTask *task, NSError *error);


@protocol BBZTaskDelegate <NSObject>
@required
- (void)task:(BBZTask *)task didCompleteWithError:(NSError *)error;
@optional
- (void)task:(BBZTask *)task didUpdateProgress:(float)progress;
@end

@interface BBZTask : NSObject
@property (nonatomic, assign) BBZTaskState state;
@property (nonatomic, assign) float cost;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) float weight;

- (BOOL)start;
- (BOOL)pause;
- (BOOL)cancel;

- (void)completeWithError:(NSError *)error;
- (void)updateProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
