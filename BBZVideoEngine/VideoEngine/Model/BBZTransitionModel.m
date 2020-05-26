//
//  BBZTransitionModel.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZTransitionModel.h"
#import "NSDictionary+YYAdd.h"


@interface BBZTransitionModel ()
@property (nonatomic, assign, readwrite) CGFloat minVersion;
@end


@implementation BBZTransitionModel

- (instancetype)init {
    if(self = [super init]) {
        _minVersion = 1.0;
    }
    return self;
}

- (instancetype)initWidthDir:(NSString *)filePath {
    if([self init]) {
        _filePath = filePath;
        [self parseFileContent];
    }
    return nil;
}

- (void)parseFileContent {
    BOOL isDirectory = NO;
    if(self.filePath.length == 0 ||
       ![[NSFileManager defaultManager] fileExistsAtPath:self.filePath isDirectory:&isDirectory] ||
       !isDirectory) {
        BBZERROR(@"directory not exsit, %@", self.filePath);
        return;
    }
    NSString *strFilterFile = [NSString stringWithFormat:@"%@/Splice.xml", self.filePath];
    if([[NSFileManager defaultManager] fileExistsAtPath:strFilterFile]) {
        NSMutableArray *array = [NSMutableArray array];
        NSData *data = [NSData  dataWithContentsOfFile:strFilterFile];
        NSDictionary *dic = [NSDictionary dictionaryWithXML:data];
        if(dic) {
            self.minVersion = [[dic objectForKey:@"miniVersion"] floatValue];
            id inputGroup = dic[@"inputGroup"];
            if ([inputGroup isKindOfClass:[NSArray class]]) {
                for (NSDictionary *item in inputGroup) {
                    BBZSpliceGroupNode *node = [[BBZSpliceGroupNode alloc] initWithDictionary:item withFilePath:self.filePath];
                    [array addObject:node];
                }
            } else if ([inputGroup isKindOfClass:[NSDictionary class]]) {
                BBZSpliceGroupNode *node = [[BBZSpliceGroupNode alloc] initWithDictionary:inputGroup withFilePath:self.filePath];
                [array addObject:node];
            }
            [array sortUsingComparator:^NSComparisonResult(BBZSpliceGroupNode *obj1, BBZSpliceGroupNode *obj2) {
                return (obj1.order<obj2.order)?NSOrderedAscending:NSOrderedDescending;
            }];
            _spliceGroups = array;
        }
    } else {
        BBZERROR(@"splice file not exsit, %@", strFilterFile);
    }
    
    strFilterFile = [NSString stringWithFormat:@"%@/Transition.xml", self.filePath];
    if([[NSFileManager defaultManager] fileExistsAtPath:strFilterFile]) {
        NSMutableArray *array = [NSMutableArray array];
        NSData *data = [NSData  dataWithContentsOfFile:strFilterFile];
        NSDictionary *dic = [NSDictionary dictionaryWithXML:data];
        if(dic) {
            self.minVersion = MIN([[dic objectForKey:@"miniVersion"] floatValue], self.minVersion);
            id inputGroup = dic[@"inputGroup"];
            if ([inputGroup isKindOfClass:[NSArray class]]) {
                for (NSDictionary *item in inputGroup) {
                    BBZTransitionGroupNode *node = [[BBZTransitionGroupNode alloc] initWithDictionary:item withFilePath:self.filePath];
                    [array addObject:node];
                }
            } else if ([inputGroup isKindOfClass:[NSDictionary class]]) {
                BBZTransitionGroupNode *node = [[BBZTransitionGroupNode alloc] initWithDictionary:inputGroup withFilePath:self.filePath];
                [array addObject:node];
            }
            [array sortUsingComparator:^NSComparisonResult(BBZTransitionGroupNode *obj1, BBZTransitionGroupNode *obj2) {
                return (obj1.order<obj2.order)?NSOrderedAscending:NSOrderedDescending;
            }];
            _transitionGroups = array;
        }
    } else {
        BBZERROR(@"transition file not exsit, %@", strFilterFile);
    }
    
}
@end
