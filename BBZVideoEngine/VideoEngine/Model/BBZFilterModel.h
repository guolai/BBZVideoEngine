//
//  BBZFilterModel.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/22.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZFilterNode.h"

@interface BBZFilterModel : NSObject
//@property (nonatomic, assign, readonly) CGFloat duration;
@property (nonatomic, assign, readonly) CGFloat minVersion;
@property (nonatomic, strong, readonly) NSString *filePath;
@property (nonatomic, strong) NSArray<BBZFilterNode *> *filterGroups;
@property (nonatomic, strong, readonly) BBZNode *endingAction;

- (instancetype)initWidthDir:(NSString *)filePath;

@end

