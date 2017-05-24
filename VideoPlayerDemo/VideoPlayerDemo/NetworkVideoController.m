//
//  NetworkVideoController.m
//  VideoPlayerDemo
//
//  Created by 焦英博 on 2017/5/23.
//  Copyright © 2017年 焦英博. All rights reserved.
//

#import "NetworkVideoController.h"
#import "PlayerView.h"

@interface NetworkVideoController ()

@property (nonatomic, strong) PlayerView *playerView;

@end

@implementation NetworkVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络视频";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initPlayer];
}

- (void)initPlayer {
    self.playerView = [PlayerView viewWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, 200)];
    self.playerView.urlString = @"http://svideo.spriteapp.com/video/2016/1114/75a39f62-aa75-11e6-8196-d4ae5296039d_wpd.mp4";
    [self.view addSubview:self.playerView];
}

@end
