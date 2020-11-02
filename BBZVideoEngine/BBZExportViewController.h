//
//  BBZExportViewController.h
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/21.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BBZExportType) {
    BBZExportTypeSingleVideoTransform = 0,
    BBZExportTypeSingleVideoCostomParamas = 1,
    BBZExportTypeVideos = 2,
    BBZExportTypeImagesAndVideos = 3,
    BBZExportTypeImagesAndVideosWithTransition = 4,
    BBZExportTypeImagesAndVideosWithBGM = 5,
    BBZExportTypeImagesAndVideosWithBGMTranstion = 6,
    BBZExportTypeSpliceImagesAndVideosBGM = 7,
    BBZExportTypeImagesBGMTransition = 8,
    BBZExportTypeImages = 9,
    BBZExportTypeMaskVideo = 10,

};

@interface BBZExportViewController : UIViewController
@property (nonatomic, assign) BBZExportType exportType;

@end

