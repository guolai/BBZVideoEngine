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


@interface BBZExportViewController ()
@property (nonatomic, strong) UILabel *lblProgress;
@end

@implementation BBZExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    btn.center = self.view.center;
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [self.view addSubview:lbl];
    [lbl setTextColor:[UIColor orangeColor]];
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
    path = [NSString stringWithFormat:@"%@/Resource/demo3", [[NSBundle mainBundle] bundlePath]];
    [videoModel addTransitionGroup:path];
    [videoModel addFilterGroup:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
    BBZImageAsset *imageAsset = [BBZImageAsset assetWithFilePath:path];
    videoModel.bgImageAsset = imageAsset;
    
    BBZExportTask *task = [BBZExportTask taskWithModel:videoModel];
    [task start];
    
}

@end
