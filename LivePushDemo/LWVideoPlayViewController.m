//
//  LWVideoPlayViewController.m
//  LivePushDemo
//
//  Created by AloesLu on 2016/9/23.
//  Copyright © 2016年 AloesLu. All rights reserved.
//

#import "LWVideoPlayViewController.h"
#import "AppDelegate.h"

@interface LWVideoPlayViewController () {
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    CGFloat playerProgress; // 播放进度
    
    UIActivityIndicatorView *_indicatior;
    
    // 手势初始X和Y坐标
    CGFloat beginTouchX;
    CGFloat beginTouchY;
    // 手势相对于初始X和Y坐标的偏移量
    CGFloat offsetX;
    CGFloat offsetY;
    
    //是否本地，是本地就把进度条和时间标签隐藏
    BOOL isLocal;
    
    //VLC承载视图
    UIView *_loadView;
}

@property (nonatomic, strong) UIProgressView *progressBar; //进度条
@property (nonatomic, strong) UILabel *remainingTimeLabel; //剩余时间条
@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation LWVideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //导航栏
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"＜＜＜" style:UIBarButtonItemStylePlain target:self action:@selector(backToTop)];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.title = _playName;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    
    //承载视图初始化
    _loadView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, _screenWidth, _screenWidth * 2 / 3)];
    _loadView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_loadView];
    
    //播放键
    UIImage *playBtnImg = [UIImage imageNamed:@"pause"];
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, _loadView.frame.size.height - playBtnImg.size.height - 15, playBtnImg.size.width, playBtnImg.size.height)];
    [_playBtn setImage:playBtnImg forState:UIControlStateNormal];
    [_loadView addSubview:_playBtn];
    [_playBtn setHidden:YES];
    [_playBtn addTarget:self action:@selector(playControl) forControlEvents:UIControlEventTouchUpInside];
    
    //剩余时间label
    NSString *defaultText = @"--:--:--";
    CGSize textSize = [defaultText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    _remainingTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_loadView.frame.size.width - textSize.width - 30, _playBtn.center.y - textSize.height / 2, textSize.width, textSize.height)];
    _remainingTimeLabel.font = [UIFont systemFontOfSize:14];
    [_remainingTimeLabel setText:defaultText];
    [_remainingTimeLabel setTextColor:[UIColor whiteColor]];
    [_loadView addSubview:_remainingTimeLabel];
    [_remainingTimeLabel setHidden:YES];
    
    //进度条
    _progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(30 + _playBtn.frame.size.width, _playBtn.center.y - 2, _screenWidth - 60 - _playBtn.frame.size.width - _remainingTimeLabel.frame.size.width, 4)];
    [_progressBar setProgress:0];
    [_loadView addSubview:_progressBar];
    [_progressBar setHidden:YES];
    
    //指示器
    _indicatior = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicatior.center = _loadView.center;
    [self.view addSubview:_indicatior];
    [_indicatior startAnimating];
    [_indicatior setHidesWhenStopped:YES];
    
    //点击手势
    UITapGestureRecognizer *tapScrn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showControlPanel)];
    tapScrn.numberOfTapsRequired = 1;
    tapScrn.numberOfTouchesRequired = 1;
    [_loadView addGestureRecognizer:tapScrn];
    
    //视频播放
    if (_playPath) {
        _player = [[Player alloc] initWithView:_loadView andMediaPath:_playPath];
        [_player playMedia];
        isLocal = YES;
    }
    if (_playURL) {
        _player = [[Player alloc] initWithView:_loadView andMediaURL:_playURL];
        [_player playMedia];
        isLocal = NO;
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((AppDelegate *)([[UIApplication sharedApplication] delegate])).isAllowRotation = YES;
    [_player.player addObserver:self forKeyPath:@"remainingTime" options:0 context:nil];
    [_player.player addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
    [_player.player addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    ((AppDelegate *)([[UIApplication sharedApplication] delegate])).isAllowRotation = NO;
    [_player.player removeObserver:self forKeyPath:@"remainingTime"];
    [_player.player removeObserver:self forKeyPath:@"isPlaying"];
    [_player.player removeObserver:self forKeyPath:@"state"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (size.width > size.height) {
        [UIView animateWithDuration:0.2 animations:^{
            _loadView.frame = CGRectMake(0, 0, size.width, size.height);
            _indicatior.center = _loadView.center;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            _loadView.frame = CGRectMake(0, 0, _screenWidth, _screenWidth * 2 / 3);
            _indicatior.center = _loadView.center;
        }];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    _progressBar.progress = [_player.player position];
    _remainingTimeLabel.text = [[_player.player remainingTime] stringValue];
    if ([keyPath isEqualToString:@"isPlaying"]) {
        if ([_player.player isPlaying]) {
            [_indicatior stopAnimating];
        }
    }
    if ([keyPath isEqualToString:@"state"]) {
        NSLog(@"%@", VLCMediaPlayerStateToString(_player.player.state));
        if ([VLCMediaPlayerStateToString(_player.player.state) isEqualToString:@"VLCMediaPlayerStateError"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误！" message:@"打开失败，频道地址失效或网络错误！" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alertController animated:YES completion:NULL];
        }
    }
}

#pragma mark - touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *oneTouch = [touches anyObject];
    
    //手指触摸屏幕开始的坐标
    beginTouchX = [oneTouch locationInView:oneTouch.view].x;
    beginTouchY = [oneTouch locationInView:oneTouch.view].y;
    
}

//滑动快进/快退
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *oneTouch = [touches anyObject];
    
    // 手势相对于初始坐标的偏移量
    offsetX = [oneTouch locationInView:oneTouch.view].x - beginTouchX;
    
    if (offsetX != 0) {
        // 中屏幕中间左右滑动改变进度
        if ([_player.player isPlaying] && isLocal) { // 如果视频可以播放才可以调整播放进度
            // 要改变的进度值
            CGFloat deltaProgress = offsetX / _screenWidth;
            int progressInSec = (int)(deltaProgress * 300);
            if (progressInSec > 0 && ([[_player.player remainingTime] intValue] + progressInSec * 1000) < 0) {
                [_player.player jumpForward:progressInSec];
            }
            if (progressInSec < 0 && ([[_player.player time] intValue] + progressInSec * 1000) > 0) {
                [_player.player jumpBackward:-progressInSec];
            }
        }
    }
}

//显示/关闭 控制面板
- (void)showControlPanel {
    
    [_loadView bringSubviewToFront:_playBtn];
    [_loadView bringSubviewToFront:_remainingTimeLabel];
    [_loadView bringSubviewToFront:_progressBar];
    
    if (_playBtn.isHidden) {
        _playBtn.hidden = NO;
        self.navigationController.navigationBar.hidden = NO;
        if (isLocal) {
            _remainingTimeLabel.hidden = NO;
            _progressBar.hidden = NO;
        }
    } else {
        _playBtn.hidden = YES;
        _remainingTimeLabel.hidden = YES;
        _progressBar.hidden = YES;
        self.navigationController.navigationBar.hidden = YES;
    }
}

- (void)playControl {
    if ([_player.player isPlaying]) {
        [_player.player pause];
        [_playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    } else {
        [_player.player play];
        [_playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

- (void)backToTop {
    [_player stopPlaying];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
