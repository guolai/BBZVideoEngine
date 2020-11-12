//
//  BBZExportViewController.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/21.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZExportViewController2.h"
#import "BBZExportTask.h"
#import "BBZVideoModel.h"
#import <Photos/Photos.h>
#import "BBZAVAssetExportSession.h"
#import "GPUImage.h"
#import "BBZEngineSetting+VideoModel.h"

@interface BBZExportViewController2 ()
@property (nonatomic, strong) UILabel *lblProgress;
@property (nonatomic, strong) UILabel *lblInfo;
@property (nonatomic, strong) UILabel *lblTime;
@property (nonatomic, strong) UISwitch *switchBtn;
//@property (nonatomic, strong) UISwitch *switchBtn;
@property (nonatomic, strong) BBZVideoModel *model;
@property (nonatomic, strong) BBZExportTask *task;
@property (nonatomic, strong) BBZAVAssetExportSession *exportSesstion;
@end

@implementation BBZExportViewController2

- (void)dealloc {
    [self.exportSesstion cancelExport];
    self.exportSesstion = nil;
    [self.task cancel];
    self.task = nil;
    BBZLOG();
    [[GPUImageFramebufferManager shareInstance] printAllLiveObject];
}


- (void)viewDidLoad {

    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [btn setTitle:@"开始转换" forState:UIControlStateNormal];
    btn.center = self.view.center;
    btn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 100, 30)];
    [self.view addSubview:lbl];
    [lbl setTextColor:[UIColor orangeColor]];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    lbl.text = @"0%";
    self.lblProgress = lbl;
    
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(100, 40, self.view.frame.size.width-100, 30)];
    [self.view addSubview:lbl];
    [lbl setTextColor:[UIColor orangeColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    lbl.text = @"";
    self.lblTime = lbl;
    
    self.switchBtn = [UISwitch new];
    self.switchBtn.frame = CGRectMake(20, 90, 40, 20);
    self.switchBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.switchBtn.onTintColor = [UIColor greenColor];
    self.switchBtn.tintColor = [UIColor clearColor];
    [self.view addSubview:self.switchBtn];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(80, 90, self.view.frame.size.width - 80, 30)];
    [self.view addSubview:lbl];
    [lbl setTextColor:[UIColor redColor]];
    [lbl setBackgroundColor:[UIColor whiteColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    lbl.text = @"背景+缩放0.8倍+旋转45度";
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, self.view.frame.size.width, 100)];
    [self.view addSubview:lbl];
    lbl.numberOfLines = -1;
    [lbl setTextColor:[UIColor orangeColor]];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    lbl.text = @"";
    self.lblInfo = lbl;
    [self buildModel];
}

