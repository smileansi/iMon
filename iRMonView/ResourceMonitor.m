//
//  FirstView.m
//  SlideMenuAndMulitView
//
//  Created by JWMAC on 13. 7. 26..
//  Copyright (c) 2013년 Kim Ji Wook. All rights reserved.
//

#import "ResourceMonitor.h"
#import "iMonUtils.h"
#import "PCPieChart.h"

@implementation ResourceMonitor {
    UILabel *CPU1Value;
    UILabel *CPU2Value;
    
    UIView *CPULine1;
    UIView *CPULine2;
    
    UILabel *PhysicalValue;
    UILabel *UserValue;
    UILabel *UsedValue;
    UILabel *TotalValue;
    
    UILabel *WifiValue;
    UILabel *CellularValue;
    UILabel *LocalValue;
    
    
    NSTimer *_refreshTimer;
    
    PCPieChart *pieChart;
    NSMutableArray *components;


}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    
    // 1초 인터벌로 setResources 실행
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setResources) userInfo:nil repeats:YES];
    
    
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        getCPU();
        getMemory();
        getTraffic();
        
        //CPU
        UILabel *CPULabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 30)];
        [CPULabel setFont:[UIFont boldSystemFontOfSize:14]];
        [CPULabel setText:@"CPU"];
        [self addSubview:CPULabel];
        
        UILabel *CPU1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 50, 30)];
        [CPU1 setFont:[UIFont systemFontOfSize:12]];
        [CPU1 setText:@"CPU #0"];
        [self addSubview:CPU1];
        
        UILabel *CPU2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, 50, 30)];
        [CPU2 setFont:[UIFont systemFontOfSize:12]];
        [CPU2 setText:@"CPU #1"];
        [self addSubview:CPU2];
        
        CPU1Value = [[UILabel alloc] initWithFrame:CGRectMake(60, 40, 100, 30)];
        [CPU1Value setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:CPU1Value];
        
        CPU2Value = [[UILabel alloc] initWithFrame:CGRectMake(60, 80, 100, 30)];
        [CPU2Value setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:CPU2Value];
        
        
        //Traffics
        UILabel *trafficLabel = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width / 2, 10, 100, 30)];
        [trafficLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [trafficLabel setText:@"TRAFFICS"];
        [self addSubview:trafficLabel];
        
        UILabel *Wifi = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width / 2, 40, 140, 30)];
        [Wifi setFont:[UIFont systemFontOfSize:12]];
        [Wifi setText:@"Wi-Fi (rx / tx)"];
        [self addSubview:Wifi];
        
        WifiValue =[[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2 + 40, 60, 100, 30)];
        [WifiValue setFont:[UIFont systemFontOfSize:12]];
        [WifiValue setText:[NSString stringWithFormat:@"%d / %d KB", currentWiFi.rx - currentWiFi.rxFirst, currentWiFi.tx - currentWiFi.txFirst]];
        WifiValue.textAlignment = NSTextAlignmentRight;
        [self addSubview:WifiValue];
        
        
        UILabel *Cellular = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width / 2, 80, 140, 30)];
        [Cellular setFont:[UIFont systemFontOfSize:12]];
        [Cellular setText:@"Cellular (rx / tx)"];
        [self addSubview:Cellular];
        
        
        CellularValue =[[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2 + 40, 100, 100, 30)];
        [CellularValue setFont:[UIFont systemFontOfSize:12]];
        [CellularValue setText:[NSString stringWithFormat:@"%d / %d KB", currentCell.rx - currentCell.rxFirst, currentCell.tx - currentCell.txFirst]];
        CellularValue.textAlignment = NSTextAlignmentRight;
        [self addSubview:CellularValue];
        
        
        UILabel *Local = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width / 2, 120, 140, 30)];
        [Local setFont:[UIFont systemFontOfSize:12]];
        [Local setText:@"Local (rx / tx)"];
        [self addSubview:Local];
        
        
        LocalValue =[[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2 + 40, 140, 100, 30)];
        [LocalValue setFont:[UIFont systemFontOfSize:12]];
        [LocalValue setText:[NSString stringWithFormat:@"%d / %d KB", currentLocal.rx - currentLocal.rxFirst, currentLocal.tx - currentLocal.txFirst]];
        LocalValue.textAlignment = NSTextAlignmentRight;
        [self addSubview:LocalValue];

        
        //Memory
        UILabel *MemLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, [self bounds].size.height/2 - 100, 100, 30)];
        [MemLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [MemLabel setText:@"MEMORY"];
        [self addSubview:MemLabel];
        
        UILabel *physical = [[UILabel alloc] initWithFrame:CGRectMake(10, [self bounds].size.height/2 - 70, 100, 30)];
        [physical setFont:[UIFont systemFontOfSize:12]];
        [physical setText:@"Physical"];
        [self addSubview:physical];
        
        PhysicalValue =[[UILabel alloc] initWithFrame:CGRectMake(40, [self bounds].size.height/2 - 70, 100, 30)];
        [PhysicalValue setFont:[UIFont systemFontOfSize:12]];
        [PhysicalValue setText:[NSString stringWithFormat:@"%.1f% %MB", currentMemory.physical / 1024]];
        PhysicalValue.textAlignment = NSTextAlignmentRight;
        [self addSubview:PhysicalValue];
        
        UILabel *used = [[UILabel alloc] initWithFrame:CGRectMake(10, [self bounds].size.height/2 - 50, 100, 30)];
        [used setFont:[UIFont systemFontOfSize:12]];
        [used setText:@"Used"];
        [self addSubview:used];
        
        UsedValue =[[UILabel alloc] initWithFrame:CGRectMake(40, [self bounds].size.height/2 - 50, 100, 30)];
        [UsedValue setFont:[UIFont systemFontOfSize:12]];
        [UsedValue setText:[NSString stringWithFormat:@"%.1f% %MB", currentMemory.used]];
        UsedValue.textAlignment = NSTextAlignmentRight;
        [self addSubview:UsedValue];
        
        
        UILabel *user = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2, [self bounds].size.height/2 - 70, 100, 30)];
        [user setFont:[UIFont systemFontOfSize:12]];
        [user setText:@"User"];
        [self addSubview:user];
        
        UserValue =[[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2 + 40, [self bounds].size.height/2 - 70, 100, 30)];
        [UserValue setFont:[UIFont systemFontOfSize:12]];
        [UserValue setText:[NSString stringWithFormat:@"%.1f% %MB", currentMemory.user / 1024]];
        UserValue.textAlignment = NSTextAlignmentRight;
        [self addSubview:UserValue];
        
        UILabel *total = [[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2, [self bounds].size.height/2 - 50, 100, 30)];
        [total setFont:[UIFont systemFontOfSize:12]];
        [total setText:@"Total"];
        [self addSubview:total];
        
        TotalValue =[[UILabel alloc] initWithFrame:CGRectMake([self bounds].size.width/2 + 40, [self bounds].size.height/2 - 50, 100, 30)];
        [TotalValue setFont:[UIFont systemFontOfSize:12]];
        [TotalValue setText:[NSString stringWithFormat:@"%.1f% %MB", currentMemory.total]];
        TotalValue.textAlignment = NSTextAlignmentRight;
        [self addSubview:TotalValue];
        
        
    }
    return self;
}



