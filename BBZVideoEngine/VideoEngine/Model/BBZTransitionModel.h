//
//  BBZTransitionModel.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZTransitionGroupNode.h"
#import "BBZSpliceGroupNode.h"



@interface BBZTransitionModel : NSObject
@property (nonatomic, assign, readonly) CGFloat minVersion;
@property (nonatomic, strong, readonly) NSString *filePath;
@property (nonatomic, strong, readonly) NSArray<BBZTransitionGroupNode *> *transitionGroups;
@property (nonatomic, strong, readonly) NSArray<BBZSpliceGroupNode *> *spliceGroups;

- (instancetype)initWidthDir:(NSString *)filePath;
@end



