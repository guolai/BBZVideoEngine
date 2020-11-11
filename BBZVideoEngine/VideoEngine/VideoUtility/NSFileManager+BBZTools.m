//
//  NSFileManager+BBZTools.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/20.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "NSFileManager+BBZTools.h"
#import "BBZVideoEngineHeader.h"


@implementation NSFileManager (BBZTools)
- (BOOL)moveFile:(NSString *)originFilePath toPath:(NSString *)newFilePath replaceIfExist:(BOOL)replaceIfExist {
    if ([self fileExistsAtPath:originFilePath isDirectory:nil] == NO) {
        BBZERROR(@"移动文件失败，需要移动的文件不存在");
        return NO;
    }
    
    NSError *error = nil;
    if ([self fileExistsAtPath:newFilePath isDirectory:nil]) {
        if (replaceIfExist == NO) {
            return YES;
        }
        
        if ([self isDeletableFileAtPath:newFilePath] == NO) {
            BBZERROR(@"移动文件失败，目标地址已经存在文件，并且不能被删除。");
            return NO;
        }
        
        [self removeItemAtPath:newFilePath error:&error];
        
        if (error) {
            BBZERROR(@"移动文件失败，目标地址已经存在文件，删除该文件失败。原因:%@",error);
            return NO;
        }
    }
    
    BOOL result = [self moveItemAtPath:originFilePath toPath:newFilePath error:&error];
    
    if (error) {
        BBZERROR(@"移动文件失败。原因:%@",error);
    }
    
    return result;
}

- (NSInteger)sizeOfFile:(NSString *)file {
    if (![self fileExistsAtPath:file]) {
        return 0;
    }
    NSError *error;
    NSDictionary *fileAttributes = [self attributesOfItemAtPath:file error:&error]; 
    if (error) {
        BBZERROR(@"read sizeOfFile: %@; error:%@", file, error);
    }
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    NSInteger fileSize = [fileSizeNumber integerValue];
    return fileSize;
}

+ (BOOL)createDirIfNeed:(NSString *)dir {
    BOOL isDir;
    BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir];
    if (isDirExist && isDir) {
        return YES;
    }
    NSError *error;
    BOOL succ = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        BBZERROR(@"create directory(%d) with error(%ld):%@", succ, (long)error.code, error.localizedDescription);
    }
    return YES;
}

+ (BOOL)removeFileIfExist:(NSString *)file {
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:file error:&error];
        return error == nil;
    }
    return YES;
    
}
@end
