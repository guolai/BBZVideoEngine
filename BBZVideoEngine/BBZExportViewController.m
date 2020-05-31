//
//  BBZExportViewController.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/21.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZExportViewController.h"
#import "BBZExportTask.h"
#import "BBZVideoModel.h"
#import <Photos/Photos.h>


@interface BBZExportViewController ()
@property (nonatomic, strong) UILabel *lblProgress;
@property (nonatomic, strong) BBZExportTask *task;
@end

@implementation BBZExportViewController

- (void)dealloc {
    [self.task cancel];
    self.task = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [btn setTitle:@"开始转换" forState:UIControlStateNormal];
    btn.center = self.view.center;
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [self.view addSubview:lbl];
    [lbl setTextColor:[UIColor orangeColor]];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    lbl.text = @"0%";
    self.lblProgress = lbl;
}


- (void)btnPressed:(id)sender {
    
    [self beginExport];
}

- (void)beginExport {
    BBZVideoModel *videoModel = [[BBZVideoModel alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG2" ofType:@"MOV" inDirectory:@"Resource"];
    [videoModel addVideoSource:path];
    path = [[NSBundle mainBundle] pathForResource:@"IMG_7316" ofType:@"MOV" inDirectory:@"Resource"];
    [videoModel addVideoSource:path];
    
//    path = [NSString stringWithFormat:@"%@/Resource/demo3", [[NSBundle mainBundle] bundlePath]];
//    [videoModel addTransitionGroup:path];
//    [videoModel addFilterGroup:path];

//    path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
//    [videoModel addImageSource:path];
//
//    path = [[NSBundle mainBundle] pathForResource:@"IMG_7306" ofType:@"HEIC" inDirectory:@"Resource"];
//    [videoModel addImageSource:path];
//
//    path = [[NSBundle mainBundle] pathForResource:@"IMG_7311" ofType:@"HEIC" inDirectory:@"Resource"];
//    [videoModel addImageSource:path];
//
//    path = [[NSBundle mainBundle] pathForResource:@"IMG_7312" ofType:@"HEIC" inDirectory:@"Resource"];
//    [videoModel addImageSource:path];
//
//    path = [[NSBundle mainBundle] pathForResource:@"IMG_7317" ofType:@"HEIC" inDirectory:@"Resource"];
//    [videoModel addImageSource:path];

//    path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    UIImage *bgImage = [UIImage imageWithData:data];
//    videoModel.bgImage = bgImage;
    NSString *tmpDir =  [NSString stringWithFormat:@"%@/tmp", videoModel.videoResourceDir];
    [NSFileManager removeFileIfExist:tmpDir];
    BBZExportTask *task = [BBZExportTask taskWithModel:videoModel];
    self.task = task;
    __weak typeof(self) weakSelf = self;
    task.completionBlock = ^(BOOL sucess, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
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
                                    
                                });
             }];
        }
    };
    [task start];
    
}

@end
