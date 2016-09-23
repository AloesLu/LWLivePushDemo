//
//  LWVideoPlayViewController.h
//  LivePushDemo
//
//  Created by AloesLu on 2016/9/23.
//  Copyright © 2016年 AloesLu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import "Player.h"

@interface LWVideoPlayViewController : UIViewController<VLCMediaPlayerDelegate>
@property (nonatomic, strong) NSString *playName;
@property (nonatomic, strong) NSString *playPath;
@property (nonatomic, strong) NSURL *playURL;

@property (nonatomic, strong) Player *player;
@end
