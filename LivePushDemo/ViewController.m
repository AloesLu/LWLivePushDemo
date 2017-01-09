//
//  ViewController.m
//  LivePushDemo
//
//  Created by AloesLu on 16/8/25.
//  Copyright © 2016年 AloesLu. All rights reserved.
//

#import "ViewController.h"
#import "LWVideoPlayViewController.h"
#import "LWVideoRecordViewController.h"

#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"简单直播Demo";
    
    //进入直播录制界面
    UIButton *buttonRecord=[[UIButton alloc]initWithFrame:CGRectMake((kScreen_Width-80)/2, 200, 80, 40)];
    buttonRecord.backgroundColor=[UIColor greenColor];
    [buttonRecord setTitle:@"视频录制" forState:UIControlStateNormal];
    [buttonRecord addTarget:self action:@selector(videoRecordAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonRecord];
    
    //进入直播播放界面
    UIButton *buttonPlay=[[UIButton alloc]initWithFrame:CGRectMake((kScreen_Width-80)/2, 280, 80, 40)];
    buttonPlay.backgroundColor=[UIColor greenColor];
    [buttonPlay setTitle:@"视频播放" forState:UIControlStateNormal];
    [buttonPlay addTarget:self action:@selector(videoPlayAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonPlay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)videoRecordAction:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (AVAuthorizationStatusDenied == authStatus ||
                AVAuthorizationStatusRestricted == authStatus) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在iPhone的“设置->隐私->相机”中打开梦虎的访问权限" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                [self presentViewController:alertController animated:YES completion:NULL];
            }else{
                LWVideoRecordViewController *vrVC=[[LWVideoRecordViewController alloc]init];
                [self.navigationController pushViewController:vrVC animated:YES];
            }
        }

    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"该设备不支持拍照" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:NULL];
    }
}
- (void)videoPlayAction:(id)sender {
    LWVideoPlayViewController *vpVC=[[LWVideoPlayViewController alloc]init];
    vpVC.playURL=[NSURL URLWithString:@"rtmp://192.168.2.100:1935/rtmplive/room1"];
    vpVC.playName=@"AloesLu";
    [self.navigationController pushViewController:vpVC animated:YES];
}

@end
