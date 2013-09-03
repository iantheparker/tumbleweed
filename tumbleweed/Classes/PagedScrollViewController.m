//
//  PagedScrollViewController.m
//  ScrollViews
//
//  Created by Matt Galloway on 01/03/2012.
//  Copyright (c) 2012 Swipe Stack Ltd. All rights reserved.
//

#import "PagedScrollViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>


#define canvas_h 640

@implementation PagedScrollViewController{
@private
    CALayer *tWLogoLayer;
    CALayer *cloud1Layer;
    CALayer *cloud2Layer;
    CALayer *tumbleweedLogo;
    CADisplayLink *displayLink;
    int middleWidth;
}

@synthesize scrollView = _scrollView;
@synthesize containerView, text1, text2, text3;


#pragma mark -

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

-(void) updateScrollDisplay : (NSTimer*) timer
{
    float loc = self.scrollView.contentOffset.y;
    
    if (loc <= 160 )
        self.scrollView.contentOffset = CGPointMake(0, loc+0.25);
    else if ( loc > 150 && loc <= 320)
    {
        float highspeed = 1.25;
        float lowspeed = 0.25;
        float middleHeight = (320 - 150)/2.0 + 150;
        float diffspeed = highspeed - (highspeed - lowspeed) * pow(M_E, -pow((middleHeight - loc)/100, 4));
        self.scrollView.contentOffset = CGPointMake(0, loc + diffspeed);
        NSLog(@"diffspeed %f", diffspeed);
    }
}

