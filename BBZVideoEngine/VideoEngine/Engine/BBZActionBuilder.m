//
//  BBZActionBuilder.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/21.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZActionBuilder.h"
#import "BBZFilterAction.h"
#import "BBZVideoSourceAction.h"
#import "BBZImageSourceAction.h"
#import "BBZInputFilterAction.h"
#import "BBZVideoWriterAction.h"
#import "BBZVideoControl.h"

@implementation BBZActionBuilder
+ (void)connectAction:(BBZAction *)fromAction toAction:(BBZAction *)toAction {
    if(fromAction || toAction) {
        BBZINFO(@"contains Nil in headAction: %@, tailAction:%@", fromAction, toAction);
        return;
    }
    
    if([fromAction isKindOfClass:[BBZSourceAction class]]) {
        if([toAction isKindOfClass:[BBZInputFilterAction class]]) {
            BBZInputFilterAction *inputAction = (BBZInputFilterAction *)toAction;
            if(!inputAction.firstInputSource) {
                inputAction.firstInputSource = (BBZSourceAction *)fromAction;
            } else if(!inputAction.secondInputSource) {
                inputAction.secondInputSource = (BBZSourceAction *)fromAction;
            } else  {
                NSAssert(false, @"error");
                inputAction.secondInputSource = (BBZSourceAction *)fromAction;
            }
        } else {
            BBZERROR(@"headAction: %@, tailAction:%@", NSStringFromClass([fromAction class]), NSStringFromClass([toAction class]));
            NSAssert(false, @"error chain");
        }
    } else if([fromAction conformsToProtocol:@protocol(BBZActionChainProtocol)] && [toAction conformsToProtocol:@protocol(BBZActionChainProtocol)]) {
        id<BBZActionChainProtocol> fromProtocol = (id<BBZActionChainProtocol>)fromAction;
        id<BBZActionChainProtocol> toProtocol = (id<BBZActionChainProtocol>)toAction;
        [fromProtocol connectToAction:toProtocol];
    } else {
         NSAssert(false, @"error unhandled");
    }
    
}


+ (NSArray *)connectActionTree:(BBZActionTree *)actionTree toAction:(BBZAction *)toAction {
    BBZAction *headAction = nil;
    BBZAction *tailAction = nil;
    [BBZActionBuilder clearActionsConnect:actionTree];
    NSMutableArray *mularray = [NSMutableArray array];
    for (BBZAction *action in actionTree.actions) {
        BBZAction *tmpAction = action;
        if([tmpAction isKindOfClass:[BBZVistualFilterAction class]]) {
            tmpAction = [BBZFilterAction createWithVistualAction:(BBZVistualFilterAction *)tmpAction];
        }
        if(!headAction) {
            headAction = tmpAction;
        }
        [BBZActionBuilder connectAction:headAction toAction:tailAction];
        tailAction = tmpAction;
        [mularray addObject:tailAction];
    }
    if(toAction) {
        [BBZActionBuilder connectAction:tailAction toAction:toAction];
        tailAction = toAction;
    } else {
        BBZINFO(@"tailAction is %@", tailAction);
    }
    if(!headAction) {
        headAction = tailAction;
    }
    for (BBZActionTree *subTree in actionTree.subTrees) {
       [mularray addObjectsFromArray:[BBZActionBuilder connectActionTree:subTree toAction:headAction]];
    }
    return mularray;
}

+ (NSArray *)connectActionsInTree:(BBZActionTree *)actionTree {
    return [BBZActionBuilder connectActionTree:actionTree toAction:nil];
}

+ (void)clearActionsConnect:(BBZActionTree *)actionTree {
    for (BBZAction *action in actionTree.actions) {
        [action removeConnects];
    }
}

@end
