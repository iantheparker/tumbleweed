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
    CALayer *tapHint;
    CADisplayLink *displayLink;
    int middleWidth;
    unsigned int gestureCount;
}

@synthesize scrollView = _scrollView;
@synthesize containerView, text1, text2, text3, text4, bgImg;


#pragma mark -

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

-(void) updateScrollDisplay : (NSTimer*) timer
{
    float loc = self.scrollView.contentOffset.y;
    int cutoff = -20;
    //CGPoint mapCenter = self.scrollView.center;
    //float offset =  - self.scrollView.contentOffset.y;
    
    //NSLog(@"gestureCount = %d, ", gestureCount);
    
    if (gestureCount == 0) {
        //do nothing. wait for gesture
    }
    else if (gestureCount == 1)
    {
        //wave twlogo out
        {
            
            CAKeyframeAnimation *tWLogoLayerAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
            tWLogoLayerAnim.duration = 0.75f;
            tWLogoLayerAnim.removedOnCompletion = NO;
            tWLogoLayerAnim.fillMode = kCAFillModeForwards;
            tWLogoLayerAnim.values = [NSArray arrayWithObjects:
                                          [NSNumber numberWithFloat:0.0],
                                          [NSNumber numberWithFloat:-200.0],
                                          nil] ;
            tWLogoLayerAnim.keyTimes = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0.0],
                                      [NSNumber numberWithFloat:1.0],
                                      nil] ;
            tWLogoLayerAnim.timingFunctions = [NSArray arrayWithObjects:
                                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                               nil] ;
            
            tWLogoLayerAnim.calculationMode = kCAAnimationCubic;
            [tWLogoLayer addAnimation:tWLogoLayerAnim forKey:Nil];
            
            
            CAKeyframeAnimation *tumbleweedLogoAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            tumbleweedLogoAnim.values = [NSArray arrayWithObjects:
                                         [NSNumber numberWithFloat:0],
                                         [NSNumber numberWithFloat: M_PI],
                                         nil];
            tumbleweedLogoAnim.keyTimes = [NSArray arrayWithObjects:
                                           [NSNumber numberWithFloat:0.0],
                                           [NSNumber numberWithFloat:1.0],
                                           nil] ;
            tumbleweedLogoAnim.timingFunctions = [NSArray arrayWithObjects:
                                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault],
                                                  nil] ;
            tumbleweedLogoAnim.duration = tWLogoLayerAnim.duration;
            tumbleweedLogoAnim.removedOnCompletion = NO;
            tumbleweedLogoAnim.calculationMode = kCAAnimationCubic;
            tumbleweedLogoAnim.fillMode = kCAFillModeForwards;
            [tumbleweedLogo addAnimation:tumbleweedLogoAnim forKey:Nil];
        }
        
        //wave 3 marketing points in
        {
            [UIView animateWithDuration:0.8 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                text1.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width/5);
            } completion:^(BOOL finished) {
                //
            }];
            [UIView animateWithDuration:0.8 delay:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                text2.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, 2*[[UIScreen mainScreen] bounds].size.width/5-15);
            } completion:^(BOOL finished) {
                //
            }];
            [UIView animateWithDuration:0.8 delay:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                text3.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, 3*[[UIScreen mainScreen] bounds].size.width/5 -30);
            } completion:^(BOOL finished) {
                //
            }];
            [UIView animateWithDuration:0.8 delay:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                text4.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, 4*[[UIScreen mainScreen] bounds].size.width/5 -30);
            } completion:^(BOOL finished) {
                //
            }];
        }
        
        gestureCount++;
    }
    else if (gestureCount == 2)
    {
        //wave out marketing points
        //gestureCount++;
        
    }
    else if (gestureCount == 3)
    {
        //wave out marketing points
        gestureCount++;
        [UIView animateWithDuration:3.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            bgImg.center = CGPointMake(bgImg.center.x, 0);
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:^{}];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
        }];
        [UIView animateWithDuration:0.8 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            text1.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, -100);
        } completion:^(BOOL finished) {
            //
        }];
        [UIView animateWithDuration:0.8 delay:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            text2.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, -100);
        } completion:^(BOOL finished) {
            //
        }];
        [UIView animateWithDuration:0.8 delay:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            text3.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, -100);
        } completion:^(BOOL finished) {
            //
        }];
        [UIView animateWithDuration:0.8 delay:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            text4.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, -100);
        } completion:^(BOOL finished) {
            //
        }];
    }
    else if (gestureCount >= 4)
    {
        [tapHint removeFromSuperlayer];
        //animate scroll
        
        float highspeed = 1.25;
        float lowspeed = 0.25;
        float middleHeight = ([UIScreen mainScreen].bounds.size.width - cutoff)/2.0 ;
        float diffspeed = lowspeed + (highspeed - lowspeed) * pow(M_E, -pow((middleHeight - loc)/200, 4));
        diffspeed = roundf(diffspeed*4)/4;
        self.scrollView.contentOffset = CGPointMake(0, loc + diffspeed);
        NSLog(@"diffspeed %f", diffspeed);
        
        
        
    }
    
    [self renderParallax];
}

