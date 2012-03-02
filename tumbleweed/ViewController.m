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

@interface ViewController ()
@property (nonatomic, retain) Tumbleweed *weed;
@end

@implementation ViewController

@synthesize scrollView, map, avatar, sprites, gasStationButton, foursquareConnectButton, walkingForward, weed;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initScenes];
    }
    return self;
}

- (void) initScenes
{
    //Gas Station
    gasStation = [[Scene alloc] init];
    gasStation.name = @"gasStation";
    gasStation.categoryId = GAS_TRAVEL_catId;
    gasStation.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                  ofType:@"mp4"]];
    gasStation.movieThumbnail = [UIImage imageNamed:@"Gas_Station_thumbnail.jpg"];
    //gasStation.movieThumbnail = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"Gas_Station_thumbnail" ofType:@"jpg"]];
    gasStation.posterArt = [UIImage imageNamed:@"bubble5.png"];
    
    //Deal Scene
    deal  = [[Scene alloc] init];
    deal.name = @"deal";
    deal.categoryId = DEAL_catId;
    deal.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                            ofType:@"mp4"]];
    deal.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    deal.posterArt = [UIImage imageNamed:@"bubble5.png"];
    
    //Bar Scene
    bar = [[Scene alloc] init];
    bar.name = @"bar";
    bar.categoryId = NIGHTLIFE_catId;
    bar.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                           ofType:@"mp4"]];
    bar.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    bar.posterArt = [UIImage imageNamed:@"bubble5.png"];
    
    //Riverbed Scene 1
    riverBed1 = [[Scene alloc] init];
    riverBed1.name = @"river";
    riverBed1.categoryId = OUTDOORS_catId;
    riverBed1.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                 ofType:@"mp4"]];
    riverBed1.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    riverBed1.posterArt = [UIImage imageNamed:@"bubble5.png"];
    
    //Riverbed Scene 2
    riverBed2 = [[Scene alloc] init];
    riverBed2.name = @"deal";
    riverBed2.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                 ofType:@"mp4"]];
    riverBed2.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    riverBed2.posterArt = [UIImage imageNamed:@"bubble5.png"];
    
    //Desert Chase
    desertChase = [[Scene alloc] init];
    desertChase.name = @"desertChase";
    desertChase.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                   ofType:@"mp4"]];
    desertChase.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    desertChase.posterArt = [UIImage imageNamed:@"bubble5.png"];
    
    //Desert Lynch
    desertLynch = [[Scene alloc] init];
    desertLynch.name = @"desertLynch";
    desertLynch.categoryId = OUTDOORS_catId;
    desertLynch.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                   ofType:@"mp4"]];
    desertLynch.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    desertLynch.posterArt = [UIImage imageNamed:@"bubble5.png"];
    
    //Campfire Scene
    campFire = [[Scene alloc] init];
    campFire.name = @"deal";
    campFire.moviePath = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                                                ofType:@"mp4"]];
    campFire.movieThumbnail = [UIImage imageNamed:@"bubble5.png"];
    campFire.posterArt = [UIImage imageNamed:@"bubble5.png"];
}

- (Tumbleweed *)weed
{
    if (!weed) weed = [[Tumbleweed alloc] init];
    return weed;
}

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

- (void) saveAvatarPosition
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:scrollView.contentOffset.x forKey:@"scroll_view_position"];
    [defaults setBool:walkingForward forKey:@"walkingForward"];
    NSLog(@"saving Jane's position");
}

#pragma mark scrollView handlers

- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    if (lastContentOffset > scrollView.contentOffset.x)
        walkingForward = NO;
    else if (lastContentOffset < scrollView.contentOffset.x) 
        walkingForward = YES;    
    lastContentOffset = scrollView.contentOffset.x;
    [self renderJane:walkingForward];
}

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
    
    if (direction) {
        [avatar setImage:img];

    } else {
        UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage scale:1.0 orientation: UIImageOrientationUpMirrored];
        [avatar setImage:flippedImage];
    }
    
    // adjust thought bubble position
    //CGPoint buttonOffset = CGPointMake(center.x + 50, center.y - 80);
    //[gasStationButton setCenter:buttonOffset];
    
}

#pragma mark button handlers


- (IBAction) foursquareConnect:(UIButton *)sender
{
    NSLog(@"pressed");
    FoursquareAuthViewController *fsq = [[FoursquareAuthViewController alloc] init];
    [self presentViewController:fsq animated:YES completion:NULL];  

}


- (IBAction)gasStationPressed:(UIButton *)sender
{    
    //NSLog(@"pressed");
    SceneController *gasStationScene = [[SceneController alloc] initWithScene:gasStation];
    [self presentModalViewController:gasStationScene animated:YES];
}

- (IBAction)dealPressed:(UIButton *)sender
{
    //NSLog(@"pressed");
    SceneController *dealScene = [[SceneController alloc] initWithScene:deal];
    [self presentModalViewController:dealScene animated:YES];
}

- (IBAction) barPressed:(UIButton *)sender
{
    //NSLog(@"pressed");
    SceneController *barScene = [[SceneController alloc] initWithScene:bar];
    [self presentModalViewController:barScene animated:YES];
}

- (IBAction)riverbedPressed:(UIButton *)sender
{
    SceneController *riverbedScene = [[SceneController alloc] initWithScene:riverBed1];
    [self presentModalViewController:riverbedScene animated:YES];
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
    //[scrollView addSubview:gasStationButton];

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
    CGPoint center = CGPointMake([[NSUserDefaults standardUserDefaults] floatForKey:@"scroll_view_position"], 0);
    scrollView.contentOffset = center;
    [self renderJane:[[NSUserDefaults standardUserDefaults] boolForKey:@"walkingForward"]];
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"]){
        //NSLog(@"access token exists");
        foursquareConnectButton.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self saveAvatarPosition];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
