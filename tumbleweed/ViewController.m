//
//  ViewController.m
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize scrollView, map, avatar;

//-- scrolling handlers

- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    NSLog(@"scroll view x %f", [sView contentOffset].x);
    NSLog(@"scroll view y %f", [sView contentOffset].y);
    
    [self renderJane];
    
}

//-- end scrolling handlers

- (void) renderJane
{
    double avatar_offset = 200;
    
    NSLog(@"rendering Jane");
    UIImage *img = [UIImage imageNamed:@"jane.png"];
    CGRect imageFrame = CGRectMake(0, 0, 200, 300);
    if(!avatar){
        avatar = [[UIImageView alloc] initWithFrame:imageFrame];
        [map addSubview:avatar];
    }
    CGPoint center = CGPointMake([scrollView contentOffset].x + avatar_offset, 175);
    [avatar setCenter:center];
    [avatar setImage:img];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];        
    UIImage *image = [UIImage imageNamed:@"map.jpg"];
    
    CGRect imageFrame = CGRectMake(0, 0, 5782, 320);
    
    map = [[UIImageView alloc] initWithFrame:imageFrame];
    [map setImage:image];
    
    CGSize screenSize = CGSizeMake(5782, 320.0);
    scrollView.contentSize = screenSize;
                         
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    [scrollView addSubview:map];
    [scrollView setDelegate:self];
   
    
   scrollView.bounces = NO;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
