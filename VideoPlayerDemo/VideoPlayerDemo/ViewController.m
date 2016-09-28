//
//  ViewController.m
//  VideoPlayerDemo
//
//  Created by 焦英博 on 16/9/22.
//  Copyright © 2016年 焦英博. All rights reserved.
//

#import "ViewController.h"
#import "FullScreenController.h"
#import "PlayerView.h"

@interface ViewController ()<PlayerViewDelegate>

@property (nonatomic, strong) PlayerView *playerView;
@property (nonatomic, strong) FullScreenController *fullVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.playerView];
}

#pragma mark - 懒加载
- (PlayerView *)playerView
{
    if (!_playerView) {
        /** 使用下面两种初始化方法会抛出异常，必须使用viewWithFrame:方法来初始化 */
        //_playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 200)];
        //_playerView = [[PlayerView alloc] init];
        _playerView = [PlayerView viewWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 200)];
        _playerView.delegate = self;
        _playerView.urlString = @"http://svideo.spriteapp.com/video/2016/0915/8224a236-7ac8-11e6-ba32-90b11c479401cut_wpd.mp4";
    }
    return _playerView;
}

- (FullScreenController *)fullVC
{
    if (!_fullVC) {
        _fullVC = [[FullScreenController alloc] init];
    }
    return _fullVC;
}

#pragma mark - 切换视频
// 播放视频1
- (IBAction)video1:(id)sender {
    _playerView.urlString = @"http://svideo.spriteapp.com/video/2016/0915/8224a236-7ac8-11e6-ba32-90b11c479401cut_wpd.mp4";
}

// 播放视频2
- (IBAction)video2:(id)sender {
    _playerView.urlString = @"http://svideo.spriteapp.com/video/2016/0921/68ad32f4-7fb5-11e6-baa3-90b11c479401cut_wpd.mp4";
}

#pragma mark - PlayerView delegate
- (void)didClickFullScreenButtonWithPlayerView:(PlayerView *)playerView
{
    if (_playerView.fullScreen == NO) {
        self.fullVC.fullScreenVC = self;
        [self presentViewController:self.fullVC animated:NO completion:^{
            _playerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            [self.fullVC.view addSubview:_playerView];
        }];
    } else {
        [self dismissViewControllerAnimated:NO completion:^{
            CGFloat width = MIN(self.view.bounds.size.height, self.view.bounds.size.width);
            _playerView.frame = CGRectMake(0, 50, width, 200);
            [self.view addSubview:_playerView];
        }];
    }
}

#pragma mark - 屏幕旋转
// 不自动旋转
- (BOOL)shouldAutorotate {
    return NO;
}
// 竖屏显示
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
@end
