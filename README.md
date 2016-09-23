# VideoPlayer
###视频播放器
此视频播放器是基于AVPlayer封装的，支持播放、暂停、拖动快进快退、缓冲进度、全屏播放。


###使用方法
播放器初始化：

    self.playerView = [PlayerView viewWithFrame:CGRectMake(0, 0, 320, 200)];
    self.playerView.delegate = self;
    self.playerView.urlString = @"http://xxxvideo.mp4";
    [self.view addSubview:self.playerView]; 
    
要切换视频源，只需要修改`urlString`：

    - (IBAction)video2:(id)sender {
        self.playerView.urlString = @"http://xxxvideo.mp4";
    }


####播放界面如下：
![](https://github.com/JiaoYingBo/VideoPlayer/raw/master/VideoPlayerDemo/HP.png)

![](https://github.com/JiaoYingBo/VideoPlayer/raw/master/VideoPlayerDemo/SP.png)

###注意
如果用Xcode7运行报错：`The document "(null)" requires Xcode 8.0 or later.` 右键报错的`StoryBoard`或`Xib`文件__-->Open As-->Source Code__，删除 `<capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/> `这一行即可。
