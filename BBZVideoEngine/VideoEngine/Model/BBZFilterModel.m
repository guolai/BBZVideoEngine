//
//  BBZFilterModel.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/22.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZFilterModel.h"
#import "NSDictionary+YYAdd.h"

@interface BBZFilterModel ()
@property (nonatomic, assign, readwrite) CGFloat duration;
@property (nonatomic, assign, readwrite) CGFloat minVersion;

@end

@implementation BBZFilterModel

- (instancetype)init {
    if(self = [super init]) {
        _duration = 1.0;
        _minVersion = 1.0;
    }
    return self;
}

- (instancetype)initWidthDir:(NSString *)filePath {
    if([self init]) {
        _filePath = filePath;
        [self parseFileContent];
    }
    return self;
}

- (void)parseFileContent {
    BOOL isDirectory = NO;
    if(self.filePath.length == 0 ||
       ![[NSFileManager defaultManager] fileExistsAtPath:self.filePath isDirectory:&isDirectory] ||
       !isDirectory) {
        BBZERROR(@"directory not exsit, %@", self.filePath);
        return;
    }
    NSString *strFilterFile = [NSString stringWithFormat:@"%@/Filter.xml", self.filePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:strFilterFile]) {
        BBZERROR(@"file not exsit, %@", strFilterFile);
        return;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    NSData *data = [NSData  dataWithContentsOfFile:strFilterFile];
    NSDictionary *dic = [NSDictionary dictionaryWithXML:data];
    if(dic) {
//        self.duration = [[dic objectForKey:@"duration"] floatValue];
        self.minVersion = [[dic objectForKey:@"miniVersion"] floatValue];
        id inputGroup = dic[@"filter"];
        if ([inputGroup isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in inputGroup) {
                BBZFilterNode *node = [[BBZFilterNode alloc] initWithDictionary:item withFilePath:self.filePath];
                [array addObject:node];
            }
        } else if ([inputGroup isKindOfClass:[NSDictionary class]]) {
            BBZFilterNode *node = [[BBZFilterNode alloc] initWithDictionary:inputGroup withFilePath:self.filePath];
            [array addObject:node];
        }
        _filterGroups = array;
    }
}


@end
