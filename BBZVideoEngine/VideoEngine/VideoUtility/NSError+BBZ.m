//
//  NSError+BBZ.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/19.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "NSError+BBZ.h"

NSString * const BBZErrorDomain = @"BBZVideoEngineError";


@implementation NSError (BBZ)

+ (instancetype)errorWithBBZErrorCode:(NSInteger)code {
    return [NSError errorWithDomain:BBZErrorDomain code:code userInfo:nil];
}

- (NSInteger)underlyingErrorCode {
    NSError *error = self.userInfo[NSUnderlyingErrorKey];
    return error ? error.code : 0;
}

- (BOOL)matchErrorCodes:(NSArray<NSNumber*> *)list {
    NSInteger code;
    NSInteger underlyingErrorCode = self.underlyingErrorCode;
    
    for (NSNumber *number in list)  {
        code = number.integerValue;
        if ((code == self.code) || (code == underlyingErrorCode)) {
            return YES;
        }
    }
    
    return NO;
}

@end
