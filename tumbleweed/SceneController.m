//
//  SceneController.m
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "SceneController.h"
#import "CheckInController.h"
#import "Foursquare.h"

#import "NSDictionary_JSONExtensions.h"

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@implementation SceneController

@synthesize venueScrollView, venueDetailNib, rewardScrollView, rewardView, locationManager, moviePlayer, allVenues, lockedRewards;

//-- Event Handlers
- (IBAction)dismissModal:(id)sender
{
    //NSLog(@"dismissing modal");
    [self dismissModalViewControllerAnimated:YES];
}

- (id) initWithCategoryId:(NSString *)category
{
    self = [super init];
    // Did the superclass's designated initializer succeed?
    if (self) {
        categoryId = category;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        allVenues = [[NSMutableDictionary alloc] init];
        lockedRewards = TRUE;
        NSLog(@"are the rewards locked? %@", lockedRewards ? @"YES": @"NO");
        
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender {
    NSString *viewId = [NSString stringWithFormat:@"%d", [sender.view hash]];    ;
    NSDictionary *venueDetails = [allVenues objectForKey:viewId];
    NSString *venueName = [venueDetails objectForKey:@"name"];
    NSString *venueId = [venueDetails objectForKey:@"id"];
    NSLog(@"venue name %@ : id %@", venueName, venueId);
    CheckInController *checkIn = [[CheckInController alloc] initWithSenderId:self];
    [checkIn setVenueDetails:venueDetails];
    [self presentModalViewController:checkIn animated:YES];
}



- (void) processVenues: (NSArray*) items
{
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
    NSLog(@"processing foursquare venues");
    
    [[NSBundle mainBundle] loadNibNamed:@"ListItemScrollView" owner:self options:nil];

    float nibwidth = venueDetailNib.frame.size.width;
    float nibheight = venueDetailNib.frame.size.height;
    int padding = 2;
    
    float scrollWidth = (nibwidth + padding) * [items count];
    CGSize contentSize = CGSizeMake(scrollWidth, venueScrollView.contentSize.height);
    
    NSLog(@"screen width %f", scrollWidth);
    
    UIView *venueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollWidth, 800)];
    
    [venueScrollView addSubview:venueView];
    
    // let the scrollview know how big the content size is
    venueScrollView.contentSize = contentSize;
    
    int offset = 0;
    for (int i = 0; i < [items count]; i++) {
        NSDictionary *ven = [items objectAtIndex:i];
        NSString *name = [ven objectForKey:@"name"];
        NSString *address = [[ven objectForKey: @"location"]  objectForKey:@"address"];
        float distance = [[[ven objectForKey: @"location"] objectForKey: @"distance"] floatValue] *.00062;
        int hereCount = [[[ven objectForKey: @"hereNow"] objectForKey:@"count"] intValue]; 

        [[NSBundle mainBundle] loadNibNamed:@"ListItemScrollView" owner:self options:nil];
       
        UILabel *nameLabel = (UILabel *)[venueDetailNib viewWithTag:1];
        UILabel *addressLabel = (UILabel *)[venueDetailNib viewWithTag:2];
        UILabel *distanceLabel = (UILabel *)[venueDetailNib viewWithTag:3];
        UILabel *peopleLabel = (UILabel *)[venueDetailNib viewWithTag:4];
        UIImageView *icon = (UIImageView *) [venueDetailNib viewWithTag:5];
        
        [nameLabel setText:name];
        [addressLabel setText:address];
        [distanceLabel setText:[NSString stringWithFormat:@"%.1f mi", distance]];
        [peopleLabel setText:[NSString stringWithFormat:@"%d people here now", hereCount]];

        //[icon setImage:[UIImage imageNamed:@"bubble5"]];
        NSString *iconURL = [[[ven objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"];
        [icon setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconURL]]]];
                        
        offset = (int)(nibwidth + padding) * i; 
        CGPoint nibCenter = CGPointMake(offset + (nibwidth / 2), nibheight/2);
        [venueDetailNib setCenter:nibCenter];
        
        // push venue details into a dictionary for future lookup
        NSString *viewId = [NSString stringWithFormat:@"%d", [venueDetailNib hash]];
        [allVenues setObject:ven forKey:viewId];
        
        // capture events
        UITapGestureRecognizer *tapHandler = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
        [venueDetailNib addGestureRecognizer:tapHandler];
        
        // add it to the content view
        [venueView addSubview:venueDetailNib];

    }
    
}