// 리소스 정보를 가져와서 화면에 Setting
-(void) setResources {
    
    // remove lineView
    [CPULine1 removeFromSuperview ];
    [CPULine2 removeFromSuperview ];
    
    //CPU
    [CPU1Value setText:[NSString stringWithFormat:@"%.2f%%", currentCPU.core0]];
    [CPU2Value setText:[NSString stringWithFormat:@"%.2f%%", currentCPU.core1]];
    
    CPULine1 = [[UIView alloc] initWithFrame:CGRectMake(10, 70, currentCPU.core0, 3)];
    CPULine2 = [[UIView alloc] initWithFrame:CGRectMake(10, 110, currentCPU.core1, 3)];
    
    [CPULine1 setBackgroundColor:PCColorBlue];
    [CPULine2 setBackgroundColor:PCColorGreen];
    
    [self addSubview:CPULine1];
    [self addSubview:CPULine2];
    
    
    //Traffics
    [WifiValue setText:[NSString stringWithFormat:@"%d / %d KB", currentWiFi.rx - currentWiFi.rxFirst, currentWiFi.tx - currentWiFi.txFirst]];
    [CellularValue setText:[NSString stringWithFormat:@"%d / %d KB", currentCell.rx - currentCell.rxFirst, currentCell.tx - currentCell.txFirst]];
    [LocalValue setText:[NSString stringWithFormat:@"%d / %d KB", currentLocal.rx - currentLocal.rxFirst, currentLocal.tx - currentLocal.txFirst]];
    
    
    // Memory
    [PhysicalValue setText:[NSString stringWithFormat:@"%.1f% %MB", currentMemory.physical / 1024]];
    [UsedValue setText:[NSString stringWithFormat:@"%.1f% %MB", currentMemory.used]];
    [UserValue setText:[NSString stringWithFormat:@"%.1f% %MB", currentMemory.user / 1024]];
    [TotalValue setText:[NSString stringWithFormat:@"%.1f% %MB", currentMemory.total]];
    
    
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
    
    PCPieComponent *component2 = [PCPieComponent pieComponentWithTitle:[NSString stringWithFormat:@"Wired\n%.1f% %MB", currentMemory.wired] value:currentMemory.wired];
    [component2 setColour:PCColorGreen];
    [components addObject:component2];
    
    PCPieComponent *component3 = [PCPieComponent pieComponentWithTitle:[NSString stringWithFormat:@"Active\n%.1f% %MB", currentMemory.active] value:currentMemory.active];
    [component3 setColour:PCColorOrange];
    [components addObject:component3];
    
    PCPieComponent *component4 = [PCPieComponent pieComponentWithTitle:[NSString stringWithFormat:@"Inactive\n%.1f% %MB", currentMemory.inactive] value:currentMemory.inactive];
    [component4 setColour:PCColorRed];
    [components addObject:component4];
    
    PCPieComponent *component5 = [PCPieComponent pieComponentWithTitle:[NSString stringWithFormat:@"Free\n%.1f% %MB", currentMemory.free] value:currentMemory.free];
    [component5 setColour:PCColorBlue];
    [components addObject:component5];

    
    // Set all the componenets
    [pieChart setComponents:components];
}


@end
