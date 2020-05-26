//
//  BBZActionBuilder.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/21.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBZAction.h"
#import "BBZActionTree.h"


@interface BBZActionBuilder : NSObject

+ (void)connectAction:(BBZAction *)headAction toAction:(BBZAction *)tailAction;
+ (NSArray *)connectActionTree:(BBZActionTree *)actionTree toAction:(BBZAction *)toAction;
+ (NSArray *)connectActionsInTree:(BBZActionTree *)actionTree;
//+ (void)clearActionsConnect:(BBZActionTree *)actionTree;

@end