-(void) renderParallax
{
    //MAP LAYER PARALLAX SPEEDS
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGPoint mapCenter = self.scrollView.center;
    //float offset = self.scrollView.contentOffset.y - mapCenter.y;
    float offset =  - self.scrollView.contentOffset.y;
    float middleHeight = ([[UIScreen mainScreen] bounds].size.width/2) - offset;
    
    text1.layer.speed = 4;
    text2.layer.speed = 3;
    text3.layer.speed = 2;
    float slowspeed = 0.2;
    
    tumbleweedLogo.transform = CATransform3DMakeRotation(offset*-M_PI_4*.2, 0, 0, 1);

    CGPoint textCenter = CGPointMake(middleWidth, mapCenter.y + (offset * 3) );
    [tWLogoLayer setPosition:textCenter];
    
    //-sky position- CALayer - fix the hardcoded offset here
    CGPoint cloud1Center = CGPointMake(middleWidth, mapCenter.y +(offset * cloud1Layer.speed));
    [cloud1Layer setPosition:cloud1Center];
    
    //--> layer1C position
    CGPoint cloud2Center = CGPointMake(middleWidth, mapCenter.y +(offset * cloud2Layer.speed));
    [cloud2Layer setPosition:cloud2Center];
    
    CGPoint text1WindowPoint = [text1 convertPoint:self.scrollView.bounds.origin toView:self.view];
    text1.alpha = pow(M_E, -pow((middleHeight - text1WindowPoint.y)/100, 4));
    float text1speed = text1.layer.speed - (text1.layer.speed - slowspeed) * text1.alpha;
    CGPoint text1Center = CGPointMake(middleWidth, text1.center.y + (offset * text1speed/20));
    text1.center = text1Center;
    //NSLog(@"windowpointY %f, text1CenterY %f, text1speed %f, text1alpha %f", middleHeight - text1WindowPoint.y, text1Center.y, text1speed, text1.alpha);

    CGPoint text2WindowPoint = [text2 convertPoint:self.scrollView.bounds.origin toView:self.view];
    text2.alpha = pow(M_E, -pow((middleHeight - text2WindowPoint.y)/100, 4));
    float text2speed = text2.layer.speed - (text2.layer.speed - slowspeed) * text2.alpha;
    CGPoint text2Center = CGPointMake(middleWidth, text2.center.y + (offset * text2speed/30));
    text2.center = text2Center;
    
    CGPoint text3WindowPoint = [text3 convertPoint:self.scrollView.bounds.origin toView:self.view];
    text3.alpha = pow(M_E, -pow((middleHeight - text3WindowPoint.y)/100, 4));
    float text3speed = text3.layer.speed - (text3.layer.speed - slowspeed) * text3.alpha;
    CGPoint text3Center = CGPointMake(middleWidth, text3.center.y + (offset * text3speed/30));
    text3.center = text3Center;
    
    /*
    basespeed = 100;
    slowspeed = 40;
    diffspeed = basespeed - slowspeed;
    textspeed(y) = basespeed - diffspeed * alpha(y);
    
     e^-y
     y = x-100  means it will peak at x = 100
     */
    
    [CATransaction commit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    middleWidth = [[UIScreen mainScreen] bounds].size.height/2;

    // Set up the content size of the scroll view
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    //CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, canvas_h);
    //bgImage.bounds = CGRectMake(0, 0, bgImage.image.size.width, bgImage.image.size.height);
    CALayer *skyLayer = [CALayer layer];
    UIImage *skybg = [UIImage imageNamed:@"intro_sky_texture_1280.jpg"];
    skyLayer.anchorPoint = CGPointMake(0, 0);
    
    skyLayer.frame = CGRectMake(0, 0, skybg.size.width, skybg.size.height);
    //set for iphone 4 size too
    //skyLayer.position = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, canvas_h/2);
    skyLayer.contents = (__bridge id)(skybg.CGImage);
    //skyLayer.contentsGravity = kCAGravityBottomLeft;
    [self.scrollView.layer insertSublayer:skyLayer atIndex:0];
    
    tWLogoLayer = [CALayer layer];
    tWLogoLayer.zPosition = 0;
    tWLogoLayer.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    [self.view.layer addSublayer:tWLogoLayer];
    cloud1Layer = [CALayer layer];
    cloud1Layer.zPosition = 1;
    cloud1Layer.speed = 1.8;
    cloud1Layer.frame = tWLogoLayer.frame;
    [self.view.layer addSublayer:cloud1Layer];
    cloud2Layer = [CALayer layer];
    cloud2Layer.zPosition = 2;
    cloud2Layer.speed = 2.5;
    cloud2Layer.frame = tWLogoLayer.frame; //CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);;
    [self.view.layer addSublayer:cloud2Layer];
    
    text1.center = CGPointMake(middleWidth, canvas_h/2);
    text2.center = CGPointMake(middleWidth, canvas_h);
    text3.center = CGPointMake(middleWidth, canvas_h*1.5);
    //text4.center = CGPointMake(middleWidth, mapCenter.y +250);
    
    NSLog(@"cloud2 pos %f,%f", cloud2Layer.position.x, cloud2Layer.position.y);
    
    CALayer *tumbleweedLogoType = [CALayer layer];
    UIImage *tumbleweedLogoTypeImg = [UIImage imageNamed:@"TW-logo-type.png"];
    UIImage *tumbleweedLogoImg = [UIImage imageNamed:@"TW-logo.png"];

    tumbleweedLogoType.bounds = CGRectMake(0, 0, tumbleweedLogoTypeImg.size.width/2, tumbleweedLogoTypeImg.size.height/2);
    tumbleweedLogoType.position = CGPointMake([[UIScreen mainScreen] bounds].size.height/2-tumbleweedLogoImg.size.width/4, [[UIScreen mainScreen] bounds].size.width/2);
    tumbleweedLogoType.contents = (__bridge id)tumbleweedLogoTypeImg.CGImage;
    [tWLogoLayer addSublayer:tumbleweedLogoType];
    
    tumbleweedLogo = [CALayer layer];
    tumbleweedLogo.bounds = CGRectMake(0, 0, tumbleweedLogoImg.size.width/2, tumbleweedLogoImg.size.height/2);
    tumbleweedLogo.anchorPoint = CGPointMake(0.5, 0.5);
    tumbleweedLogo.position = CGPointMake(tumbleweedLogo.bounds.size.width/2 + tumbleweedLogoType.bounds.size.width+5, 12);
    tumbleweedLogo.contents = (__bridge id)tumbleweedLogoImg.CGImage;
    [tumbleweedLogoType addSublayer:tumbleweedLogo];
    
    static const int cloudTotal = 12;
    static const CGPoint cloudPos[cloudTotal] = {
        
        {103, 64},
        {51, 370},
        {457, 54},
        {184, 129},
        {340, 400},
        {224, 263},
        {392, 255},
        {176, 70},
        {295, 200},
        {440, 30},
        {95, 110},
        {78, 223}
    };
    
    for (int i = 1; i<=cloudTotal; i++)
    {
        //int randomPosX = [self getRandomNumberBetween:0 to:[[UIScreen mainScreen] bounds].size.height -100];
        //int randomPosY = [self getRandomNumberBetween:0 to:[[UIScreen mainScreen] bounds].size.width ];
        
        //NSLog(@"{%d, %d}", randomPosX, randomPosY);
        
        CALayer *cloud1 = [CALayer layer];
        UIImage *cloud1img = [UIImage imageNamed:[NSString stringWithFormat:@"cloud_%02d.png", i]];
        cloud1.bounds = CGRectMake(0, 0, cloud1img.size.width/2, cloud1img.size.height/2);
        //cloud1.position = CGPointMake(0, (canvas_h / cloudTotal) * i);
        cloud1.position = CGPointMake(0, cloudPos[i].y);
        CGImageRef cloud1imgref = [cloud1img CGImage];
        [cloud1 setContents:(__bridge id)cloud1imgref];
        //cloud1.name = @"cloud";
        if (i%2)[cloud1Layer addSublayer:cloud1];
        else [cloud2Layer addSublayer:cloud1];
        
        CABasicAnimation *cloud1anim;
        cloud1anim = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        //cloud1anim.fromValue = [NSNumber numberWithInt:([[UIScreen mainScreen] bounds].size.height/cloudTotal) * i];
        cloud1anim.fromValue = [NSNumber numberWithInt:cloudPos[i].x];
        cloud1anim.toValue = [NSNumber numberWithInt:[[UIScreen mainScreen] bounds].size.height];
        cloud1anim.duration = [self getRandomNumberBetween:70 to:150]; //90 - 300?
        cloud1anim.autoreverses = YES;
        //cloud1anim.cumulative = YES;
        cloud1anim.repeatCount = HUGE_VAL;
        cloud1anim.removedOnCompletion = NO;
        //cloud1anim.fillMode = kCAFillModeForwards;
        //cloud1anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        cloud1anim.delegate = self;
        [cloud1anim setValue:@"cloud" forKey:@"tag"];
        [cloud1 addAnimation:cloud1anim forKey:[NSString stringWithFormat:@"cloud_%02d", i]];
        
        
        
    }
    [self renderParallax];

    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateScrollDisplay:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    if (scrollView.contentOffset.y >= canvas_h - [[UIScreen mainScreen] bounds].size.width)
    {
        NSLog(@"over 960");
        //self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self dismissViewControllerAnimated:NO completion:^{}];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
        [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    [self renderParallax];
    
}



@end
