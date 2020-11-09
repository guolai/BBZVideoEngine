//
//  BBZFilterNode.m
//  BBZVideoEngine
//
//  Created by bob on 2020/4/22.
//  Copyright © 2020年 BBZ. All rights reserved.
//

#import "BBZFilterNode.h"
#import "NSDictionary+YYAdd.h"

extern NSString *const BBZFilterMovieEnding;

@interface BBZFilterNode ()
@property (nonatomic, assign, readwrite) BOOL hasEnding;
@end

@implementation BBZFilterNode
- (instancetype)initWithDictionary:(NSDictionary *)dic withFilePath:(NSString *)filePath {
    if (self = [super init]) {
        _filePath = filePath;
        self.begin = [dic floatValueForKey:@"begin" default:0.0];
        self.duration = [dic floatValueForKey:@"duration" default:0.0];
        self.index = [dic intValueForKey:@"index" default:0];
//        self.repeat = [dic intValueForKey:@"repeat" default:1];
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


- (BOOL)bPlayFromEnd {
    return self.begin < 0.0;
}


- (BBZNode *)endingAction {
    BBZNode *retAction = nil;
    for (BBZNode *node in self.actions) {
        if([node.name isEqualToString:BBZFilterMovieEnding]) {
            retAction = node;
            break;
        }
    }
    return retAction;
}

@end
