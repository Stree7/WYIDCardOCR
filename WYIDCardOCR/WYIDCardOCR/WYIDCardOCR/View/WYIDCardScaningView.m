//
//  WYIDCardScaningView.m
//  WYIDCardOCR
//
//  Created by 汪年成 on 17/7/6.
//  Copyright © 2017年 之静之初. All rights reserved.
//

#import "WYIDCardScaningView.h"

// iPhone5/5c/5s/SE 4英寸 屏幕宽高：320*568点 屏幕模式：2x 分辨率：1136*640像素
#define iPhone5or5cor5sorSE ([UIScreen mainScreen].bounds.size.height == 568.0)

// iPhone6/6s/7 4.7英寸 屏幕宽高：375*667点 屏幕模式：2x 分辨率：1334*750像素
#define iPhone6or6sor7 ([UIScreen mainScreen].bounds.size.height == 667.0)

// iPhone6 Plus/6s Plus/7 Plus 5.5英寸 屏幕宽高：414*736点 屏幕模式：3x 分辨率：1920*1080像素
#define iPhone6Plusor6sPlusor7Plus ([UIScreen mainScreen].bounds.size.height == 736.0)

/** 相对4.0寸屏幕宽的自动布局 */
#define KRealWidth5(value)  (long)((value)/320.0f * [UIScreen mainScreen].bounds.size.width)


@interface WYIDCardScaningView ()
{
    CAShapeLayer *_IDCardScanningWindowLayer;
    NSTimer *_timer;
}
@end

@implementation WYIDCardScaningView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)scaningCardIDWithType:(ScaningCardType)type
{
    // 添加扫描窗口
    [self addScaningWindowWithType:type];
    
    // 添加定时器
    [self addTimer];
}


#pragma mark - 添加扫描窗口
- (void)addScaningWindowWithType:(ScaningCardType)type
{
    // 中间包裹线
    _IDCardScanningWindowLayer = [CAShapeLayer layer];
    _IDCardScanningWindowLayer.position = self.layer.position;
    CGFloat width = iPhone5or5cor5sorSE? 240: (iPhone6or6sor7? 270: 300);
    _IDCardScanningWindowLayer.bounds = (CGRect){CGPointZero, {width, width * 1.574}};
    _IDCardScanningWindowLayer.cornerRadius = 15;
    _IDCardScanningWindowLayer.borderColor = [UIColor whiteColor].CGColor;
    _IDCardScanningWindowLayer.borderWidth = 1.5;
    [self.layer addSublayer:_IDCardScanningWindowLayer];
    
    // 最里层镂空
    UIBezierPath *transparentRoundedRectPath = [UIBezierPath bezierPathWithRoundedRect:_IDCardScanningWindowLayer.frame cornerRadius:_IDCardScanningWindowLayer.cornerRadius];
    
    // 最外层背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.frame];
    [path appendPath:transparentRoundedRectPath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.6;
    
    [self.layer addSublayer:fillLayer];
    
    CGFloat facePathWidth = iPhone5or5cor5sorSE? 125: (iPhone6or6sor7? 150: 180);
    CGFloat facePathHeight = facePathWidth * 0.812;
    CGRect rect = _IDCardScanningWindowLayer.frame;
    self.facePathRect = (CGRect){CGRectGetMaxX(rect) - facePathWidth - 35,CGRectGetMaxY(rect) - facePathHeight - 25,facePathWidth,facePathHeight};
    
    // 提示标签
    CGPoint center = self.center;
    center.x = CGRectGetMaxX(_IDCardScanningWindowLayer.frame) + 20;
    
    
    NSString *titles = type == ScaningCardIDWithBank ? @"将银行卡置于此区域内，进行扫描" : @"将身份证置于此区域内，进行扫描";
    [self addTipLabelWithText:titles center:center];
    
    
    // 人像
    if (type == ScaningCardIDWithFront) {
        
        UIImageView *headIV = [[UIImageView alloc] initWithFrame:_facePathRect];
        headIV.image = [UIImage imageNamed:@"IDCard_head"];
        headIV.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        headIV.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:headIV];
        
    }
    
    else if (type == ScaningCardIDWithDown) {
        
        CGFloat X = rect.size.width + rect.origin.x - KRealWidth5(94);
        CGFloat Y = rect.origin.y + KRealWidth5(20);
        UIImageView *headIV = [[UIImageView alloc] initWithFrame:CGRectMake(X, Y, KRealWidth5(80), KRealWidth5(80))];
        headIV.image = [UIImage imageNamed:@"IDCard_guohui"];
        headIV.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        headIV.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:headIV];
        
    }
    
    
    
    
    
    
}

