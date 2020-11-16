//
//  BBZInputNode.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/23.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZInputNode.h"
#import "NSDictionary+BBZVE.h"

@implementation BBZInputNode

-(instancetype)initWithDictionary:(NSDictionary *)dic  withFilePath:(NSString *)filePath{
    if (self = [super init]) {
        _filePath = filePath;
        self.index = [dic BBZVEintValueForKey:@"index" default:0];
        self.playOrder = [dic BBZVEintValueForKey:@"playOrder" default:0];
        self.scale = [dic BBZVEdoubleValueForKey2:@"scale" default:1.0];
        self.assetOrder = [dic BBZVEintValueForKey:@"assetOrder" default:0];
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
        self.actions = array;
    }
    return self;
}

@end

