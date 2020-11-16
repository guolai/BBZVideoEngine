//
//  BBZSpliceGroupNode.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/24.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZSpliceGroupNode.h"
#import "NSDictionary+BBZVE.h"

@implementation BBZSpliceNode
-(instancetype)initWithDictionary:(NSDictionary *)dic withFilePath:(NSString *)filePath {
    if (self = [super init]) {
        _filePath = filePath;
        id Obj = [dic objectForKey:@"action"];
        NSMutableArray *array = [NSMutableArray array];
        if ([Obj isKindOfClass:[NSDictionary class]]) {
            BBZNode *node = [[BBZNode alloc] initWithDictionary:Obj withFilePath:self.filePath];
            [array addObject:node];
        } else if ([Obj isKindOfClass:[NSArray class]]) {
            for (NSDictionary *subDic in Obj) {
                BBZNode *node = [[BBZNode alloc] initWithDictionary:subDic withFilePath:self.filePath];
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


@implementation BBZSpliceGroupNode
-(instancetype)initWithDictionary:(NSDictionary *)dic withFilePath:(NSString *)filePath {
    if (self = [super init]) {
        self.minDuration = [dic BBZVEfloatValueForKey2:@"duration" default:0.0];
        self.order = [dic BBZVEintValueForKey:@"order" default:0];
        id Obj = [dic objectForKey:@"splice"];
        if ([Obj isKindOfClass:[NSDictionary class]]) {
            BBZSpliceNode *node = [[BBZSpliceNode alloc] initWithDictionary:Obj withFilePath:self.filePath];
            self.spliceNode = node;
        } else if ([Obj isKindOfClass:[NSArray class]]) {
            NSAssert(false, @"not support");
        }
        
        Obj = [dic objectForKey:@"input"];
        NSMutableArray *array = [NSMutableArray array];
        if ([Obj isKindOfClass:[NSDictionary class]]) {
            BBZInputNode *node = [[BBZInputNode alloc] initWithDictionary:Obj withFilePath:self.filePath];
            [array addObject:node];
        } else if ([Obj isKindOfClass:[NSArray class]]) {
            for (NSDictionary *subDic in Obj) {
                BBZInputNode *node = [[BBZInputNode alloc] initWithDictionary:subDic withFilePath:self.filePath];
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
