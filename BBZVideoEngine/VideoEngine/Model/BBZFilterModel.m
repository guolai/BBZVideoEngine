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
@property (nonatomic, strong) NSMutableArray *interFilterGroup;

@end

@implementation BBZFilterModel

- (instancetype)init {
    if(self = [super init]) {
        _interFilterGroup = [NSMutableArray arrayWithCapacity:2];
        _duration = 1.0;
        _minVersion = 1.0;
    }
    return self;
}

- (instancetype)initWidthFilePath:(NSString *)filePath {
    if([self init]) {
        _filePath = filePath;
        [self parseFileContent];
    }
    return nil;
}

- (void)parseFileContent {
    if(self.filePath.length == 0 ||
       ![[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        BBZERROR(@"filePath not exsit, %@", self.filePath);
        return;
    }
    NSData *data = [NSData  dataWithContentsOfFile:self.filePath];
    NSDictionary *dic = [NSDictionary dictionaryWithXML:data];
    if(dic) {
        self.duration = [[dic objectForKey:@"duration"] floatValue];
        self.minVersion = [[dic objectForKey:@"miniVersion"] floatValue];
        id inputGroup = dic[@"filterGroup"];
        if ([inputGroup isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *item in inputGroup)
            {
//                MVTransitionInputGroup *group = [[MVTransitionInputGroup alloc] initWithDic:item dir:dir];
//                [self.inputGroups addObject:group];
            }
        }
        else if ([inputGroup isKindOfClass:[NSDictionary class]])
        {
//            [self.inputGroups addObject:[[MVTransitionInputGroup alloc] initWithDic:inputGroup dir:dir]];
        }
    }
}

- (NSArray *)filterGroup {
    return self.interFilterGroup;
}

@end