- (void)buildModel {
    BBZVideoModel *videoModel = [[BBZVideoModel alloc] init];
    
    if(self.exportType == BBZExportTypeImagesAndVideosWithBGM || self.exportType == BBZExportTypeImagesAndVideosWithBGMTranstion || self.exportType == BBZExportTypeSpliceImagesAndVideosBGM || self.exportType == BBZExportTypeImagesBGMTransition || self.exportType == BBZExportTypeMaskVideo) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"jimoshazhouleng" ofType:@"mp3" inDirectory:@"Resource"];
        [videoModel addAudioSource:path];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"douyin1" ofType:@"mp4" inDirectory:@"Resource"];
    if(self.exportType == BBZExportTypeSingleVideoCostomParamas) {
        path = [[NSBundle mainBundle] pathForResource:@"douyin3" ofType:@"mp4" inDirectory:@"Resource"];
        [videoModel addVideoSource:path];
    } else if(self.exportType == BBZExportTypeVideos ) {
        [videoModel addVideoSource:path];
        path = [[NSBundle mainBundle] pathForResource:@"douyin3" ofType:@"mp4" inDirectory:@"Resource"];
        [videoModel addVideoSource:path];
    } else if(self.exportType == BBZExportTypeImagesAndVideos) {
        [videoModel addVideoSource:path];
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"douyin2" ofType:@"mp4" inDirectory:@"Resource"];
        [videoModel addVideoSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7306" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7311" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        //        path = [[NSBundle mainBundle] pathForResource:@"IMG_7316" ofType:@"MOV" inDirectory:@"Resource"];
        //        [videoModel addVideoSource:path];
        
        //        path = [[NSBundle mainBundle] pathForResource:@"IMG_7312" ofType:@"HEIC" inDirectory:@"Resource"];
        //        [videoModel addImageSource:path];
        
        //        path = [[NSBundle mainBundle] pathForResource:@"IMG_7315" ofType:@"MOV" inDirectory:@"Resource"];
        //        [videoModel addVideoSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7317" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
    } else if(self.exportType == BBZExportTypeImagesAndVideosWithTransition) {
        [videoModel addVideoSource:path];
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"douyin2" ofType:@"mp4" inDirectory:@"Resource"];
        [videoModel addVideoSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7306" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7311" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        //        path = [[NSBundle mainBundle] pathForResource:@"IMG_7316" ofType:@"MOV" inDirectory:@"Resource"];
        //        [videoModel addVideoSource:path];
        //
        //        path = [[NSBundle mainBundle] pathForResource:@"IMG_7312" ofType:@"HEIC" inDirectory:@"Resource"];
        //        [videoModel addImageSource:path];
        //
        //        path = [[NSBundle mainBundle] pathForResource:@"IMG_7315" ofType:@"MOV" inDirectory:@"Resource"];
        //        [videoModel addVideoSource:path];
        //
        //        path = [[NSBundle mainBundle] pathForResource:@"IMG_7317" ofType:@"HEIC" inDirectory:@"Resource"];
        //        [videoModel addImageSource:path];
    } else if(self.exportType == BBZExportTypeImagesAndVideosWithBGM) {
        [videoModel addVideoSource:path];
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"douyin2" ofType:@"mp4" inDirectory:@"Resource"];
        [videoModel addVideoSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7306" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7311" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        
    } else if (self.exportType == BBZExportTypeImagesAndVideosWithBGMTranstion) {
        [videoModel addVideoSource:path];
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"douyin2" ofType:@"mp4" inDirectory:@"Resource"];
        [videoModel addVideoSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7306" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7311" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
    } else if(self.exportType == BBZExportTypeSpliceImagesAndVideosBGM){
        
        [videoModel addVideoSource:path];
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"douyin2" ofType:@"mp4" inDirectory:@"Resource"];
        [videoModel addVideoSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7306" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7311" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
    } else if(self.exportType == BBZExportTypeImagesBGMTransition){
        
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7311" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7317" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7312" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7306" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
    } else if(self.exportType == BBZExportTypeImages) {
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7311" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7317" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
    }
    else if(self.exportType == BBZExportTypeMaskVideo) {
//        [videoModel addVideoSource:path];
        
//        path = [[NSBundle mainBundle] pathForResource:@"IMG_7311" ofType:@"HEIC" inDirectory:@"Resource"];
//        [videoModel addImageSource:path];
//        
//        path = [[NSBundle mainBundle] pathForResource:@"IMG_7317" ofType:@"HEIC" inDirectory:@"Resource"];
//        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        
        path = [[NSBundle mainBundle] pathForResource:@"IMG_7312" ofType:@"HEIC" inDirectory:@"Resource"];
        [videoModel addImageSource:path];
        videoModel.useGaussImage = YES;
    }
    
    
    //    path = [NSString stringWithFormat:@"%@/Resource/demo3", [[NSBundle mainBundle] bundlePath]];
    //    [videoModel addTransitionGroup:path];
    //    [videoModel addFilterGroup:path];
    
    self.model = videoModel;
    self.lblInfo.text = [NSString stringWithFormat:@"%@",[videoModel debugSourceInfo]];
}


- (void)btnPressed:(id)sender {
    if (self.exportType == BBZExportTypeSingleVideoTransform) {
        [self beginSimpleExport];
    } else {
        [self benginVideoEngineExport];
    }
}

