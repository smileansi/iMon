//
//  Third.m
//  SlideMenuAndMulitView
//
//  Created by JWMAC on 13. 7. 26..
//  Copyright (c) 2013년 Kim Ji Wook. All rights reserved.
//

#import "ThirdView.h"
#import "iMonUtils.h"

@implementation ThirdView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *test = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height)/2-30, 320, 30)];
        [test setText:@"미구현"];
        [test setBackgroundColor:[UIColor clearColor]];
        test.textAlignment = NSTextAlignmentCenter;
        [self addSubview:test];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
