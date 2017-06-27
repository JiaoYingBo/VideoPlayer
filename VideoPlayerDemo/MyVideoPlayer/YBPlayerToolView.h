//
//  YBPlayerToolView.h
//  VideoPlayerDemo
//
//  Created by 焦英博 on 2017/6/27.
//  Copyright © 2017年 焦英博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YBPlayerToolView : UIView

@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *fullButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

+ (instancetype)instanceView;

@end
