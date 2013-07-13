//
//  PagedScrollViewController.m
//  ScrollViews
//
//  Created by Matt Galloway on 01/03/2012.
//  Copyright (c) 2012 Swipe Stack Ltd. All rights reserved.
//

#import "PagedScrollViewController.h"
#import <QuartzCore/QuartzCore.h>


#define canvas_h 960


@implementation PagedScrollViewController{
@private
    CALayer *sunLayer;
    CALayer *cloud1Layer;
    CALayer *cloud2Layer;

}

@synthesize scrollView = _scrollView;
@synthesize bgImage, containerView;


#pragma mark -

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

-(void) renderParallax
{
    //MAP LAYER PARALLAX SPEEDS
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGPoint mapCenter = self.scrollView.center;
    float janeOffset = mapCenter.y - self.scrollView.contentOffset.y;
    
    //-sky position- CALayer - fix the hardcoded offset here
    float skyCoefficient = 1.5;
    CGPoint cloud1Center = cloud1Layer.position;
    cloud1Center = CGPointMake(cloud1Center.x, floorf((janeOffset * skyCoefficient)-mapCenter.y));
    [cloud1Layer setPosition:cloud1Center];
    
    //--> layer1C position
    float cloud2Coefficient = 0.5;
    CGPoint cloud2Center = cloud2Layer.position;
    cloud2Center = CGPointMake(cloud2Center.x, floorf((janeOffset * cloud2Coefficient)-mapCenter.y));
    [cloud2Layer setPosition:cloud2Center];
    /*
    //--> layer1B position
    float layer1BCoefficient = .04;
    CGPoint layer1BPos = CGPointMake(floorf(mapCenter.x + (janeOffset * layer1BCoefficient)), map1BCA.position.y);
    [map1BCA setPosition:layer1BPos];
    
    //--> layer2 position
    float layer2Coefficient = .03;
    CGPoint layer2Pos = CGPointMake(mapCenter.x + (janeOffset * layer2Coefficient), map2CA.position.y);
    [map2CA setPosition:layer2Pos];
    
    //--> top layer position
    float toplayerCoefficient = 1.5;
    CGPoint toplayerPos = CGPointMake(floorf(avatar_offset+mapCenter.x + (janeOffset * toplayerCoefficient)), map4CA.position.y);
    [map4CA setPosition:toplayerPos];
    
    //--> top layer buttons
    [buttonContainer setCenter:toplayerPos];
    */
    [CATransaction commit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Paged";
    
    sunLayer = [CALayer layer];
    sunLayer.zPosition = 0;
    [containerView.layer addSublayer:sunLayer];
    cloud1Layer = [CALayer layer];
    cloud1Layer.zPosition = 1;
    [containerView.layer addSublayer:cloud1Layer];
    cloud2Layer = [CALayer layer];
    cloud2Layer.zPosition = 2;
    [containerView.layer addSublayer:cloud2Layer];
    
    
    for (int i = 1; i<=10; i++)
    {
        CALayer *cloud1 = [CALayer layer];
        UIImage *cloud1img = [UIImage imageNamed:[NSString stringWithFormat:@"cloud_%02d.png", i]];
        cloud1.bounds = CGRectMake(0, 0, cloud1img.size.width/2, cloud1img.size.height/2);
        cloud1.position = CGPointMake(0, [self getRandomNumberBetween:0 to:[[UIScreen mainScreen] bounds].size.width ]);
        CGImageRef cloud1imgref = [cloud1img CGImage];
        [cloud1 setContents:(__bridge id)cloud1imgref];
        //cloud1.name = @"cloud";
        if (i%2)[cloud1Layer addSublayer:cloud1];
        else [cloud2Layer addSublayer:cloud1];
        
        CABasicAnimation *cloud1anim;
        cloud1anim = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        cloud1anim.fromValue = [NSNumber numberWithInt:[self getRandomNumberBetween:0 to:[[UIScreen mainScreen] bounds].size.height ]];
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
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the content size of the scroll view
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    //CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, canvas_h);
    //bgImage.bounds = CGRectMake(0, 0, bgImage.image.size.width, bgImage.image.size.height);
    self.scrollView.layer.contents = (__bridge id)(bgImage.image.CGImage);

    
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
    //bgImage.center = CGPointMake(bgImage.center.x, -scrollView.contentOffset.y);
    [self renderParallax];
    
    if (scrollView.contentOffset.y >= canvas_h - [[UIScreen mainScreen] bounds].size.width)
    {
        NSLog(@"over 960");
        [self dismissViewControllerAnimated:NO completion:^{}];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
    }
    
}



@end
