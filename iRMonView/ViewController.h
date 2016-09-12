//
//  SlideMenuAndMulitViewViewController.h
//  SlideMenuAndMulitView
//
//  Created by JWMAC on 13. 7. 26..
//  Copyright (c) 2013년 Kim Ji Wook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

{
    IBOutlet UIButton *startBtn;
    IBOutlet UIButton *logBtn;
    
    BOOL *isRunning;
}


@property(nonatomic, assign) BOOL sideMenuCheck;
@property(nonatomic, strong) IBOutlet UITableView *sideMenu;

@property(nonatomic, strong) IBOutlet UIView *mainViews;
@property(nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

- (IBAction) sideMenuBtn;

@end