- (void) processRewards
{
    NSLog(@"processing rewards");
    int rewardsForScene = 1;
    float scrollWidth = 500;
    CGSize rewardSize = CGSizeMake(scrollWidth, rewardScrollView.contentSize.height);    
    rewardScrollView.contentSize = rewardSize;
    
    //int offset = 0;
    for (int i = 0; i < rewardsForScene; i++) {        
        //NSLog(@"processing rewards for loop");
        /*
        
        UIImageView *rewardicon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
        float nibwidth = 100;
        float nibheight = 100; 
        int padding = 2;
        offset = (int)(nibwidth + padding) * i; 
        CGPoint rewardCenter = CGPointMake(offset + (nibwidth / 2), nibheight/2);
        [rewardicon setFrame:CGRectMake(0, 0, 100, 100)];
        [rewardicon setCenter:rewardCenter];
        [rewardView addSubview:rewardicon];
         */
        
        
    }

}

- (void) animateRewards
{
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(0.f, 0.f, 50.f, 50.f);
    [button1 setTitle:@"video 1" 
             forState:(UIControlState)UIControlStateNormal];
    [button1 addTarget:self
                action:@selector(launchVideoPlayer:) 
      forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    //[button1 setEnabled:NO];
    rewardView.userInteractionEnabled = YES; // <--- this has to be set to YES
    [rewardView addSubview:button1];
    
    [UIView animateWithDuration:1.0 animations:^{
        venueScrollView.alpha = 0.0;
        UILabel *venuename = (UILabel *) [self.view viewWithTag:1];
        [venuename setText:@"you checked in here"];
        //UIView *rewardsBar = (UIView *) [self.view viewWithTag:3];
        //[rewardsBar setAlpha:0.0];
        //[rewardsBar removeFromSuperview];
        rewardBar.alpha = 0.0;
        
    }];
    [UIView animateWithDuration:1.0
                          delay:1.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGPoint rewardorigin = CGPointMake(rewardScrollView.center.x, 135);     
                         rewardScrollView.center = rewardorigin;
                     } 
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                         lockedRewards = FALSE;
                     }];
    
}

- (void) launchVideoPlayer:(MPMoviePlayerViewController *)mplayer
{
    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"videoTest1"
                                                          ofType:@"mp4"];
    if (moviePath) {
        NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
        moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    }
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
}

#pragma mark - Required CoreLocation methods


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"location update is called");
    [locationManager stopUpdatingLocation];
    
    NSString *lat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
    //add logic so that if you haven't moved very far you'll get the most recently requested venues array    
    ASIHTTPRequest *request = [Foursquare searchVenuesNearByLatitude:lat longitude:lon categoryId:categoryId];
    [request setDelegate:self];
    [request startAsynchronous];    
     
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location error is called");

}


#pragma mark - Required ASIHTTP Asynchronous request methods 


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    NSError *err;
    if ([[request.userInfo valueForKey:@"operation"] isEqualToString:@"searchVenues"]) {
        NSLog(@"searchVenues requestFinished");        
        NSDictionary *venuesDict = [NSDictionary dictionaryWithJSONString:responseString error:&err];
        [self processVenues:[[[[venuesDict objectForKey:@"response"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"]];
    }    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error! %@", error);
    // Must add graceful network error like a pop-up saying, get internet!
}


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];
    [self processRewards];
    
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
    NSLog(@"are the rewards locked? %@", lockedRewards ? @"YES": @"NO");
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"unlocked"]){
        NSLog(@"gas station is unlocked");
    }
     
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
