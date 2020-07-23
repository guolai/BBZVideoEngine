# BBZVideoEngine
音视频编辑及导出引擎

支持视频+相片+贴纸+特效+转场进行预览 及合成 
* 多视频合成框架
* 相册与视频混拍合成框架 
* 视频与相片转场框架


# 一期先完成视频合成导出功能


1. 支持不同分辩率，不同码率视频合成为一个分辩率一个码率的视频文件(分辩率及码率可以自适应，也可以使用指定参数)
1. 支持横竖屏强转
1. 支持混音功能 
1. 支持单个视频资源，在资源的时长范围内，指定片段或者全时长使用特效资源
1. 支持视频资源全局特效及水印贴纸功能添加
1. 合成视频资源的特效及贴纸水印支持动态配置及默认配置功能
1. 特效底层框架使用自定义GPU框架

1. 转场资源描述 
1. 转场时间线排布 
1. 转场后滤镜链树实现 
1. 滤镜链树状资源时间线排布资源管理 
1. 滤镜链优化管理

## 整体框架图
![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/AVFoundation.png)
![Image text](https://github.com/guolai/testCoreData/blob/master/AVFoundation.png)


## 音视频引擎架构图
![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/AVFoundatioSimpleClass.png)
![Image text](https://github.com/guolai/testCoreData/blob/master/AVFoundatioSimpleClass.png)

## 类结构概览
![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/class.png)
![Image text](https://github.com/guolai/testCoreData/blob/master/class.png)

## 音视频处理工作流
![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/DescriptionWorkFlow.png)
![Image text](https://github.com/guolai/testCoreData/blob/master/DescriptionWorkFlow.png)

![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/VideoEngineWorkFlow.png)
![Image text](https://github.com/guolai/testCoreData/blob/master/VideoEngineWorkFlow.png)


## 转场时间轴示意
![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/TransitionFlow.png)
![Image text](https://github.com/guolai/testCoreData/blob/master/TransitionFlow.png)

## 树状滤镜链管理
![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/FilterTreeManage.png)
![Image text](https://github.com/guolai/testCoreData/blob/master/FilterTreeManage.png)

## 拼接及转场滤镜链
![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/transitionAndSplice.png)
![Image text](https://github.com/guolai/testCoreData/blob/master/transitionAndSplice.png)

## 滤镜链优化处理
![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/FilterOptimization.png)
![Image text](https://github.com/guolai/testCoreData/blob/master/FilterOptimization.png)

## 代码使用示例
### 创建model
(''')
    BBZVideoModel *videoModel = [[BBZVideoModel alloc] init];   
(''')

### 加入图片资源
(```)
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
    [videoModel addImageSource:path];  
(```)

### 加入视频资源
(```)
    NSString *path = [[NSBundle mainBundle] pathForResource:@"douyin3" ofType:@"mp4" inDirectory:@"Resource"];
    [videoModel addVideoSource:path];
(```)

### 加入背景音乐
(```)
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jimoshazhouleng" ofType:@"mp3" inDirectory:@"Resource"];
    [videoModel addAudioSource:path];
(```)

### 指定转场资源路径
(```)
    NSString *path = [NSString stringWithFormat:@"%@/Resource/demo2", [[NSBundle mainBundle] bundlePath]];
    [videoModel addTransitionGroup:path];
(```)

### 加入视频或者图集 支持加入背景图片，并对内容进行缩放和旋转
(```)
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *bgImage = [UIImage imageWithData:data];
    videoModel.bgImage = bgImage;
    BBZTransformItem *transformItem = [[BBZTransformItem alloc] init];
    transformItem.scale = 0.8;
    transformItem.angle = 45.0;
    videoModel.transform = transformItem;
(```)

### 视频水印支持动态图片序列帧
(```)
    NSMutableArray *multiArray = [NSMutableArray array];
    for (int i = 1; i < 10; i++) {
        NSString *strName = [NSString stringWithFormat:@"00%d@2x", i];
        NSString *icon = [[NSBundle mainBundle] pathForResource:strName ofType:@"png" inDirectory:@"Resource/icon"];
        NSData *data = [NSData dataWithContentsOfFile:icon];
        UIImage *image = [UIImage imageWithData:data];
        [multiArray addObject:image];
    }
    videoModel.maskImage = multiArray;
(```)

### 启动合成任务
(```)
    BBZExportTask *task = [BBZExportTask taskWithModel:videoModel];
    task.completeBlock = ^(BOOL sucess, NSError *error) {
    };
    task.progressBlock = ^(CGFloat progress) {
    };
    [task start];
(```)