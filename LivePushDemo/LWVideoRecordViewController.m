//
//  LWVideoRecordViewController.m
//  LivePushDemo
//
//  Created by AloesLu on 2016/9/23.
//  Copyright © 2016年 AloesLu. All rights reserved.
//

#import "LWVideoRecordViewController.h"

@interface LWVideoRecordViewController ()
@property (nonatomic,strong)GPUImageVideoCamera *camera;
@end

@implementation LWVideoRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //  1. 创建视频摄像头
    self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720
                                                      cameraPosition:AVCaptureDevicePositionBack];
    //  2. 设置摄像头帧率
    self.camera.frameRate = 25;
    //  3. 设置摄像头输出视频的方向
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //  4.0 创建用于展示视频的GPUImageView
    GPUImageView *imageView = [[GPUImageView alloc] init];
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    //  4.1 添加GPUImageView为摄像头的的输出目标
    [self.camera addTarget:imageView];
    //  5. 创建原始数据输出对象
    
    GDLRawDataOutput *output = [[GDLRawDataOutput alloc] initWithVideoCamera:self.camera withImageSize:CGSizeMake(720, 1280)];
    
    //  6. 添加数据输出对象为摄像头输出目标
    [self.camera addTarget:output];
    
    //  7.开始捕获视频
    [self.camera startCameraCapture];
    
    //  8.开始上传视频
    [output startUploadStreamWithURL:@"rtmp://192.168.2.100:1935/rtmplive" andStreamKey:@"room1"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.camera startCameraCapture];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.camera stopCameraCapture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