- (void)benginVideoEngineExport {
    BBZVideoModel *videoModel = self.model;
    
    if(self.exportType == BBZExportTypeImagesAndVideosWithTransition ||
       self.exportType == BBZExportTypeImagesAndVideosWithBGMTranstion ||
       self.exportType == BBZExportTypeImagesBGMTransition ||
       self.exportType == BBZExportTypeMaskVideo) {
        NSString *path = [NSString stringWithFormat:@"%@/Resource/transition/horizontal", [[NSBundle mainBundle] bundlePath]];
        [videoModel addTransitionGroup:path];
    } else {
        if(self.switchBtn.on ) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            UIImage *bgImage = [UIImage imageWithData:data];
            videoModel.bgImage = bgImage;
            BBZTransformItem *transformItem = [[BBZTransformItem alloc] init];
            transformItem.scale = 0.8;
            transformItem.angle = 45.0;
            //
            //            CGAffineTransform transform = CGAffineTransformIdentity;
            //            transform = CGAffineTransformScale(transform, 0.8, 0.8);
            //            transform = CGAffineTransformRotate(transform, 45*2.0*M_PI/360.0);
            videoModel.transform = transformItem;
        }
    }
    
    if(0) {
        NSMutableArray *multiArray = [NSMutableArray array];
        for (int i = 1; i < 10; i++) {
            NSString *strName = [NSString stringWithFormat:@"00%d@2x", i];
            NSString *icon = [[NSBundle mainBundle] pathForResource:strName ofType:@"png" inDirectory:@"Resource/icon"];
            NSData *data = [NSData dataWithContentsOfFile:icon];
            UIImage *image = [UIImage imageWithData:data];
            [multiArray addObject:image];
        }
        videoModel.maskImage = multiArray;
    }
    if(self.exportType == BBZExportTypeMaskVideo) {
        NSString *path = [NSString stringWithFormat:@"%@/Resource/filter/mask", [[NSBundle mainBundle] bundlePath]];
        [videoModel addFilterGroup:path];
    } else if (1) {
        NSString *path = [NSString stringWithFormat:@"%@/Resource/filter/lut", [[NSBundle mainBundle] bundlePath]];
        [videoModel addFilterGroup:path];
    }
    
    BBZEngineSetting *setting = [BBZEngineSetting  buildVideoSettings:videoModel];
    setting.videoSize = CGSizeMake(720, 720);
    setting.fillType = BBZVideoFillModePreserveAspectRatio;
    setting.videoFrameRate = 60;
    
    NSString *tmpDir =  [NSString stringWithFormat:@"%@/tmp", videoModel.videoResourceDir];
    [NSFileManager removeFileIfExist:tmpDir];
    BBZExportTask *task = [BBZExportTask taskWithModel:videoModel];
    task.videoSetting = setting;
    self.task = task;
    NSDate *date = [NSDate date];
    NSLog(@"视频保存 开始");
    
    __weak typeof(self) weakSelf = self;
    
    task.completeBlock = ^(BOOL sucess, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error)  {
            NSLog(@"视频保存Asset失败：%@",error);
        }
        NSTimeInterval costTime = [[NSDate date] timeIntervalSinceDate:date];
        NSLog(@"视频保存 Asset cost time %f",costTime);
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.lblTime.text = [NSString stringWithFormat:@"耗时：%.4f秒",costTime];
            strongSelf.lblProgress.text = [NSString stringWithFormat:@"100%%"];
        });
        if(sucess && 1) {
            NSURL *movieURL = [NSURL fileURLWithPath:strongSelf.task.outputFile];
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^(void)
             {
                 PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:movieURL];
                 request.creationDate = [NSDate date];
             }
                                              completionHandler:^(BOOL success, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^(void)
                                {
                                    if (error != nil)
                                    {
                                        NSLog(@"[SaveTask] save video failed! error: %@", error);
                                    }
                                    
                                    NSLog(@"视频保存本地成功");
                                    strongSelf.task = nil;
                                });
             }];
        }
      
    };
    task.progressBlock = ^(CGFloat progress) {
        __strong typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.lblProgress.text = [NSString stringWithFormat:@"%d%%", (int)(progress * 100)];
        });
    };
    [task start];
    self.lblInfo.text = [NSString stringWithFormat:@"%@ \n资源总时长:%.2f秒",[videoModel debugSourceInfo], videoModel.builderDuraton];
}