-(void) renderParallax
{
    //MAP LAYER PARALLAX SPEEDS
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGPoint mapCenter = self.scrollView.center;
    float offset =  - self.scrollView.contentOffset.y;
    
    //-sky position- CALayer - fix the hardcoded offset here
    CGPoint cloud1Center = CGPointMake(middleWidth, mapCenter.y +(offset * cloud1Layer.speed));
    [cloud1Layer setPosition:cloud1Center];
    
    //--> layer1C position
    CGPoint cloud2Center = CGPointMake(middleWidth, mapCenter.y +(offset * cloud2Layer.speed));
    [cloud2Layer setPosition:cloud2Center];
    
    /*
         
    float middleHeight = ([[UIScreen mainScreen] bounds].size.width/2) - offset;
    
    text1.layer.speed = 4;
    text2.layer.speed = 3;
    text3.layer.speed = 2;
    float slowspeed = 0.2;
     
    tumbleweedLogo.transform = CATransform3DMakeRotation(offset*-M_PI_4*.2, 0, 0, 1);
     
    CGPoint textCenter = CGPointMake(middleWidth, mapCenter.y + (offset * 3) );
    [tWLogoLayer setPosition:textCenter];
     
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
    //skyLayer.contents = (__bridge id)(skybg.CGImage);
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
    
    text1.center = CGPointMake(middleWidth, canvas_h-50);
    text2.center = CGPointMake(middleWidth, canvas_h);
    text3.center = CGPointMake(middleWidth, canvas_h+50);
    text4.center = CGPointMake(middleWidth, canvas_h+100);
    
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
    
    tapHint = [CALayer layer];
    UIImage *tapHintImg = [UIImage imageNamed:@"tap_tip_1.png"];
    tapHint.bounds = CGRectMake(0, 0, tapHintImg.size.width, tapHintImg.size.height);
    tapHint.position = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, 4.4 * [[UIScreen mainScreen] bounds].size.width/5);
    tapHint.contents = (__bridge id)tapHintImg.CGImage;
    [self.scrollView.layer addSublayer:tapHint];
    
    CABasicAnimation *tapHintAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    tapHintAnim.fromValue = [NSNumber numberWithFloat:.0];
    tapHintAnim.toValue = [NSNumber numberWithFloat: 1.0];
    tapHintAnim.duration = 1.0f;
    tapHintAnim.autoreverses = YES;
    tapHintAnim.repeatCount = HUGE_VALF;
    tapHintAnim.removedOnCompletion = NO;
    [tapHint addAnimation:tapHintAnim forKey:@"opacity"];
    
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
    
    UITapGestureRecognizer *gestureHandler = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
    [gestureHandler setDelegate:self];
    [self.scrollView addGestureRecognizer:gestureHandler];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateScrollDisplay:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

}

- (void) handleSingleTap: (UIGestureRecognizer*) sender
{
    NSLog(@"gesture recognized");
    gestureCount++;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    if (scrollView.contentOffset.y >= canvas_h - [[UIScreen mainScreen] bounds].size.width)
    {
        NSLog(@"over 960");
        //self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //[self dismissViewControllerAnimated:NO completion:^{}];
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
        [displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    
}

@end
