//
//  BBZErrorMonitor.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/19.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBZErrorMonitor : NSObject
+ (instancetype)shareInstance;
- (void)addErrorBlock:(void(^)(NSError *error))block;
@end

NS_ASSUME_NONNULL_END
