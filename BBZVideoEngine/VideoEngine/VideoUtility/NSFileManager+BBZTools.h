//
//  NSFileManager+BBZTools.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (BBZTools)

- (BOOL)moveFile:(NSString *)originFilePath toPath:(NSString *)newFilePath replaceIfExist:(BOOL)replaceIfExist;
- (NSInteger)sizeOfFile:(NSString *)file;
+ (BOOL)createDirIfNeed:(NSString *)dir;
+ (BOOL)removeFileIfExist:(NSString *)file;

@end

NS_ASSUME_NONNULL_END
