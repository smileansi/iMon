//
//  SecondView.m
//  SlideMenuAndMulitView
//
//  Created by JWMAC on 13. 7. 26..
//  Copyright (c) 2013년 Kim Ji Wook. All rights reserved.
//

#import "MemoryAllocator.h"
#import "iMonUtils.h"
#import "PCPieChart.h"

@implementation MemoryAllocator {
    NSTimer *refreshTimer;
    
    uint64_t physicalMemorySize;
    uint64_t userMemorySize;
    
    Byte *add1Mb[10000];
    Byte *add5Mb[10000];
    Byte *add10Mb[10000];
    Byte *add50Mb[10000];
    
    int allocCount1mb;
    int allocCount5mb;
    int allocCount10mb;
    int allocCount50mb;
    
    int allocatedSize;
    
    int memWariningSize;
    int beforeWaringSize;
    
    PCPieChart *pieChart;
    NSMutableArray *components;
    
    UILabel *allocatedSizeValue;
    UILabel *allocated1mbValue;
    UILabel *allocated5mbValue;
    UILabel *allocated10mbValue;
    UILabel *allocated50mbValue;


}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    // 1초 인터벌로 setResources 실행
//    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setResources) userInfo:nil repeats:YES];
   
    [self setResources];
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        // Label
        UILabel *Label_1MB = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
        [Label_1MB setFont:[UIFont boldSystemFontOfSize:14]];
        [Label_1MB setText:@"1MB"];
        [self addSubview:Label_1MB];
        
        UILabel *Label_5MB = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 30)];
        [Label_5MB setFont:[UIFont boldSystemFontOfSize:14]];
        [Label_5MB setText:@"5MB"];
        [self addSubview:Label_5MB];
        
        UILabel *Label_10MB = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 100, 30)];
        [Label_10MB setFont:[UIFont boldSystemFontOfSize:14]];
        [Label_10MB setText:@"10MB"];
        [self addSubview:Label_10MB];
        
        UILabel *Label_50MB = [[UILabel alloc] initWithFrame:CGRectMake(10, 160, 100, 30)];
        [Label_50MB setFont:[UIFont boldSystemFontOfSize:14]];
        [Label_50MB setText:@"50MB"];
        [self addSubview:Label_50MB];
        
        UILabel *Label_free = [[UILabel alloc] initWithFrame:CGRectMake(10, 210, 100, 30)];
        [Label_free setFont:[UIFont boldSystemFontOfSize:14]];
        [Label_free setText:@"dealloc"];
        [self addSubview:Label_free];
        
        allocated1mbValue = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2+40, 10, 100, 30)];
        [allocated1mbValue setFont:[UIFont boldSystemFontOfSize:14]];
        allocated1mbValue.textAlignment = NSTextAlignmentRight;
        allocated1mbValue.textColor = PCColorBlue;
        [allocated1mbValue setText:@"0"];
        [self addSubview:allocated1mbValue];
        
        allocated5mbValue = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2+40, 60, 100, 30)];
        [allocated5mbValue setFont:[UIFont boldSystemFontOfSize:14]];
        allocated5mbValue.textAlignment = NSTextAlignmentRight;
        allocated5mbValue.textColor = PCColorBlue;
        [allocated5mbValue setText:@"0"];
        [self addSubview:allocated5mbValue];
        
        allocated10mbValue = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2+40, 110, 100, 30)];
        [allocated10mbValue setFont:[UIFont boldSystemFontOfSize:14]];
        allocated10mbValue.textAlignment = NSTextAlignmentRight;
        allocated10mbValue.textColor = PCColorBlue;
        [allocated10mbValue setText:@"0"];
        [self addSubview:allocated10mbValue];
        
        allocated50mbValue = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2+40, 160, 100, 30)];
        [allocated50mbValue setFont:[UIFont boldSystemFontOfSize:14]];
        allocated50mbValue.textAlignment = NSTextAlignmentRight;
        allocated50mbValue.textColor = PCColorBlue;
        [allocated50mbValue setText:@"0"];
        [self addSubview:allocated50mbValue];
        
        
        allocatedSizeValue = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2+40, 210, 100, 30)];
        [allocatedSizeValue setFont:[UIFont boldSystemFontOfSize:14]];
        allocatedSizeValue.textAlignment = NSTextAlignmentRight;
        allocatedSizeValue.textColor = PCColorRed;
        [allocatedSizeValue setText:@"0"];
        [self addSubview:allocatedSizeValue];
        
        
        // 버튼 정의
        UIButton *add1MBbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [add1MBbtn setFrame:CGRectMake([self bounds].size.width/2-30, 15, 30, 30)];
        [add1MBbtn setImage:[UIImage imageNamed:@"Plus.png"] forState:UIControlStateNormal];
        [self addSubview:add1MBbtn];
        [add1MBbtn addTarget:self action:@selector(add1MBaction:) forControlEvents: UIControlEventTouchUpInside];
        
        UIButton *free1MBbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [free1MBbtn setFrame:CGRectMake([self bounds].size.width/2+10, 15, 30, 30)];
        [free1MBbtn setImage:[UIImage imageNamed:@"Minus.png"] forState:UIControlStateNormal];
        [self addSubview:free1MBbtn];
        [free1MBbtn addTarget:self action:@selector(free1MBaction:) forControlEvents: UIControlEventTouchUpInside];
        
        
        
        
        UIButton *add5MBbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [add5MBbtn setFrame:CGRectMake([self bounds].size.width/2-30, 65, 30, 30)];
        [add5MBbtn setImage:[UIImage imageNamed:@"Plus.png"] forState:UIControlStateNormal];
        [self addSubview:add5MBbtn];
        [add5MBbtn addTarget:self action:@selector(add5MBaction:) forControlEvents: UIControlEventTouchUpInside];
        
        UIButton *free5MBbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [free5MBbtn setFrame:CGRectMake([self bounds].size.width/2+10, 65, 30, 30)];
        [free5MBbtn setImage:[UIImage imageNamed:@"Minus.png"] forState:UIControlStateNormal];
        [self addSubview:free5MBbtn];
        [free5MBbtn addTarget:self action:@selector(free5MBaction:) forControlEvents: UIControlEventTouchUpInside];
        
        
        
        
        
        UIButton *add10MBbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [add10MBbtn setFrame:CGRectMake([self bounds].size.width/2-30, 115, 30, 30)];
        [add10MBbtn setImage:[UIImage imageNamed:@"Plus.png"] forState:UIControlStateNormal];
        [self addSubview:add10MBbtn];
        [add10MBbtn addTarget:self action:@selector(add10MBaction:) forControlEvents: UIControlEventTouchUpInside];
        
        UIButton *free10MBbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [free10MBbtn setFrame:CGRectMake([self bounds].size.width/2+10, 115, 30, 30)];
        [free10MBbtn setImage:[UIImage imageNamed:@"Minus.png"] forState:UIControlStateNormal];
        [self addSubview:free10MBbtn];
        [free10MBbtn addTarget:self action:@selector(free10MBaction:) forControlEvents: UIControlEventTouchUpInside];
        
        
        
        
        UIButton *add50MBbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [add50MBbtn setFrame:CGRectMake([self bounds].size.width/2-30, 165, 30, 30)];
        [add50MBbtn setImage:[UIImage imageNamed:@"Plus.png"] forState:UIControlStateNormal];
        [self addSubview:add50MBbtn];
        [add50MBbtn addTarget:self action:@selector(add50MBaction:) forControlEvents: UIControlEventTouchUpInside];
        
        UIButton *free50MBbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [free50MBbtn setFrame:CGRectMake([self bounds].size.width/2+10, 165, 30, 30)];
        [free50MBbtn setImage:[UIImage imageNamed:@"Minus.png"] forState:UIControlStateNormal];
        [self addSubview:free50MBbtn];
        [free50MBbtn addTarget:self action:@selector(free50MBaction:) forControlEvents: UIControlEventTouchUpInside];
        
        
        
        
        
        UIButton *deallocBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deallocBtn setFrame:CGRectMake([self bounds].size.width/2+10, 215, 30, 30)];
        [deallocBtn setImage:[UIImage imageNamed:@"Refresh.png"] forState:UIControlStateNormal];
        [self addSubview:deallocBtn];
        [deallocBtn addTarget:self action:@selector(deallocAction:) forControlEvents: UIControlEventTouchUpInside];

    }
    return self;
}