- (void)beginSimpleExport {
    NSDate *date = [NSDate date];
    NSLog(@"视频保存 开始");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"douyin1" ofType:@"mp4" inDirectory:@"Resource"];
    
    NSURL *sampleURL = [NSURL fileURLWithPath:path];
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie2.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToMovie]) {
        [[NSFileManager defaultManager] removeItemAtPath:pathToMovie error:nil];
    }
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:sampleURL options:nil];
    NSLog(@"%@", pathToMovie);
    BBZAVAssetExportSession *exporter = [[BBZAVAssetExportSession alloc] initWithAsset:avAsset];
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.outputURL = movieURL;
    exporter.videoSettings = [BBZExportViewController2 videoSettings:CGSizeMake(720, 1280)];
    exporter.audioSettings = [BBZExportViewController2 audioSettings];
    exporter.shouldPassThroughNatureSize = YES;
    
    __weak typeof(self) weakself = self;
    exporter.exportProgressBlock = ^(CGFloat progress) {
        __strong typeof(self) strongSelf = weakself;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.lblProgress.text = [NSString stringWithFormat:@"%d%%", (int)(progress * 100)];
        });
    };
    
    [exporter exportAsynchronouslyWithCompletionHandler:^(BBZAVAssetExportSession *exportSession){
        if (exporter.error)  {
            NSLog(@"视频保存Asset失败：%@", exporter.error);
        }
        NSTimeInterval costTime = [[NSDate date] timeIntervalSinceDate:date];
        NSLog(@"视频保存 Asset cost time %f",costTime);
        __strong typeof(self) strongSelf = weakself;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.lblTime.text = [NSString stringWithFormat:@"耗时：%.4f秒",costTime];
            strongSelf.lblProgress.text = [NSString stringWithFormat:@"100%%"];
        });
        __block NSString *localIdentifier = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^(void)
         {
             PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:movieURL];
             request.creationDate = [NSDate date];
             localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
         }
                                          completionHandler:^(BOOL success, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                if (error != nil)
                                {
                                    NSLog(@"[SaveTask] save video failed! error: %@", error);
                                }
                                
                                NSLog(@"视频保存本地成功");
                                
                            });
         }];
        
    }];
    self.exportSesstion = exporter;
}
+ (NSDictionary *)videoSettings:(CGSize)size
{
    //    NSInteger bitRate = fmin(size.width * size.height * 6.5f, 4194304); // 限制一下最大512kbps
    //    return @{
    //             AVVideoCodecKey: AVVideoCodecH264,
    //             AVVideoWidthKey: [NSNumber numberWithFloat:size.width],
    //             AVVideoHeightKey: [NSNumber numberWithFloat:size.height],
    //             AVVideoCompressionPropertiesKey: @
    //                 {
    //                 AVVideoAverageBitRateKey: @(bitRate),// @1960000,
    //                 AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel, // AVVideoProfileLevelH264Baseline31,
    //                 AVVideoMaxKeyFrameIntervalKey: @25,
    //                 },
    //             };
    NSDictionary *properties = @{ AVVideoAverageBitRateKey : @(1945748),
                                  AVVideoExpectedSourceFrameRateKey : @(30),
                                  AVVideoMaxKeyFrameIntervalKey : @(30),
                                  AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel,
                                  AVVideoAllowFrameReorderingKey : @(NO)
                                  };
    NSDictionary *videoSettings = @{
                                    AVVideoCodecKey : AVVideoCodecH264,
                                    AVVideoWidthKey : @(size.width),
                                    AVVideoHeightKey : @(size.height),
                                    AVVideoCompressionPropertiesKey : properties
                                    };
    return videoSettings;
}

+ (NSDictionary *)audioSettings
{
    AudioChannelLayout acl;
    bzero( &acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSData *channelLayoutAsData = [NSData dataWithBytes:&acl length:sizeof(acl)];
    
    return @{AVFormatIDKey: @(kAudioFormatMPEG4AAC),
             AVSampleRateKey: @(48000),
             AVEncoderBitRateKey: @(128000),
             AVChannelLayoutKey: channelLayoutAsData,
             AVNumberOfChannelsKey: @(2)};
    //    return @{
    //             AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    //             AVNumberOfChannelsKey: @2,
    //             AVSampleRateKey: @48000,
    //             AVEncoderBitRateKey: @128000,
    //             };
}

//视频格式
//使用Base Media version 2
+ (NSString *)outputFileType
{
    return AVFileTypeMPEG4;
}
@end
