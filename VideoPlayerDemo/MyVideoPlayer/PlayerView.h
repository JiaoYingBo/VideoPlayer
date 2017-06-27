//
//  PlayerView.h
//  VideoPlayer3
//
//  Created by 焦英博 on 16/9/17.
//  Copyright © 2016年 焦英博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, MovieViewState) {
    MovieViewStateSmall,
    MovieViewStateAnimating,
    MovieViewStateFullscreen,
};

@class PlayerView;
@protocol PlayerViewDelegate <NSObject>

@optional
- (void)playerViewDidClickFullScreenButton:(PlayerView *)playerView;

@end

@interface PlayerView : UIView

@property (nonatomic, weak) id<PlayerViewDelegate>delegate;

@property (nonatomic, assign, readonly) BOOL playEnded; //是否播放完毕
@property (nonatomic, assign, readonly) BOOL fullScreen; //是否是全屏

/** 初始化方法 */
+ (instancetype)viewWithFrame:(CGRect)frame;
// 网络视频
- (void)playWithRemoteURL:(NSString *)url;
// 本地视频
- (void)playWithLocalURL:(NSString *)url;

@end


@interface ToolView : UIView

@end
