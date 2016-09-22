//
//  FullScreenController.m
//  VideoPlayer3
//
//  Created by 焦英博 on 16/9/21.
//  Copyright © 2016年 焦英博. All rights reserved.
//

#import "FullScreenController.h"
#import "PlayerView.h"

@interface FullScreenController ()

@end

@implementation FullScreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

// 不自动旋转
- (BOOL)shouldAutorotate {
    return NO;
}
// 横屏显示
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
