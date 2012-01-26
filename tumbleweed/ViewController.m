//
//  ViewController.m
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "ViewController.h"
#import "SceneController.h"
#import "FoursquareAuthViewController.h"

@implementation ViewController

@synthesize scrollView, map, avatar, sprites, gasStationButton, walkingForward;

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
        [scrollView addSubview:avatar];
    }
    
    CGPoint center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
    
    [avatar setCenter:center];
    
    if (walkingForward) {
        [avatar setImage:img];

    } else {
        UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage scale:1.0 orientation: UIImageOrientationUpMirrored];
        [avatar setImage:flippedImage];
    }
    
    // adjust thought bubble position
    CGPoint buttonOffset = CGPointMake(center.x + 50, center.y - 80);
    [gasStationButton setCenter:buttonOffset];
    
}

// event handlers

- (IBAction) foursquareConnect:(UIButton *)sender
{
    NSLog(@"pressed");
    FoursquareAuthViewController *fsq = [[FoursquareAuthViewController alloc] init];
    [self presentModalViewController:fsq animated:YES];    

}



- (IBAction)gasStationPressed:(UIButton *)sender
{    
    NSLog(@"pressed");
    SceneController *sc = [[SceneController alloc] init];
    [self presentModalViewController:sc animated:YES];
}


// event handlers


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
    
    CGSize screenSize = CGSizeMake(5782, 320.0);
    scrollView.contentSize = screenSize;
    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    [scrollView setDelegate:self];
    [scrollView addSubview:gasStationButton];

/**
    UIImage *maplayer1 = [UIImage imageNamed:@"map.jpg"];
    CGRect mapFrame = CGRectMake(0, 0, 5782, 320);
    
    map = [[UIImageView alloc] initWithFrame:mapFrame];
    [map setImage:maplayer1];
                         
    [scrollView addSubview:map];
    
    */
    
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
    [self renderJane:walkingForward];
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
