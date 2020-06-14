//
//  BBZActionMixer.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZActionTree.h"

@interface BBZActionMixer : NSObject

@property (nonatomic, assign) BOOL bOnlyMixActionsInCurrentNodeTree;

- (NSArray *)combineFiltersFromActionTree:(BBZActionTree *)actionTree;

@end

