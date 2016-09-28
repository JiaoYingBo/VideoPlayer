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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderLeadingCtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderTrailingCtn;
/** 记录暂停状态 */
@property (nonatomic ,assign) BOOL paused;
@end

@implementation PlayerView

#pragma mark - 初始化方法
+ (instancetype)viewWithFrame:(CGRect)frame
{
    PlayerView *view = [PlayerView pv_instanceView];
    view.frame = frame;
    return view;
}

#pragma mark - 系统方法
- (instancetype)initWithFrame:(CGRect)frame
{
    // 写这行是为了消除Xcode8上的警告，强迫症！
    self = [super initWithFrame:frame];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"必须使用 viewWithFrame: 方法初始化" userInfo:nil];
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"必须使用 viewWithFrame: 方法初始化" userInfo:nil];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_imageView.layer addSublayer:self.playerLayer];
    [self pv_resetUI];
    _fullScreen = NO;
    _paused = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pv_applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
}

- (void)dealloc {
    [self pv_playerItemRemoveObserver];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self.player removeTimeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            [_activityView stopAnimating];
            [self pv_setTimeLabel];
            // 开始自动播放
            _playButton.enabled = YES;
            _slider.enabled = YES;
            [self pv_playButtonClick:_playButton];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *array = self.player.currentItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);//本次缓冲起始时间
        NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);//缓冲时间
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        float totalTime = CMTimeGetSeconds(self.player.currentItem.duration);//视频总长度
        float progress = totalBuffer/totalTime;//缓冲进度
        [_progressView setProgress:progress];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_toolView.hidden == YES) {
        [self pv_showToolView];
    } else {
        [self pv_hideToolView];
    }
}

#pragma mark - setter方法
- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    [self pv_resetPlayer];
    if (self.player.currentItem != nil) {
        [self pv_playerItemRemoveNotification];
        [self pv_playerItemRemoveObserver];
    }
    AVPlayerItem *playerItem = [self pv_getPlayerItemWithURLString:urlString];
    [self pv_addObserverToPlayerItem:playerItem];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        [self pv_playerItemAddNotification];
    });
}

#pragma mark - 懒加载
- (AVPlayer *)player
{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        __weak typeof(self) weakSelf = self;
        // 播放1s回调一次
        [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
            [weakSelf pv_setTimeLabel];
            NSTimeInterval totalTime = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
            weakSelf.slider.value = time.value/time.timescale/totalTime;//time.value/time.timescale是当前时间
        }];
    }
    return _player;
}

- (AVPlayerLayer *)playerLayer
{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    }
    return _playerLayer;
}

#pragma mark -
#pragma mark - 私有方法
+ (instancetype)pv_instanceView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
}

- (void)pv_resetUI
{
    [_slider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    [_slider setMaximumTrackImage:[self pv_imageWithColor:[UIColor clearColor] size:CGSizeMake(300, 2)] forState:UIControlStateNormal];
    [_progressView setProgressTintColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:235/255.0 alpha:.8]];
    [_progressView setTrackTintColor:[UIColor whiteColor]];
}

- (AVPlayerItem *)pv_getPlayerItemWithURLString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    return item;
}

#pragma mark - 观察者
- (void)pv_playerItemAddNotification
{
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pv_playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)pv_addObserverToPlayerItem:(AVPlayerItem *)playerItem
{
    // 监听播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听缓冲进度
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)pv_playerItemRemoveNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)pv_playerItemRemoveObserver
{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(void)pv_playbackFinished:(NSNotification *)noti{
    _playEnded = YES;
    if (_playButton.selected) {
        _playButton.selected = NO;
    }
}

- (void)pv_applicationWillResignActive:(NSNotification *)noti
{
    if (self.player.rate == 1) {
        [self pv_playButtonClick:_playButton];
    }
}

#pragma mark - 点击/滑动动作
- (IBAction)pv_playButtonClick:(UIButton *)sender {
    if (self.player.rate == 0) {
        sender.selected = YES;
        _paused = NO;
        [self pv_play];
    } else if (self.player.rate == 1) {
        sender.selected = NO;
        _paused = YES;
        [self pv_pause];
    }
}

- (IBAction)pv_sliderTouchBegin:(UISlider *)sender {
    [self pv_pause];
}

- (IBAction)pv_sliderValueChanged:(UISlider *)sender {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * _slider.value;
    NSInteger currentMin = currentTime / 60;
    NSInteger currentSec = (NSInteger)currentTime % 60;
    _currentTime.text = [NSString stringWithFormat:@"%02td:%02td",currentMin,currentSec];
}

- (IBAction)pv_sliderTouchEnd:(UISlider *)sender {
    NSTimeInterval slideTime = CMTimeGetSeconds(self.player.currentItem.duration) * _slider.value;
    if (slideTime == CMTimeGetSeconds(self.player.currentItem.duration)) {
        slideTime -= 0.5;
    }
    [self.player seekToTime:CMTimeMakeWithSeconds(slideTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    if (_paused == NO) {
        [self pv_play];
    }
}

- (IBAction)pv_fullScreenBtnClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(didClickFullScreenButtonWithPlayerView:)]) {
        [_delegate didClickFullScreenButtonWithPlayerView:self];
        sender.selected = !sender.selected;
    }
    _fullScreen = !_fullScreen;
}

#pragma mark - Time Label
- (void)pv_setTimeLabel
{
    NSTimeInterval totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentTime);
    // 切换视频源时totalTime/currentTime的值会出现nan导致时间错乱
    if (!(totalTime>=0)||!(currentTime>=0)) {
        totalTime = 0;
        currentTime = 0;
    }
    
    NSInteger totalMin = totalTime / 60;
    NSInteger totalSec = (NSInteger)totalTime % 60;
    _totalTime.text = [NSString stringWithFormat:@"%02td:%02td",totalMin,totalSec];
    
    NSInteger currentMin = currentTime / 60;
    NSInteger currentSec = (NSInteger)currentTime % 60;
    _currentTime.text = [NSString stringWithFormat:@"%02td:%02td",currentMin,currentSec];
}

#pragma mark - 播放状态
- (void)pv_play
{
    // 如果已播放完毕，则重新从头开始播放
    if (_playEnded == YES) {
        [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        _playEnded = NO;
    }
    [self.player play];
}

- (void)pv_pause
{
    [self.player pause];
}

- (void)pv_resetPlayer
{
    _playEnded = NO;
    _paused = NO;
    [self pv_pause];
    if (_playButton.selected) {
        _playButton.selected = NO;
    }
    [_activityView startAnimating];
}

#pragma mark - ToolView
- (void)pv_hideToolView
{
    _toolView.hidden = YES;
}

- (void)pv_showToolView
{
    _toolView.hidden = NO;
}

#pragma mark - 绘制图片
- (UIImage *)pv_imageWithColor:(UIColor *)color size:(CGSize)size
{
    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillRect(ctx, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

@end

@implementation ToolView
// 创建自定义view并重写这个方法，让ToolView可以响应点击事件，而不被传递到PlayerView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Clicked ToolView");
}

@end
