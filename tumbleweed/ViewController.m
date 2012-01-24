//
//  ViewController.m
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize scrollView, map, avatar, sprites;

- (void) initSprites
{
    if(sprites == nil){
        sprites = [[NSMutableArray alloc] initWithObjects:
                   [UIImage imageNamed:@"JANE_walkcycle0.png"],
                   [UIImage imageNamed:@"JANE_walkcycle1.png"],
                   [UIImage imageNamed:@"JANE_walkcycle2.png"],
                   [UIImage imageNamed:@"JANE_walkcycle3.png"],
                   [UIImage imageNamed:@"JANE_walkcycle4.png"],
                   [UIImage imageNamed:@"JANE_walkcycle5.png"],
                   [UIImage imageNamed:@"JANE_walkcycle6.png"],
                   nil];
    }
    
}

/**
 * x = canvas_width
 * y = frame_size
 * z = image count
 * c = current position
 * r = result (image index out of z)
 */
-(UIImage *) selectAvatarImage:(float) position
{
    int y = 20;
    int z = 7;
    int c = (int) position;
    int r = (c + (y * z)) % (y * z) / y;
    return [sprites objectAtIndex:r];
}


//-- scrolling handlers

- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    [self renderJane];
}

//-- end scrolling handlers

- (void) renderJane
{
    double avatar_offset = 200;

    UIImage *img = [self selectAvatarImage:[scrollView contentOffset].x];
    CGRect imageFrame = CGRectMake(0, 0, 150, 200);
    
    if(!avatar){
        avatar = [[UIImageView alloc] initWithFrame:imageFrame];
        [map addSubview:avatar];
    }
    
    CGPoint center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
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
    [self initSprites];
    
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
    [self renderJane];
    
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
