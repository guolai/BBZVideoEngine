//
//  HomeTableViewController.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/8.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "HomeTableViewController.h"
#import "BBZExportViewController.h"
#import "BBZVideoModel.h"

@interface HomeTableViewController ()
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = [NSMutableArray array];
    [self.array addObject:@"单视频尺寸转换"];
    [self.array addObject:@"单视频自定义参数转换"];
    [self.array addObject:@"多视频合成"];
    [self.array addObject:@"相片+视频合成"];
    [self.array addObject:@"相片+视频+转场 合成"];
    [self.array addObject:@"相片+视频+音乐 合成"];
    [self test];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    cell.textLabel.text = [self.array objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBZExportViewController *vc = [[BBZExportViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Test

- (void)test {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Filter" ofType:@"xml" inDirectory:@"Resource/demo3"];
    NSString *path = [NSString stringWithFormat:@"%@/Resource/demo3", [[NSBundle mainBundle] bundlePath]];
    BBZVideoModel *videoModel = [[BBZVideoModel alloc] init];
//    videoModel
    BBZINFO(@"%@", videoModel);
}

@end
