//
//  PlayerView.m
//  VideoPlayer3
//
//  Created by 焦英博 on 16/9/17.
//  Copyright © 2016年 焦英博. All rights reserved.
//

#import "PlayerView.h"
#import "FullScreenController.h"

@interface PlayerView ()

@end

@implementation PlayerView

#pragma mark - 初始化方法
+ (instancetype)viewWithFrame:(CGRect)frame
{
    PlayerView *view = [PlayerView instanceView];
    view.frame = frame;
    return view;
}

+ (instancetype)instanceView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"PlayerView" owner:nil options:nil] firstObject];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // 初始化AVPlayer
    self.player = [[AVPlayer alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf setTimeLabel];
        NSTimeInterval totalTime = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        // time.value/time.timescale是当前时间
        weakSelf.slider.value = time.value/time.timescale/totalTime;
    }];
    // 初始化AVPlayerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.imageView.layer addSublayer:self.playerLayer];
    
    [self.slider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    [self addNotification];
    _fullScreen = NO;
}

#pragma mark - Notification
- (void)addNotification
{
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)playbackFinished:(NSNotification *)noti{
    _playEnded = YES;
    if (self.playButton.selected) {
        self.playButton.selected = NO;
    }
}

#pragma mark - 点击/滑动动作
- (IBAction)playButtonClick:(UIButton *)sender {
    if (self.player.rate == 0) {
        sender.selected = YES;
        [self play];
    } else if (self.player.rate == 1) {
        sender.selected = NO;
        [self pause];
    }
}

- (IBAction)sliderTouchBegin:(UISlider *)sender {
    [self pause];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * self.slider.value;
    NSInteger currentMin = currentTime / 60;
    NSInteger currentSec = (NSInteger)currentTime % 60;
    self.currentTime.text = [NSString stringWithFormat:@"%02td:%02td",currentMin,currentSec];
}

- (IBAction)sliderTouchEnd:(UISlider *)sender {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * self.slider.value;
    [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self play];
}

- (IBAction)fullScreenBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didClickFullScreenButtonWithPlayerView:)]) {
        [self.delegate didClickFullScreenButtonWithPlayerView:self];
        sender.selected = !sender.selected;
    }
    _fullScreen = !_fullScreen;
}

#pragma mark - Time Label
- (void)setTimeLabel
{
    NSTimeInterval totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentTime);
    
    NSInteger totalMin = totalTime / 60;
    NSInteger totalSec = (NSInteger)totalTime % 60;
    self.totalTime.text = [NSString stringWithFormat:@"%02td:%02td",totalMin,totalSec];
    
    NSInteger currentMin = currentTime / 60;
    NSInteger currentSec = (NSInteger)currentTime % 60;
    self.currentTime.text = [NSString stringWithFormat:@"%02td:%02td",currentMin,currentSec];
}

#pragma mark - 播放状态
- (void)play
{
    // 如果播放完毕，则重新从头播放
    if (self.playEnded == YES) {
        [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        _playEnded = NO;
    }
    [self.player play];
}

- (void)pause
{
    [self.player pause];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            [self.activityView stopAnimating];
            [self setTimeLabel];
            // 开始自动播放
            self.playButton.enabled = YES;
            self.slider.enabled = YES;
            [self playButtonClick:self.playButton];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *array = self.player.currentItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
        NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        float totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
        NSLog(@"已缓冲：%.2f%%", totalBuffer/totalTime*100);
    }
}

#pragma mark - set方法
- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    // 先清空playerItem
    [self playerItemRemoveObserver];
    self.playerItem = nil;
    // 再创建
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlString]];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    // 监听属性
    [self playerItemAddObserver];
}

#pragma mark - KVO
- (void)playerItemAddObserver
{
    // 监听播放状态
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听缓冲进度
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)playerItemRemoveObserver
{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

#pragma mark - ToolView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.toolView.hidden == YES) {
        [self showToolView];
    } else {
        [self hideToolView];
    }
}

- (void)hideToolView
{
    self.toolView.hidden = YES;
}

- (void)showToolView
{
    self.toolView.hidden = NO;
}

- (void)dealloc {
    [self playerItemRemoveObserver];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self.player removeTimeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation ToolView
// 创建自定义view并重写这个方法，让ToolView可以响应点击事件，而不被传递到PlayerView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Clicked ToolView");
}

@end
