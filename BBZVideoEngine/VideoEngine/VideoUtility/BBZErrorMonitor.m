//
//  BBZErrorMonitor.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/19.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZErrorMonitor.h"
#import "JRSwizzle.h"

@interface BBZErrorMonitor()

@property (nonatomic,strong) NSMutableArray *errorObservers;

@end

@implementation BBZErrorMonitor

+ (instancetype)shareInstance {
    static BBZErrorMonitor *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BBZErrorMonitor alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _errorObservers = [NSMutableArray array];
    }
    return self;
}

- (void)addErrorBlock:(void (^)(NSError *))block {
    [self.errorObservers addObject:[block copy]];
}

- (void)comeUpError:(NSError*)error {
    for ( void (^block)(NSError *) in self.errorObservers) {
        block(error);
    }
}

@end

@interface NSError (BBZErrorMonitor)

@end

@implementation NSError (BBZErrorMonitor)
+ (void)load {
    [self jr_swizzleMethod:@selector(initWithDomain:code:userInfo:) withMethod:@selector(BBZErrorMonitor_initWithDomain:code:userInfo:) error:nil];
}

- (instancetype)BBZErrorMonitor_initWithDomain:(NSErrorDomain)domain code:(NSInteger)code userInfo:(nullable NSDictionary *)dict {
    id result = [self BBZErrorMonitor_initWithDomain:domain code:code userInfo:dict];
    [[BBZErrorMonitor shareInstance] comeUpError:self];
    return result;
}
@end

