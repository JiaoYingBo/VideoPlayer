//
//  LocalVideoController.m
//  VideoPlayerDemo
//
//  Created by 焦英博 on 2017/5/23.
//  Copyright © 2017年 焦英博. All rights reserved.
//

#import "LocalVideoController.h"
#import "PlayerView.h"

@interface LocalVideoController ()

@property (nonatomic, strong) PlayerView *playerView;

@end

@implementation LocalVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"本地视频";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initPlayer];
}

- (void)initPlayer {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"localvideo.mp4" ofType:nil];
    self.playerView = [PlayerView viewWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, 200)];
    self.playerView.pathString = path;
    [self.view addSubview:self.playerView];
}

@end
