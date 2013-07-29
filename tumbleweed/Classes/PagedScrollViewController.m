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


#define canvas_h 960


@implementation PagedScrollViewController{
@private
    CALayer *tWLogoLayer;
    CALayer *cloud1Layer;
    CALayer *cloud2Layer;
    CALayer *tumbleweedLogo;

}

@synthesize scrollView = _scrollView;
@synthesize containerView, textContainer, text1, text2, text3;


#pragma mark -

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

- (void) handleSingleTap:(UIGestureRecognizer *)sender
{
    //NSLog(@"just got tapped");
    float loc = self.scrollView.contentOffset.y;
    //self.scrollView.contentOffset = CGPointMake(0, loc+10);
    [self.scrollView setContentOffset:CGPointMake(0, loc+50) animated:YES];
}


-(void) renderParallax
{
    //MAP LAYER PARALLAX SPEEDS
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    
    CGPoint mapCenter = self.scrollView.center;
    //float offset = self.scrollView.contentOffset.y - mapCenter.y;
    float offset =  - self.scrollView.contentOffset.y;
    float middleWidth = [[UIScreen mainScreen] bounds].size.height/2;
    
    tumbleweedLogo.transform = CATransform3DMakeRotation(offset*-M_PI_4*.2, 0, 0, 1);

    //-sky position- CALayer - fix the hardcoded offset here
    //float textCoefficient = 5.0;
    //CGPoint cloud1Center = cloud1Layer.position;

    CGPoint textCenter = CGPointMake(middleWidth, mapCenter.y - (pow(offset,7/3)) );
    [tWLogoLayer setPosition:textCenter];

    
    //-sky position- CALayer - fix the hardcoded offset here
    float cloud1Coefficient = 1.8;
    //CGPoint cloud1Center = cloud1Layer.position;
    CGPoint cloud1Center = CGPointMake(middleWidth, mapCenter.y +(offset * cloud1Coefficient));
    [cloud1Layer setPosition:cloud1Center];
    
    //--> layer1C position
    //float cloud2Coefficient = 2.5;
    CGPoint cloud2Center = CGPointMake(middleWidth, mapCenter.y +(offset * cloud2Layer.speed));
    [cloud2Layer setPosition:cloud2Center];
    
    [CATransaction commit];
    
    //NSLog(@"rendering parallax");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Paged";
    
    tWLogoLayer = [CALayer layer];
    tWLogoLayer.zPosition = 0;
    tWLogoLayer.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    [containerView.layer addSublayer:tWLogoLayer];
    cloud1Layer = [CALayer layer];
    cloud1Layer.zPosition = 1;
    cloud1Layer.frame = tWLogoLayer.frame;
    [containerView.layer addSublayer:cloud1Layer];
    cloud2Layer = [CALayer layer];
    cloud2Layer.zPosition = 2;
    cloud2Layer.speed = 2.5;
    cloud2Layer.frame = tWLogoLayer.frame; //CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);;
    [containerView.layer addSublayer:cloud2Layer];
    textContainer.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width*1.5);
    
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
    
    for (int i = 1; i<=12; i++)
    {
        CALayer *cloud1 = [CALayer layer];
        UIImage *cloud1img = [UIImage imageNamed:[NSString stringWithFormat:@"cloud_%02d.png", i]];
        cloud1.bounds = CGRectMake(0, 0, cloud1img.size.width/2, cloud1img.size.height/2);
        cloud1.position = CGPointMake(0, [self getRandomNumberBetween:0 to:[[UIScreen mainScreen] bounds].size.width *2 ]);
        CGImageRef cloud1imgref = [cloud1img CGImage];
        [cloud1 setContents:(__bridge id)cloud1imgref];
        //cloud1.name = @"cloud";
        if (i%2)[cloud1Layer addSublayer:cloud1];
        else [cloud2Layer addSublayer:cloud1];
        
        CABasicAnimation *cloud1anim;
        cloud1anim = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        cloud1anim.fromValue = [NSNumber numberWithInt:[self getRandomNumberBetween:0 to:[[UIScreen mainScreen] bounds].size.height -100]];
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

    
    [UIView animateWithDuration:10.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        //[self.scrollView setContentOffset:CGPointMake(0, canvas_h) animated:NO];
        //self.scrollView.contentOffset = CGPointMake(0, canvas_h);
        
    } completion:^(BOOL finished) {
        //
    }];
     
    UITapGestureRecognizer *tapHandler = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
    tapHandler.numberOfTapsRequired = 1;
    [tapHandler setDelegate:self];
    [self.scrollView addGestureRecognizer:tapHandler];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the content size of the scroll view
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    //CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, canvas_h);
    //bgImage.bounds = CGRectMake(0, 0, bgImage.image.size.width, bgImage.image.size.height);
    CALayer *skyLayer = [CALayer layer];
    UIImage *skybg = [UIImage imageNamed:@"intro_sky_texture.jpg"];
    skyLayer.bounds = CGRectMake(0, 0, skybg.size.width, skybg.size.height);
    skyLayer.position = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, canvas_h/2);
    skyLayer.contents = (__bridge id)(skybg.CGImage);
    [self.scrollView.layer insertSublayer:skyLayer atIndex:0];

    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.scrollView = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages which are now on screen
    [self renderParallax];
    
    if (scrollView.contentOffset.y >= canvas_h - [[UIScreen mainScreen] bounds].size.width)
    {
        NSLog(@"over 960");
        [self dismissViewControllerAnimated:NO completion:^{}];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
    }
    else if (scrollView.contentOffset.y >= [[UIScreen mainScreen] bounds].size.width)
    {
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            //[self.scrollView setContentOffset:CGPointMake(0, canvas_h) animated:YES];
            //text1.center = CGPointZero;
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                //text2.center = CGPointZero;
                
            } completion:^(BOOL finished) {
                //
            }];
        }];
    }
    
}
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= canvas_h - [[UIScreen mainScreen] bounds].size.width)
    {
        [self dismissViewControllerAnimated:NO completion:^{}];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
    }
}



@end