-(void) allocatedValueRefresh {
    
    
    [allocated1mbValue setText:[NSString stringWithFormat:@"%d",allocCount1mb]];
    [allocated5mbValue setText:[NSString stringWithFormat:@"%d",allocCount5mb * 5]];
    [allocated10mbValue setText:[NSString stringWithFormat:@"%d",allocCount10mb * 10]];
    [allocated50mbValue setText:[NSString stringWithFormat:@"%d",allocCount50mb * 50]];
    
    allocatedSize = allocCount1mb + allocCount5mb * 5 + allocCount10mb * 10 + allocCount50mb * 50;
    [allocatedSizeValue setText:[NSString stringWithFormat:@"%d",allocatedSize]];
    
}




// 리소스 정보를 가져와서 화면에 Setting
-(void) setResources {
    
    getMemory();
    [self allocatedValueRefresh];
    
    // Remove all components
    [components removeAllObjects];
    // Remove the piecomponent
    [pieChart removeFromSuperview];
    
    // Get all the data
    components = [[NSMutableArray alloc] init];
    
    // Make the piechart view
    int height = [self bounds].size.width/3*2.; // 220;
    int width = [self bounds].size.width - 7; //320;
    pieChart = [[PCPieChart alloc] initWithFrame:CGRectMake(0,[self bounds].size.height - height- 80,width,height)];
    [pieChart setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [pieChart setDiameter:width/2];
    [pieChart setSameColorLabel:YES];
    
    // Add the piechart to the view
    [self addSubview:pieChart];
    
    // Set up for iPad and iPhone
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)
    {
        pieChart.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30];
        pieChart.percentageFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:50];
    }
    
    // Make all the components
    PCPieComponent *component2 = [PCPieComponent pieComponentWithTitle:[NSString stringWithFormat:@"Used\n%.1f% %MB", currentMemory.used] value:currentMemory.used];
    [component2 setColour:PCColorGreen];
    [components addObject:component2];
    
    PCPieComponent *component3 = [PCPieComponent pieComponentWithTitle:[NSString stringWithFormat:@"Free\n%.1f% %MB", currentMemory.free] value:currentMemory.free];
    [component3 setColour:PCColorOrange];
    [components addObject:component3];
    
    PCPieComponent *component4 = [PCPieComponent pieComponentWithTitle:[NSString stringWithFormat:@"Allocated\n%.1d% %MB", allocatedSize] value:allocatedSize];
    [component4 setColour:PCColorRed];
    [components addObject:component4];
    
    PCPieComponent *component5 = [PCPieComponent pieComponentWithTitle:[NSString stringWithFormat:@"Allocable\n%.1f% %MB", (currentMemory.user / 1024) - (currentMemory.free + allocatedSize)] value:(currentMemory.physical / 1024) - (currentMemory.free + allocatedSize)];
    [component5 setColour:PCColorBlue];
    [components addObject:component5];

    // Set all the componenets
    [pieChart setComponents:components];
}



