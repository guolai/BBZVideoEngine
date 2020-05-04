//
//  BBZTransitionGroupNode.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/24.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZTransitionGroupNode.h"
#import "NSDictionary+YYAdd.h"

//@property (nonatomic, assign) double timestamp;
//@property (nonatomic, assign) double duration;
//@property (nonatomic, assign) NSInteger order;
//@property (nonatomic, assign) NSInteger repeat;
@implementation BBZTransitionNode
-(instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        self.timestamp = [dic floatValueForKey:@"timestamp" default:0.0];
        self.duration = [dic floatValueForKey:@"duration" default:0.0];
        self.order = [dic intValueForKey:@"order" default:0];
        self.repeat = [dic intValueForKey:@"repeat" default:0];
        id Obj = [dic objectForKey:@"action"];
        NSMutableArray *array = [NSMutableArray array];
        if ([Obj isKindOfClass:[NSDictionary class]]) {
            BBZNode *node = [[BBZNode alloc] initWithDictionary:Obj];
            [array addObject:node];
        } else if ([Obj isKindOfClass:[NSArray class]]) {
            for (NSDictionary *subDic in Obj) {
                BBZNode *node = [[BBZNode alloc] initWithDictionary:subDic];
                [array addObject:node];
            }
        }
        [array sortUsingComparator:^NSComparisonResult(BBZNode *obj1, BBZNode *obj2) {
            return (obj1.order<obj2.order)?NSOrderedAscending:NSOrderedDescending;
        }];
        self.actions = array;
    }
    return self;
}

@end


@implementation BBZTransitionGroupNode
-(instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        self.duration = [dic floatValueForKey:@"duration" default:0.0];
        self.order = [dic intValueForKey:@"order" default:0];
        id Obj = [dic objectForKey:@"splice"];
        if ([Obj isKindOfClass:[NSDictionary class]]) {
            BBZTransitionNode *node = [[BBZTransitionNode alloc] initWithDictionary:Obj];
            self.transitionNode = node;
        } else if ([Obj isKindOfClass:[NSArray class]]) {
            NSAssert(false, @"not support");
        }
        
        Obj = [dic objectForKey:@"input"];
        NSMutableArray *array = [NSMutableArray array];
        if ([Obj isKindOfClass:[NSDictionary class]]) {
            BBZInputNode *node = [[BBZInputNode alloc] initWithDictionary:Obj];
            [array addObject:node];
        } else if ([Obj isKindOfClass:[NSArray class]]) {
            for (NSDictionary *subDic in Obj) {
                BBZInputNode *node = [[BBZInputNode alloc] initWithDictionary:subDic];
                [array addObject:node];
            }
        }
        [array sortUsingComparator:^NSComparisonResult(BBZInputNode *obj1, BBZInputNode *obj2) {
            return (obj1.index<obj2.index)?NSOrderedAscending:NSOrderedDescending;
        }];
        self.inputNodes = array;
    }
    return self;
}

@end
