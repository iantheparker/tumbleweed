//
//  ViewController.m
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize scrollView, map, avatar, sprites, walkingForward;

- (void) initSprites
{
    if(sprites == nil){
        sprites = [[NSMutableArray alloc] initWithObjects:
                   //[UIImage imageNamed:@"JANE_walkcycle0.png"],
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
    //int z = 7;
    int z = 6;
    int c = (int) position;
    int r = (c + (y * z)) % (y * z) / y;
    return [sprites objectAtIndex:r];
}


//-- scrolling handlers

- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    if (lastContentOffset > scrollView.contentOffset.x)
        walkingForward = NO;
    else if (lastContentOffset < scrollView.contentOffset.x) 
        walkingForward = YES;    
    lastContentOffset = scrollView.contentOffset.x;
    NSLog(walkingForward ? @"Yes" : @"No");
    [self renderJane:walkingForward];


}

//-- end scrolling handlers
- (void) renderJane: (BOOL) direction
{
    double avatar_offset = 200;

    UIImage *img = [self selectAvatarImage:[scrollView contentOffset].x];
    CGRect imageFrame = CGRectMake(0, 0, 150, 200);
    
    if(!avatar){
        avatar = [[UIImageView alloc] initWithFrame:imageFrame];
        [map addSubview:avatar];
    }
    
    CGPoint center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
    CGPoint buttonOffset = CGPointMake(130, 20);
    [avatar setCenter:center];
    if (walkingForward){
        [avatar setImage:img];

    }else{
        UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage scale:1.0 orientation: UIImageOrientationUpMirrored];
        [avatar setImage:flippedImage];
    }
    [avatar addSubview:gasStationButton];
    [gasStationButton setCenter:buttonOffset];
    
}

//location detail handlers

- (IBAction)gasStationPressed:(UIButton *)sender{
    NSLog(@"pressed");
}


//end location detail handlers


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
    walkingForward = YES;

    UIImage *maplayer1 = [UIImage imageNamed:@"map.jpg"];
    
    CGRect mapFrame = CGRectMake(0, 0, 5782, 320);
    
    map = [[UIImageView alloc] initWithFrame:mapFrame];
    [map setImage:maplayer1];
    
    CGSize screenSize = CGSizeMake(5782, 320.0);
    scrollView.contentSize = screenSize;
                         
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    
    //gasStationButton = [[UIButton alloc] init]; 
    
    //[gasStationButton setTitle:@"word!" forState: UIControlStateNormal];
    //UIImage *gasBubble = [UIImage imageNamed:@"bubble5.png"];
    //[gasStationButton setBackgroundImage :gasBubble forState: UIControlStateNormal];
    
    
    [scrollView addSubview:map];
    [scrollView setDelegate:self];
    
    
    //[map addSubview:gasStationBubble];
    //[map addSubview:gasStationButton];
    [self renderJane:walkingForward];
    
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
