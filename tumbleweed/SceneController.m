//
//  SceneController.m
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "SceneController.h"
#import "CheckInController.h"
//#import "Foursquare.h"

//#import "NSDictionary_JSONExtensions.h"

//#import "ASIFormDataRequest.h"
//#import "ASIHTTPRequest.h"


@implementation SceneController

@synthesize checkinScrollView, venueScrollView, venueDetailNib, movieThumbnailImageView, locationManager, moviePlayer, allVenues, scene, mvFoursquare, pinsLoaded, userCurrentLocation, checkinView, sceneTitle, checkInIntructions, refreshButton, activityIndicator, leftScroll, rightScroll;



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
    [request clearDelegatesAndCancel];
    [locationManager stopUpdatingLocation];
    [self dismissModalViewControllerAnimated:YES];
}



- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender {
    NSString *viewId = [NSString stringWithFormat:@"%d", [sender.view hash]];    ;
    NSDictionary *venueDetails = [allVenues objectForKey:viewId];
    NSString *venueName = [venueDetails objectForKey:@"name"];
    NSString *venueId = [venueDetails objectForKey:@"id"];
    NSLog(@"venue name %@ : id %@", venueName, venueId);
    //CheckInController *checkIn = [[CheckInController alloc] initWithSenderId:self];
    //[checkIn setVenueDetails:venueDetails];
    //[self presentModalViewController:checkIn animated:YES];
    
    //[mvFoursquare selectAnnotation:annotation animated:YES];
}

//set the nib width to venuescrollview paging width

- (void) processVenues: (NSArray*) items
{
    [activityIndicator stopAnimating];
    //[activityIndicator removeFromSuperview];
    NSLog(@"processing foursquare venues");
    
    if ([items count] == 0) {
        UILabel *nameLabel = (UILabel *)[venueDetailNib viewWithTag:1];
        [nameLabel setFont:[UIFont fontWithName:@"Rockwell" size:24]];
        [nameLabel setText:@"Nothing around. Try later."];
        UIColor *redText = [UIColor colorWithRed:212.0/255.0 green:83.0/255.0 blue:88.0/255.0 alpha:1.0];
        [nameLabel setTextColor:redText];
        return;
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"ListItemScrollView" owner:self options:nil];

    float nibwidth = venueDetailNib.frame.size.width;
    float nibheight = venueDetailNib.frame.size.height;
    int padding = 2;
    
    float scrollWidth = (nibwidth + padding) * [items count];
    CGSize contentSize = CGSizeMake(scrollWidth, venueScrollView.contentSize.height);
    
    NSLog(@"screen width %f", scrollWidth);
    
    venueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollWidth, 800)];
    
    [venueScrollView addSubview:venueView];
    
    // let the scrollview know how big the content size is
    venueScrollView.contentSize = contentSize;
    
    allVenues = nil;
    
    int offset = 0;
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (int i = 0; i < [items count]; i++) {
        NSDictionary *ven = [items objectAtIndex:i];
        NSString *vID = [ven objectForKey:@"id"];
        NSString *name = [ven objectForKey:@"name"];
        NSString *address = [[ven objectForKey: @"location"]  objectForKey:@"address"];
        //float distance = [[[ven objectForKey: @"location"] objectForKey: @"distance"] floatValue] *.00062;
        //int hereCount = [[[ven objectForKey: @"hereNow"] objectForKey:@"count"] intValue]; 
        CGFloat latitude = [[[ven objectForKey: @"location"] objectForKey: @"lat"] floatValue];
		CGFloat longitude = [[[ven objectForKey: @"location"] objectForKey: @"lng"] floatValue];
        NSString *iconURL = [[[ven objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"];
        iconURL = [iconURL stringByReplacingOccurrencesOfString:@"https://foursquare.com/img/categories/" withString:@""];
        iconURL = [iconURL stringByReplacingOccurrencesOfString: @"/" withString: @"_"];
        UIImage *icon = [UIImage imageNamed:iconURL];
        //UIImage *icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconURL]]];
        //NSLog(@"lat%f, long%f", latitude, longitude);
        //NSLog(@"icon url %@", iconURL);

        [[NSBundle mainBundle] loadNibNamed:@"ListItemScrollView" owner:self options:nil];
       
        UILabel *nameLabel = (UILabel *)[venueDetailNib viewWithTag:1];
        [nameLabel setFont:[UIFont fontWithName:@"Rockwell" size:24]];
        [nameLabel setText:name];
        UIColor *redText = [UIColor colorWithRed:212.0/255.0 green:83.0/255.0 blue:88.0/255.0 alpha:1.0];
        [nameLabel setTextColor:redText];

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
		MKCoordinateRegion region = { { latitude , longitude } , { 0.001f , 0.001f } };
		
		// set all properties with the necessary details
		[foursquareAnnotation setCoordinate: region.center];
		[foursquareAnnotation setTitle: name];
		[foursquareAnnotation setSubtitle: address];
        [foursquareAnnotation setVenueId: vID];
        [foursquareAnnotation setIcon:icon];
		
		// add the annotation object to the container
		[annotations addObject: foursquareAnnotation];

    }
    [mvFoursquare addAnnotations: annotations];
    //[mvFoursquare selectAnnotation:[annotations objectAtIndex:0] animated:YES];
}

- (void) processRewards
{
    //write logic that handles case when it's been unlocked
    //movieThumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 220, 447, 200)];
    //[movieThumbnailImageView setImage:scene.movieThumbnail];
    //[self.view addSubview:movieThumbnailImageView];

}

- (void) animateRewards
{
    /*
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
        UILabel *challengeText = (UILabel *) [self.view viewWithTag:-1];
        [challengeText setText:[NSString stringWithFormat:@"You checked in at %@. Now you can watch the next scene!", [[[[scene.checkInResponse objectForKey:@"response"] objectForKey:@"checkin"] objectForKey:@"venue"] objectForKey:@"name"]]];
        UILabel *venuename = (UILabel *) [self.view viewWithTag:2];
        [venuename setText:@"Unlocked"];
        UILabel *rewardBar = (UILabel *) [self.view viewWithTag:3];
        [rewardBar setAlpha:0.0];
        UILabel *rewardText = (UILabel *) [self.view viewWithTag:4];
        [rewardText setAlpha:0.0];
        
    }];
    [UIView animateWithDuration:1.0
                          delay:1.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGPoint neworigin = CGPointMake(movieThumbnailImageView.center.x, 200);     
                         movieThumbnailImageView.center = neworigin;
                     } 
                     completion:^(BOOL finished){
                         NSLog(@"scene image path %@", scene.moviePath);
                         scene.unlocked = TRUE;
                     }];
    
*/
}
- (IBAction) playVideo:(id)sender
{
    [self launchVideoPlayer];
}
- (void) launchVideoPlayer
{
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:scene.movieName
                                                                             ofType:@"mp4"]]; 
    moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
}