#pragma mark - 添加提示标签
- (void)addTipLabelWithText:(NSString *)text center:(CGPoint)center {
    UILabel *tipLabel = [[UILabel alloc] init];
    
    tipLabel.text = text;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    
    tipLabel.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    [tipLabel sizeToFit];
    
    tipLabel.center = center;
    
    [self addSubview:tipLabel];
}

#pragma mark - 添加定时器
- (void)addTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)timerFire:(id)notice {
    [self setNeedsDisplay];
}

- (void)dealloc {
    [_timer invalidate];
}

- (void)drawRect:(CGRect)rect {
    rect = _IDCardScanningWindowLayer.frame;
    
    // 人像提示框
//    UIBezierPath *facePath = [UIBezierPath bezierPathWithRect:_facePathRect];
//    facePath.lineWidth = 1.5;
//    [[UIColor whiteColor] set];
//    [facePath stroke];
    
    // 水平扫描线
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    static CGFloat moveX = 0;
    static CGFloat distanceX = 0;
    
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 2);
    CGContextSetRGBStrokeColor(context,0.3,0.8,0.3,0.8);
    CGPoint p1, p2;// p1, p2 连成水平扫描线;
    
    moveX += distanceX;
    if (moveX >= CGRectGetWidth(rect) - 2) {
        distanceX = -2;
    } else if (moveX <= 2){
        distanceX = 2;
    }
    
    p1 = CGPointMake(CGRectGetMaxX(rect) - moveX, rect.origin.y);
    p2 = CGPointMake(CGRectGetMaxX(rect) - moveX, rect.origin.y + rect.size.height);
    
    CGContextMoveToPoint(context,p1.x, p1.y);
    CGContextAddLineToPoint(context, p2.x, p2.y);
    
    /*
     // 竖直扫描线
     static CGFloat moveY = 0;
     static CGFloat distanceY = 0;
     CGPoint p3, p4;// p3, p4连成竖直扫描线
     
     moveY += distanceY;
     if (moveY >= CGRectGetHeight(rect) - 2) {
     distanceY = -2;
     } else if (moveY <= 2) {
     distanceY = 2;
     }
     p3 = CGPointMake(rect.origin.x, rect.origin.y + moveY);
     p4 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + moveY);
     
     CGContextMoveToPoint(context,p3.x, p3.y);
     CGContextAddLineToPoint(context, p4.x, p4.y);
     */
    
    CGContextStrokePath(context);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    [[UIColor colorWithWhite:0 alpha:0.7] setFill];
//    // 半透明区域
//    UIRectFill(rect);
//
//    // 透明区域
//    CGRect holeRection = self.layer.sublayers[0].frame;
//    /** union: 并集
//     CGRect CGRectUnion(CGRect r1, CGRect r2)
//     返回并集部分rect
//     */
//
//    /** Intersection: 交集
//     CGRect CGRectIntersection(CGRect r1, CGRect r2)
//     返回交集部分rect
//     */
//    CGRect holeiInterSection = CGRectIntersection(holeRection, rect);
//    [[UIColor clearColor] setFill];
//
//    //CGContextClearRect(ctx, <#CGRect rect#>)
//    //绘制
//    //CGContextDrawPath(ctx, kCGPathFillStroke);
//    UIRectFill(holeiInterSection);
//}





@end
