//
//  NSError+BBZ.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/19.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (BBZ)

@property (nonatomic, readonly) NSInteger underlyingErrorCode;

+ (instancetype)errorWithBBZErrorCode:(NSInteger)code;

- (BOOL)matchErrorCodes:(NSArray<NSNumber*> *)list;

@end


#pragma mark - 错误码

//错误Domian
extern NSString * const BBZErrorDomain;

//错误码基准
#define BBZErrorCodeBase 50000


typedef NS_ENUM(NSInteger, BBZErrorCode)
{
    BBZErrorCodeUnknown = BBZErrorCodeBase,  //未知错误
    
    //通用的错误
    BBZErrorCodeInvalidFilePath    = BBZErrorCodeBase + 1,  //无效的文件路径
    BBZErrorCodeInvalidAsset       = BBZErrorCodeBase + 2,  //无效的音视频源
    BBZErrorCodeInvalidResolution  = BBZErrorCodeBase + 3,  //无效的分辨率
    BBZErrorCodeMoveFileFailed     = BBZErrorCodeBase + 4,  //转移文件失败
    BBZErrorCodeDiskSpaceFull      = BBZErrorCodeBase + 5,  //设备没有存储空间
    BBZErrorCodeCancelled          = BBZErrorCodeBase + 6,  //操作取消
    
    //数据有效性的错误
    BBZErrorCodeRestoreFailed    = BBZErrorCodeBase + 101,  //恢复数据失败
    BBZErrorCodeUnarchieveFailed = BBZErrorCodeBase + 102,  //反序列化失败
    
    //合成视频时的特殊错误
    BBZErrorCodeRestoreVideoFileNotExist  = BBZErrorCodeBase + 201,  //恢复数据失败
    BBZErrorCodeCopyMaterialFailed        = BBZErrorCodeBase + 202,  //复制素材失败
    BBZErrorCodeCheckMaterialFailed       = BBZErrorCodeBase + 203,  //校验素材失败
    BBZErrorCodeCreateWriterFailed        = BBZErrorCodeBase + 204,  //创建Writer失败
    BBZErrorCodeComposeVideoEmptySize     = BBZErrorCodeBase + 205,  //0尺寸的视频文件
    BBZErrorCodeInvertVideoInvalidParams  = BBZErrorCodeBase + 206,  //参数有误
    BBZErrorCodeInvertVideoEmptySize      = BBZErrorCodeBase + 207,  //0尺寸的视频文件
    BBZErrorCodeMergeVideoNoInputVideo    = BBZErrorCodeBase + 208,  //没有输入的视频文件
    BBZErrorCodeMergeVideoInvalidAsset    = BBZErrorCodeBase + 209,  //无效的音视频源
    BBZErrorCodeMergeVideoEmptySize       = BBZErrorCodeBase + 210,  //0尺寸的视频文件
    BBZErrorCodeExportVideoFailed         = BBZErrorCodeBase + 211,  //导出视频失败
    BBZErrorCodeExportAudioInvalidAsset   = BBZErrorCodeBase + 212,  //无效的音视频源
    BBZErrorCodeExportInterruptedBySystem = BBZErrorCodeBase + 213,  //合成被系统打断
    BBZErrorCodeReadVideoFrameFailed      = BBZErrorCodeBase + 214,  //读取视频帧失败
    BBZErrorCodeModelAssetItemsEmpty      = BBZErrorCodeBase + 215,  //AssetItems为空
    
    //相册相关的错误
    BBZErrorCodeAlbumAssetOnICloud   = BBZErrorCodeBase + 401,  //相册资源存储在iCloud端
    BBZErrorCodeAlbumAssetLoadFailed = BBZErrorCodeBase + 402,  //从相册加载资源失败
    BBZErrorCodeAlbumAssetNotExist   = BBZErrorCodeBase + 403,  //相册视频or照片资源不存在
};

NS_ASSUME_NONNULL_END
