//
//  HomeTableViewController.m
//  BBZVideoEngine
//
//  Created by Hbo on 2020/4/8.
//  Copyright © 2020 BBZ. All rights reserved.
//

#import "HomeTableViewController.h"
#define BBINFO(fmt, ...)          NSLog(@"[%@:%d]"fmt, \
[[NSString stringWithFormat:@"%s", __FILE__] lastPathComponent], \
__LINE__, \
##__VA_ARGS__)
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
    BBINFO(@"test");
//    UIImage *image = [UIImage imageNamed:@"IMG_7317.HEIC"];
//    BBINFO(@"%@", image);
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
    UIViewController *vc = nil;
   
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end