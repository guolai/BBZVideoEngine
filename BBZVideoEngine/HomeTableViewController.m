//
//  HomeTableViewController.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/8.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "HomeTableViewController.h"
#import "BBZExportViewController.h"
#import "BBZExportViewController2.h"
#import "BBZVideoModel.h"

@interface HomeTableViewController ()
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) BOOL bUseExportSquare;
@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    self.bUseExportSquare = YES;
    [super viewDidLoad];
    self.array = [NSMutableArray array];
    [self.array addObject:@"单视频尺寸转换"];
    [self.array addObject:@"单视频自定义参数转换"];
    [self.array addObject:@"多视频合成"];
    [self.array addObject:@"相片+视频合成"];
    [self.array addObject:@"相片+视频+转场 合成"];
    [self.array addObject:@"相片+视频+音乐 合成"];
    [self.array addObject:@"相片+视频+音乐+转场 合成"];
    [self.array addObject:@"拼接(相片/视频)+音乐+转场 合成"];
    [self.array addObject:@"相片+音乐+转场 合成"];
    [self.array addObject:@"相片 合成"];
    [self.array addObject:@"Mask视频"];
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
    if(self.bUseExportSquare) {
        BBZExportViewController2 *vc = [[BBZExportViewController2 alloc] init];
        vc.exportType = indexPath.row;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        BBZExportViewController *vc = [[BBZExportViewController alloc] init];
        vc.exportType = indexPath.row;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}



@end
