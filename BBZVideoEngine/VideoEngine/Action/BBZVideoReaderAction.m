//
//  BBZVideoReaderAction.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/29.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "BBZVideoReaderAction.h"
#import "BBZAssetReader.h"
#import "BBZVideoAsset.h"

@interface BBZVideoReaderAction ()
@property (nonatomic, strong) BBZAssetReader *reader;
@property (nonatomic, strong) BBZAssetReaderSequentialAccessVideoOutput *videoOutPut;
@end


@implementation BBZVideoReaderAction


- (void)buildReader {
    if(!self.reader) {
        BBZVideoAsset *videoAsset = (BBZVideoAsset *)self.asset;
        self.reader = [[BBZAssetReader alloc] initWithAsset:(AVAsset *)videoAsset.asset];
        self.reader.timeRange = videoAsset.playTimeRange;
        self.videoOutPut = [[BBZAssetReaderSequentialAccessVideoOutput alloc] initWithOutputSettings:nil];
        [self.reader addOutput:self.videoOutPut];
    }
}

- (void)updateWithTime:(CMTime)time {
    
}

- (void)newFrameAtTime:(CMTime)time {
    
}

- (void)lock {
    [super lock];
    [self buildReader];
    [self.videoOutPut startProcessing];
}

- (void)destroySomething{
    [self.videoOutPut endProcessing];
    [self.reader removeOutput:self.videoOutPut];
    self.videoOutPut = nil;
    self.reader = nil;
}

@end
