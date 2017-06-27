// 关于状态栏旋转，参考：http://blog.csdn.net/yyjjyysleep/article/details/68926803
//

#import "ViewController.h"
#import "LocalVideoController.h"
#import "NetworkVideoController.h"
#import "FullScreenController.h"
#import "PlayerView.h"

@interface ViewController ()<PlayerViewDelegate>

@property (nonatomic, strong) PlayerView *playerView;
@property (nonatomic, strong) FullScreenController *fullVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"AVPlayer";
//    [self.view addSubview:self.playerView];
}

#pragma mark - 懒加载
- (PlayerView *)playerView
{
    if (!_playerView) {
        /** 使用下面两种初始化方法会抛出异常，必须使用viewWithFrame:方法来初始化 */
        //_playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 200)];
        //_playerView = [[PlayerView alloc] init];
        _playerView = [PlayerView viewWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, 200)];
        _playerView.delegate = self;
//        _playerView.urlString = @"http://svideo.spriteapp.com/video/2016/1114/75a39f62-aa75-11e6-8196-d4ae5296039d_wpd.mp4";
        
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
/** 播放视频1 */
- (IBAction)video1:(id)sender {
//    self.playerView.urlString = @"http://svideo.spriteapp.com/video/2016/1114/75a39f62-aa75-11e6-8196-d4ae5296039d_wpd.mp4";
    
    NetworkVideoController *network = [[NetworkVideoController alloc] init];
    [self.navigationController pushViewController:network animated:YES];
}

/** 播放视频2 */
- (IBAction)video2:(id)sender {
//    self.playerView.urlString = @"http://svideo.spriteapp.com/video/2016/1114/c7257f48-aa68-11e6-990d-d4ae5296039d_wpd.mp4";
    
    LocalVideoController *local = [[LocalVideoController alloc] init];
    [self.navigationController pushViewController:local animated:YES];
}

#pragma mark - PlayerView delegate
/** 代理回调 */
- (void)playerViewDidClickFullScreenButton:(PlayerView *)playerView
{
    if (self.playerView.fullScreen == NO) {
        self.fullVC.fullScreenVC = self;
        [self presentViewController:self.fullVC animated:NO completion:^{
            self.playerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            [self.fullVC.view addSubview:self.playerView];
        }];
    } else {
        [self dismissViewControllerAnimated:NO completion:^{
            CGFloat width = MIN(self.view.bounds.size.height, self.view.bounds.size.width);
            self.playerView.frame = CGRectMake(0, 70, width, 200);
            [self.view addSubview:self.playerView];
        }];
    }
}

//#pragma mark - 屏幕旋转
///** 不自动旋转 */
//- (BOOL)shouldAutorotate {
//    return NO;
//}
///** 竖屏显示 */
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationPortrait;
//}
@end
