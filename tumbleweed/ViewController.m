//
//  ViewController.m
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize scrollView, map;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGSize screenSize = CGSizeMake(10000.0, 320.0);
    
    UIImage *image = [UIImage imageNamed:@"map.jpg"];
    map = [[UIImageView alloc] initWithImage:image];
        
    
    
    scrollView.contentSize = screenSize;
                         
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [scrollView addSubview:map];
    
   // scrollView.minimumZoomScale = 0.2;
   // scrollView.maximumZoomScale = 4.0;
    
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