- (void) searchSetup
{
    NSLog(@"search setup");
    //[activityIndicator setHidden:NO];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator startAnimating];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager startUpdatingLocation];

}

- (IBAction)refreshSearch:(id)sender
{
    [venueView removeFromSuperview];
    scene.recentSearchVenueResults = Nil;
    [activityIndicator startAnimating];
    //remove annotations from mapview
    [self.mvFoursquare removeAnnotations:mvFoursquare.annotations];
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGAffineTransform transform1 = CGAffineTransformMakeRotation(180 * M_PI / 180);
                         CGAffineTransform transform2 = CGAffineTransformMakeRotation(360 * M_PI / 180);
                         refreshButton.transform = transform1;
                         refreshButton.transform = transform2;
                         
                     } 
                     completion:^(BOOL finished){
                         [self searchSetup];
                     }];
    
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
    if (meters < 10 && scene.recentSearchVenueResults) {
        [self processVenues:[[[[scene.recentSearchVenueResults objectForKey:@"response"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"]];
        return; 
    }
    
    scene.date = [newLocation timestamp];
    
    NSString *lat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
    request = [Foursquare searchVenuesNearByLatitude:lat longitude:lon categoryId:scene.categoryId];
    [request setDelegate:self];
    [request setTimeOutSeconds:20];
    [request startAsynchronous];    
     
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location error is called - %@", error);

}


#pragma mark - Required ASIHTTP Asynchronous request methods 


- (void)requestFinished:(ASIHTTPRequest *)rquest
{
    NSString *responseString = [rquest responseString];
    NSError *err;
    if ([[rquest.userInfo valueForKey:@"operation"] isEqualToString:@"searchVenues"]) {
        NSLog(@"searchVenues requestFinished");        
        NSDictionary *venuesDict = [NSDictionary dictionaryWithJSONString:responseString error:&err];
        scene.recentSearchVenueResults = venuesDict;
        //NSLog(@"venuesdict %@", venuesDict);
        [self processVenues:[[[[venuesDict objectForKey:@"response"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"]];
    }    
}

- (void)requestFailed:(ASIHTTPRequest *)rquest
{
    NSError *error = [rquest error];
    NSLog(@"error! %@", error);
    // Must add graceful network error like a pop-up saying, get internet!
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Timeout" message:@"Are you sure you have internet right now...?" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] ;
    //[alert show];
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
}

#pragma mark - Map View Delegate methods
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	// didUpdateUserLocation tend to repeat at times
	// so to not get a duplicated pin(s)
	if ([self isPinsLoaded])
	{
		return;
	}
	
	[self setPinsLoaded: YES];	
    userCurrentLocation = userLocation;
	// set the mapView's region the same as the user's coordinate
	CLLocationCoordinate2D userCoords = [userLocation coordinate];
	// with a fixed zoom level with an animation
	MKCoordinateRegion region = { { userCoords.latitude , userCoords.longitude }, { 0.009f , 0.009f } };
	[mapView setRegion: region animated: YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[FoursquareAnnotation class]]) {
        
        MKAnnotationView *annotationView = 
        (MKAnnotationView *)[mvFoursquare dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] 
                              initWithAnnotation:annotation 
                              reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;        
        annotationView.image = ((FoursquareAnnotation *)annotation).icon;
        //[mvFoursquare selectAnnotation:annotation animated:YES];
        
        // Create a UIButton object to add on the 
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        [annotationView setRightCalloutAccessoryView:rightButton];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [leftButton setTitle:annotation.title forState:UIControlStateNormal];
        //[annotationView setLeftCalloutAccessoryView:leftButton];
        
        return annotationView;
    }
    
    return nil; 
}

- (void)mapView:(MKMapView *)mapView 
 annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if ([(UIButton*)control buttonType] == UIButtonTypeDetailDisclosure){
        // Do your thing when the detailDisclosureButton is touched - open another mapviewcontroller or whatever
        
        NSString* foursquareURL = [NSString stringWithFormat: @"foursquare://venues/%@",((FoursquareAnnotation*)[view annotation]).venueId];
        BOOL canOpenFoursquareApp = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: foursquareURL]];
        if (canOpenFoursquareApp) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: foursquareURL]]; 
        }
        else {
            NSString *formattedAddress = [[NSString stringWithFormat:@"%@",(FoursquareAnnotation*)[view annotation].subtitle] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSString *routeString = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@&dirflg=w",userCurrentLocation.coordinate.latitude,userCurrentLocation.coordinate.longitude,formattedAddress];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:routeString]];
        }
        
    } else if([(UIButton*)control buttonType] == UIButtonTypeInfoDark) {
        // Do your thing when the infoDarkButton is touched
        NSLog(@"infoDarkButton for longitude: %f and latitude: %f and address is %@", 
              [(FoursquareAnnotation*)[view annotation] coordinate].longitude, 
              [(FoursquareAnnotation*)[view annotation] coordinate].latitude, (FoursquareAnnotation*)[view annotation].subtitle);
    }
}
/*
- (void) mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    for (id<MKAnnotation> currentAnnotation in mapView.annotations) {       
        if ([currentAnnotation isEqual:annotationToSelect]) {
            [mapView selectAnnotation:currentAnnotation animated:FALSE];
        }
    }
}
*/
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    //Here
    //sleep(3);
    //[mapView selectAnnotation:[[mapView annotations] lastObject] animated:YES];
    //[[views lastObject] setHighlighted:YES];
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (scene.categoryId && !scene.unlocked) 
    {
        [self searchSetup];
    }
    else {
        [searchView removeFromSuperview];
        //[mvFoursquare removeFromSuperview];
    }
    
    
    [movieThumbnailImageView setImage:[UIImage imageNamed:scene.movieThumbnail]];
    sceneTitle.text = scene.name;
    sceneTitle.font = [UIFont fontWithName:@"rockwell-bold" size:30];
    UIColor *brownText = [UIColor colorWithRed:62.0/255.0 green:43.0/255.0 blue:26.0/255.0 alpha:1.0];
    [sceneTitle setTextColor:brownText];
    checkInIntructions.text = scene.checkInCopy;
    checkInIntructions.font = [UIFont fontWithName:@"rockwell" size:18];
    [checkInIntructions setTextColor:brownText];
    
    CGSize screenSize = CGSizeMake(480, 540);
    checkinScrollView.contentSize = screenSize;
    checkinScrollView.showsHorizontalScrollIndicator = NO;
    checkinScrollView.showsVerticalScrollIndicator = NO;
    checkinScrollView.bounces = NO;
    checkinScrollView.pagingEnabled = YES;
    [checkinScrollView setDelegate:self];
    [checkinScrollView addSubview:checkinView];
    venueScrollView.pagingEnabled = YES;
    mvFoursquare.layer.cornerRadius = 10.0;
    
    UIImage *leftArrowOn = [UIImage imageNamed:@"carosel_arrow-on.png"];
    [leftScroll setImage:[UIImage imageWithCGImage:leftArrowOn.CGImage 
                                             scale:1.0 orientation: UIImageOrientationUpMirrored] forState:UIControlStateNormal];
    
}
- (void)dealloc
{
    [request clearDelegatesAndCancel];
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