// 메모리 할당 메소드
-(void)allocMem :(int) memSize {
    
    if (memSize == 1) {
        add1Mb[allocCount1mb] = malloc (1024 * 1024);
        memset (add1Mb[allocCount1mb], 0, 1024 *1024);
        allocCount1mb += 1;
    }
    else if (memSize == 5) {
        add5Mb[allocCount5mb] = malloc (5 * 1024 * 1024);
        memset (add5Mb[allocCount5mb], 0, 5 * 1024 *1024);
        allocCount5mb += 1;
        
    }
    else if (memSize == 10) {
        add10Mb[allocCount10mb] = malloc (10 * 1024 * 1024);
        memset (add10Mb[allocCount10mb], 0, 10 * 1024 *1024);
        allocCount10mb += 1;
        
    }
    else if (memSize == 50) {
        add50Mb[allocCount50mb] = malloc (50 * 1024 * 1024);
        memset (add50Mb[allocCount50mb], 0, 50 * 1024 * 1024);
        allocCount50mb += 1;
    }
    else
        NSLog(@"unknown size");
    
    [self refreshMemoryInfo];
    
}


// 메모리 해제 메소드
-(void) freeMem : (int) memSize {
    
    if (memSize == 1) {
        if (allocCount1mb >= 1)
        {
            free (add1Mb[allocCount1mb - 1]);
            allocCount1mb -= 1;
        }
        
    }
    else if (memSize == 5) {
        if (allocCount5mb >= 1)
        {
            free (add5Mb[allocCount5mb - 1]);
            allocCount5mb -= 1;
        }
        
    }
    else if (memSize == 10) {
        if (allocCount10mb >= 1)
        {
            free (add10Mb[allocCount10mb - 1]);
            allocCount10mb -= 1;
        }
    }
    else if (memSize == 50) {
        if (allocCount50mb >= 1)
        {
            free (add50Mb[allocCount50mb - 1]);
            allocCount50mb -= 1;
        }
    }
    else
        NSLog(@"unknown size");
    
    [self refreshMemoryInfo];
    
}


