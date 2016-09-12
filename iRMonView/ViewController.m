//
//  SlideMenuAndMulitViewViewController.m
//  SlideMenuAndMulitView
//
//  Created by JWMAC on 13. 7. 26..
//  Copyright (c) 2013년 Kim Ji Wook. All rights reserved.
//

#import "ViewController.h"
#import "iMonLog.h"
#import "ResourceMonitor.h"
#import "MemoryAllocator.h"
#import "ThirdView.h"
#import "PCPieChart.h"


#define SizeX 0
#define SizeY 0
#define SizeWidth 320
#define SizeHeight 580

#define SizeInterval 320


NSString *const kCurrentLogSettingsKey = @"current_log_file";
static NSString *const kLogIntervalDefaultsKey = @"log_interval";
static NSString *currentLog = @"SetLog";
static double warningMemory = 0;



@interface ViewController ()

@end

@implementation ViewController {
    NSTimer *_refreshTimer;
    NSTimer *_memoryWarningCheck;
    iMonLog *_imonLog;
    CFTimeInterval _lastLogEntryTime;
    NSTimeInterval *_backgroundRunningTimeInterval;
}

@synthesize sideMenu;
@synthesize mainViews;
@synthesize sideMenuCheck;
@synthesize mainScrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self audioInit];
    
	// Do any additional setup after loading the view, typically from a nib.
    sideMenuCheck = true;
    [sideMenu setDataSource:self];
    [sideMenu setDelegate:self];

    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(SizeX, SizeY+44, SizeWidth, SizeHeight-44)];
    mainScrollView = [self scrollViewSetting:mainScrollView setX:SizeWidth*3 setY:SizeHeight-44];
    
    [mainScrollView setDelegate:self];
    
    [mainViews addSubview:mainScrollView];
    [mainScrollView addSubview:[[ResourceMonitor alloc] initWithFrame:CGRectMake(SizeX, SizeY, SizeWidth, SizeHeight)]];
    [mainScrollView addSubview:[[MemoryAllocator alloc] initWithFrame:CGRectMake(SizeX+SizeWidth, SizeY, SizeWidth, SizeHeight)]];
    [mainScrollView addSubview:[[ThirdView alloc] initWithFrame:CGRectMake(SizeX+SizeWidth+SizeWidth, SizeY, SizeWidth, SizeHeight)]];
//    [mainScrollView addSubview:[[FourthView alloc] initWithFrame:CGRectMake(SizeX+SizeWidth+SizeWidth+SizeWidth, SizeY, SizeWidth, SizeHeight)]];
    
    }

- (UIScrollView *) scrollViewSetting : (UIScrollView *)Scrollview setX :(int)setX setY :(int)setY
{
    Scrollview.clipsToBounds = YES; //스크롤뷰 영역안으로 클립되도록 설정
    Scrollview.scrollEnabled = YES; //스크롤뷰 가능하도록 설정
    Scrollview.directionalLockEnabled = YES; //한쪽 방향으로만
    Scrollview.pagingEnabled = YES; // 스크롤뷰의 크기만큼씩 페이징 되도록 설정
    Scrollview.bounces = YES;
    Scrollview.showsHorizontalScrollIndicator = NO;
    Scrollview.showsVerticalScrollIndicator = NO;      // 스크롤 막대 가로, 세로 안보이기
    
    [Scrollview setContentSize:CGSizeMake(setX,setY)]; // 스크롤뷰 싸이즈 조정
    
    return Scrollview;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [mainViews setBackgroundColor:PCColorRed];
    
}

// 메뉴 버튼 클릭시 액션
- (IBAction) sideMenuBtn
{
    CGRect viewFram = mainViews.frame;
    [sideMenu reloadData];
    if (sideMenuCheck == true)
    {
        viewFram.origin.x += 260;
        sideMenuCheck = false;
    }else{
        viewFram.origin.x -= 260;
        sideMenuCheck = true;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    
    [mainViews setFrame:viewFram];
    [UIView commitAnimations];
}


#pragma mark - TableView메소드

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{   // 그룹의 갯수를 정한다.
    // 전화번호가 없을 시에는
    return 1;
}

/*
 -(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
 {   // 그룹간 간격 띄우기 첫번째일 때 너무 붙으면 안돼서 많이 띄운다.
 return 1;
 }
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   // 세션 나누기
    switch (section) {
        case 0:
            return 3;
            break;
    }
    return 0;
}

// 커스텀 타이틀
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *testView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 10)];
    testView.backgroundColor = [UIColor blackColor];
    testView.textColor = [UIColor whiteColor];
    switch (section) {
        case 0:
            testView.text =@"  Menu";
            break;
    }
    
    return testView;
}

/*
// 이건 기본 제공
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"";
            break;
        case 1:
            return @"";
            break;
        case 2:
            return @"";
            break;
        default:
            return @"";
            break;
    }
}
 */

#pragma mark - tableView cellForRowAtIndexPath(각각 셀 만드는 메소드)
// 기능 : 정보에 따라 안에 값들을 만들어준다.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [sideMenu dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSArray *viewsToRemove1 = [cell subviews];
    for (UIView *v in viewsToRemove1)
    {
        if (v.tag == 111111) {
            [v removeFromSuperview];
        }
        
    }
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 200, 20)];
    text.backgroundColor = [UIColor clearColor];
    text.textColor =[UIColor blackColor];
    text.font = [UIFont systemFontOfSize:14];
    text.tag = 111111;
    
