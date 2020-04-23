//
//  BBZSpliceGroupNode.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/24.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZSpliceGroupNode.h"


@implementation BBZSpliceNode
-(instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
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
        self.actions = array;
    }
    return self;
}

@end


@implementation BBZSpliceGroupNode
-(instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        
        id Obj = [dic objectForKey:@"splice"];
        if ([Obj isKindOfClass:[NSDictionary class]]) {
            BBZSpliceNode *node = [[BBZSpliceNode alloc] initWithDictionary:Obj];
            self.spliceNode = node;
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
        self.inputNodes = array;
    }
    return self;
}

@end