// 메모리 전체 해제 메소드
- (void) freeAllMem {
    
    if (allocCount1mb >= 1)
    {
        for (int i = 0 ; i < allocCount1mb ; i ++)
            free(add1Mb[i]);
    }
    
    if (allocCount5mb >= 1)
    {
        for (int i = 0 ; i < allocCount5mb ; i ++)
            free(add5Mb[i]);
    }
    
    if (allocCount10mb >= 1)
    {
        for (int i = 0 ; i < allocCount10mb ; i ++)
            free(add10Mb[i]);
    }
    
    if (allocCount50mb >= 1)
    {
        for (int i = 0 ; i < allocCount50mb ; i ++)
            free(add50Mb[i]);
    }
    
    allocCount1mb = 0;
    allocCount5mb = 0;
    allocCount10mb = 0;
    allocCount50mb = 0;
    
    [self refreshMemoryInfo];
    
}

// 메모리 정보 갱신
- (void)refreshMemoryInfo {
    
    // Get memory info
//    int mib[2];
//    size_t length;
//    mib[0] = CTL_HW;
//    
//    
//    mib[1] = HW_MEMSIZE;
//    length = sizeof(int64_t);
//    sysctl(mib, 2, &physicalMemorySize, &length, NULL, 0);
//    
//    mib[1] = HW_USERMEM;
//    length = sizeof(int64_t);
//    sysctl(mib, 2, &userMemorySize, &length, NULL, 0);
    getMemory();
    [self setResources];
}


// 버튼 액션 정의
- (void)add1MBaction:(UIButton*)sender {
    [self allocMem:1];
}

- (void)add5MBaction:(UIButton*)sender {
    [self allocMem:5];
}

- (void)add10MBaction:(UIButton*)sender {
    [self allocMem:10];
}

- (void)add50MBaction:(UIButton*)sender {
    [self allocMem:50];
}

- (void)free1MBaction:(UIButton*)sender {
    [self freeMem:1];
}

- (void)free5MBaction:(UIButton*)sender {
    [self freeMem:5];
}

- (void)free10MBaction:(UIButton*)sender {
    [self freeMem:10];
}

- (void)free50MBaction:(UIButton*)sender {
    [self freeMem:50];
}

- (void)deallocAction:(UIButton*)sender {
    [self freeAllMem];
}


@end
