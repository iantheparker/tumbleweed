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

@synthesize venueScrollView, venueDetailNib, movieThumbnailImageView, locationManager, moviePlayer, allVenues, scene, mvFoursquare, pinsLoaded, mapButton;



- (id) initWithScene:(Scene *) scn
{
    self = [super init];
    // Did the superclass's designated initializer succeed?
    if (self) {
        scene = scn;      
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // assign this to scene.recentSearches when ready
        allVenues = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark Event Handlers


- (IBAction)dismissModal:(id)sender
{
    //NSLog(@"dismissing modal");
    [self dismissModalViewControllerAnimated:YES];

}

- (IBAction) mapLaunch
{
    if ([mvFoursquare isHidden]) {
        [mvFoursquare setHidden:NO];
        [self.view bringSubviewToFront:mvFoursquare];
        mapButton.selected = YES;
    }
    else {
        [mvFoursquare setHidden:YES];
        [mapButton setSelected:NO];
        
    }
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
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (int i = 0; i < [items count]; i++) {
        NSDictionary *ven = [items objectAtIndex:i];
        NSString *name = [ven objectForKey:@"name"];
        NSString *address = [[ven objectForKey: @"location"]  objectForKey:@"address"];
        float distance = [[[ven objectForKey: @"location"] objectForKey: @"distance"] floatValue] *.00062;
        int hereCount = [[[ven objectForKey: @"hereNow"] objectForKey:@"count"] intValue]; 
        CGFloat latitude = [[[ven objectForKey: @"location"] objectForKey: @"lat"] floatValue];
		CGFloat longitude = [[[ven objectForKey: @"location"] objectForKey: @"lng"] floatValue];
        NSLog(@"lat%f, long%f", latitude, longitude);

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
        
        // create and initialise the annotation
		FoursquareAnnotation *foursquareAnnotation = [[FoursquareAnnotation alloc] init];
		// create the map region for the coordinate
		MKCoordinateRegion region = { { latitude , longitude } , { 0.01f , 0.01f } };
		
		// set all properties with the necessary details
		[foursquareAnnotation setCoordinate: region.center];
		[foursquareAnnotation setTitle: name];
		[foursquareAnnotation setSubtitle: address];
		
		// add the annotation object to the container
		[annotations addObject: foursquareAnnotation];

    }
    [mvFoursquare addAnnotations: annotations];
    
}

- (void) processRewards
{
    //write logic that handles case when it's been unlocked
    movieThumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 235, 447, 251)];
    [movieThumbnailImageView setImage:scene.movieThumbnail];
    [self.view addSubview:movieThumbnailImageView];

}

- (void) animateRewards
{
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(100.f, 0.f, 50.f, 50.f);
    [button1 setTitle:@"video 1" 
             forState:(UIControlState)UIControlStateNormal];
    [button1 addTarget:self
                action:@selector(launchVideoPlayer) 
      forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    //[button1 setEnabled:NO];
    movieThumbnailImageView.userInteractionEnabled = YES; // <--- this has to be set to YES
    [movieThumbnailImageView addSubview:button1];
    
    [UIView animateWithDuration:1.0 animations:^{
        venueScrollView.alpha = 0.0;
        UILabel *venuename = (UILabel *) [self.view viewWithTag:1];
        [venuename setText:@"you checked in here"];
        rewardBar.alpha = 0.0;
        
    }];
    [UIView animateWithDuration:1.0
                          delay:1.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGPoint neworigin = CGPointMake(movieThumbnailImageView.center.x, 220);     
                         movieThumbnailImageView.center = neworigin;
                     } 
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                         scene.unlocked = TRUE;
                     }];
    
}

- (void) launchVideoPlayer
{
     moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:scene.moviePath];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
}

#pragma mark - Required CoreLocation methods


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [locationManager stopUpdatingLocation];
    
    // How many seconds ago was this new location created?
    NSTimeInterval t = [[newLocation timestamp] timeIntervalSinceNow];
    // CLLocationManagers will return the last found location of the
    // device first, you don't want that data in this case.
    // If this location was made more than 2 minutes ago, ignore it.

    NSLog(@"nstimeinterval %f", t);
    CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
    if (meters < 100 && scene.recentSearchVenueResults) {
        [self processVenues:[[[[scene.recentSearchVenueResults objectForKey:@"response"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"]];
        NSLog(@"using recentSearchVenue instead of making a new call");
        return; 
    }
    
    NSString *lat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
    ASIHTTPRequest *request = [Foursquare searchVenuesNearByLatitude:lat longitude:lon categoryId:scene.categoryId];
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
        scene.recentSearchVenueResults = venuesDict;
        [self processVenues:[[[[venuesDict objectForKey:@"response"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"]];
    }    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error! %@", error);
    // Must add graceful network error like a pop-up saying, get internet!
}

#pragma mark - Map View Delegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	// didUpdateUserLocation tend to repeat at times
	// so to not get a duplicated pin(s)
	if ([self isPinsLoaded])
	{
		//return;
	}
	
	[self setPinsLoaded: YES];
	
	
	// set the mapView's region the same as the user's coordinate
	CLLocationCoordinate2D userCoords = [userLocation coordinate];
	// with a fixed zoom level with an animation
	MKCoordinateRegion region = { { userCoords.latitude , userCoords.longitude }, { 0.009f , 0.009f } };
	[mapView setRegion: region animated: YES];
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
    NSLog(@"is the scene unlocked? %@", scene.unlocked ? @"YES": @"NO");
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"unlocked"]){
        NSLog(@"%@ is unlocked", scene.name);
    }
     
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
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
