
# BBZVideoEngine
音视频编辑导出引擎架构设计--支持视频+相片+贴纸+特效+转场+画面宫格进行编辑预览合成


# 目的 ：

随着社交类APP抖音快手带动短视频行业的爆火，越来越多的行业参与到了短视频这个领域。比如以电商为代表的淘宝拼多多，以及以及东南亚电商。

之前在腾讯主要负责了发布器引擎相关开发与设计，一直在思考如何实现一套比较完美的音视频编辑引擎，可以在支持扩展的情况下，又极大的保持性能与内存占用的最小化实现.
对比了行业内常见三种音视频引擎实现方案在性能及扩展能力方面的指标，最终决定了当前开源音视频引擎架构原型。

希望可以帮助更多的使用者可以在这块少走一些弯路、少掉一些坑，以更加合理的功能架构设计，在实现当前需求的功能前提下，为以后产品功能的快速迭代预留好新增功能的接口。同时在性能提升方面尽可能做到极致，占用更少的内存CPU资源

当然写这个框架是利用了一些业余时间来完成的，还有一些功能点未进行开发

有任何使用过程中的有比较好的建议或者问题，欢迎加VX：HaoYeO88 交流

# 功能：

* 多视频合成框架 
    1. 支持不同分辩率，不同码率视频合成为一个分辩率一个码率的视频文件(分辩率及码率可以自适应，也可以使用指定参数)
    2. 支持横竖屏强转
    3. 支持单个视频资源，在资源的时长范围内，指定片段或者全时长使用特效资源
* 相册与视频混拍合成框架 
* 视频与相片转场框架 
* 目前已支持抖音常见消融 画面分格碎裂 擦除 左右上下 百叶窗 淡入淡出 波纹等效果 
* 多画面拼接场景支持 
* 抖音常见的三格左中右 四格 9宫格均支持，另外支持自定义形状GLSL渲染
* 支持各种视频特效 
    1. 目前已实现 支持LUT，波纹，mask视频等
    2. 支持视频资源全局特效及水印贴纸功能添加
* 支持视频添加贴纸 
* 支持添加背景音乐  支持混音功能
* 以上所有功能均支持动态下发 

# 功能优化点特性：

* 特效底层框架使用自定义GPU框架
* 转场/特效/贴纸/音频/宫格 资源描述
* 转场/特效/贴纸/音频/宫格 时间线排布 
* 滤镜链树状资源时间线排布资源管理  
    1. 支持特效限定区间，
    2. 不同区间参数动态调整 
    3. 资源使用中创建，使用完立即释放
* 滤镜链优化管理 
    1. 减少视频合成时长 
    2. 减少视频合成中内存占用

# 待完成功能：

* 粒子特效实现 
* 人脸模型支持 
* 3D贴纸支持 
* AR场景支持 
* AI特效引入
* 字幕引入


## 整体框架图
<!-- ![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/AVFoundation.png) -->
![Image text](https://github.com/guolai/testCoreData/blob/master/AVFoundation.png)


## 音视频引擎架构图
<!-- ![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/AVFoundatioSimpleClass.png) -->
![Image text](https://github.com/guolai/testCoreData/blob/master/AVFoundatioSimpleClass.png)

## 类结构概览
<!-- ![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/class.png) -->
![Image text](https://github.com/guolai/testCoreData/blob/master/class.png)

## 音视频处理工作流
<!-- ![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/DescriptionWorkFlow.png) -->
![Image text](https://github.com/guolai/testCoreData/blob/master/DescriptionWorkFlow.png)

<!-- ![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/VideoEngineWorkFlow.png) -->
![Image text](https://github.com/guolai/testCoreData/blob/master/VideoEngineWorkFlow.png)


## 转场时间轴示意
<!-- ![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/TransitionFlow.png) -->
![Image text](https://github.com/guolai/testCoreData/blob/master/TransitionFlow.png)

## 树状滤镜链管理
<!-- ![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/FilterTreeManage.png) -->
![Image text](https://github.com/guolai/testCoreData/blob/master/FilterTreeManage.png)

## 拼接及转场滤镜链
<!-- ![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/transitionAndSplice.png) -->
![Image text](https://github.com/guolai/testCoreData/blob/master/transitionAndSplice.png)

## 滤镜链优化处理
<!-- ![Image text](http://raw.githubusercontent.com/guolai/testCoreData/master/FilterOptimization.png) -->
![Image text](https://github.com/guolai/testCoreData/blob/master/FilterOptimization.png)

## 代码使用示例
### 创建model

    BBZVideoModel *videoModel = [[BBZVideoModel alloc] init];   


### 加入图片资源

    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
    [videoModel addImageSource:path];  


### 加入视频资源

    NSString *path = [[NSBundle mainBundle] pathForResource:@"douyin3" ofType:@"mp4" inDirectory:@"Resource"];
    [videoModel addVideoSource:path];


### 加入背景音乐

    NSString *path = [[NSBundle mainBundle] pathForResource:@"jimoshazhouleng" ofType:@"mp3" inDirectory:@"Resource"];
    [videoModel addAudioSource:path];


### 指定转场资源路径

    NSString *path = [NSString stringWithFormat:@"%@/Resource/demo2", [[NSBundle mainBundle] bundlePath]];
    [videoModel addTransitionGroup:path];


### 加入视频或者图集 支持加入背景图片，并对内容进行缩放和旋转

    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_7305" ofType:@"HEIC" inDirectory:@"Resource"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *bgImage = [UIImage imageWithData:data];
    videoModel.bgImage = bgImage;
    BBZTransformItem *transformItem = [[BBZTransformItem alloc] init];
    transformItem.scale = 0.8;
    transformItem.angle = 45.0;
    videoModel.transform = transformItem;


### 视频水印支持动态图片序列帧

    NSMutableArray *multiArray = [NSMutableArray array];
    for (int i = 1; i < 10; i++) {
        NSString *strName = [NSString stringWithFormat:@"00%d@2x", i];
        NSString *icon = [[NSBundle mainBundle] pathForResource:strName ofType:@"png" inDirectory:@"Resource/icon"];
        NSData *data = [NSData dataWithContentsOfFile:icon];
        UIImage *image = [UIImage imageWithData:data];
        [multiArray addObject:image];
    }
    videoModel.maskImage = multiArray;


### 启动合成任务

    BBZExportTask *task = [BBZExportTask taskWithModel:videoModel];
    task.completeBlock = ^(BOOL sucess, NSError *error) {
    };
    task.progressBlock = ^(CGFloat progress) {
    };
    [task start];