//    NSLog(@"세션값 알아보기[%ld]",(long)indexPath.section);
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            text.text = @"Resoruce Monitor";
        }else if(indexPath.row == 1)
        {
            text.text = @"Memory Allocator";
        }else if(indexPath.row == 2)
        {
            text.text = @"Process List";
        }
    }
  
    [cell addSubview:text];
    return cell;
}


#pragma mark - tableView didSelectRowAtIndexPath(각각 셀 만드는 메소드)
// 기능 : 각각 셀을 선택하였을 때
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld열 %ld행 번째",(long)indexPath.section,(long)[indexPath row]);
    
    if (indexPath.section == 0) {
        CGPoint point;
        point.y = SizeY;
        if (indexPath.row == 0) {
            point.x = SizeX;
        }else if(indexPath.row == 1){
            point.x = SizeX+SizeWidth;
        }else if(indexPath.row == 2){
            point.x = SizeX+SizeWidth+SizeWidth;
        }else if(indexPath.row == 3){
            point.x = SizeX+SizeWidth+SizeWidth+SizeWidth;
        }
        [mainScrollView setContentOffset:point animated:NO];
        [self sideMenuBtn];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];  // 해제
}




// Background에서 동작될 AudioSession 설정
-(void) audioInit {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    UInt32 doSetProperty = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
    [[AVAudioSession sharedInstance] setActive:YES error:nil]; //다른 Audio와 중복 재생 설정
    
    NSURL *audioFileLocationURL = [[NSBundle mainBundle]URLForResource:@"Silence" withExtension:@"wav"];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:nil];
    _audioPlayer.numberOfLoops = -1; // Audio 무한루프
    [_audioPlayer setVolume:0.0];
    [_audioPlayer play];
    
}

// log 파일명 설정을 위한 alert창 호출
- (void)startNewLog {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log File Name" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

// log alert창 처리
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *logFileName = [alertView textFieldAtIndex:0].text;
    [[NSUserDefaults standardUserDefaults] setObject:logFileName forKey:kCurrentLogSettingsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _imonLog = [[iMonLog alloc] initWithLogFileName:logFileName];
    [self setLogName];    
}


// view가 노출되면 NSTimer가 동작하면서 setResoureces 메소드를 1초 interval로 호출
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setResources) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_refreshTimer invalidate];
}




// Start 버튼 이벤트
- (IBAction)startBtn:(id)sender {
    
    
    if (![currentLog isEqualToString:@"SetLog"]) {
        
        isRunning = YES;
        [self performSelectorInBackground:@selector(runningInBackground) withObject:nil]; //BG 실행
        
        // 버튼 상태에 따라 이미지 변경 (IB에서 default 이미지와 / selected 이미지를 각각 설정해둔 상태)
        if ([startBtn state] == 1) {
            [startBtn setSelected:true];
        } else {
            isRunning = NO;
            [startBtn setSelected:false];
        }
    }
    
}

// log 영역 선택시 새로운 로그 생성
- (IBAction)logBtn:(id)sender {
    [self startNewLog];
}


// 변경된 log 파일 이름을 화면에 출력
-(void) setLogName {
    currentLog = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentLogSettingsKey];
    [logBtn setTitle:currentLog forState:0];
    if ([currentLog isEqualToString:@""]) {
        [logBtn setTitle:@"SetLog" forState:0];
    }
}

// bg 동작 설정
- (void) runningInBackground
{
    while (isRunning) {
        [NSThread sleepForTimeInterval:1];
        [_imonLog appendLogEntry]; //로그 기록
    }
}

@end
