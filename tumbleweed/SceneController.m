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

@interface SceneController()

@property (nonatomic) CLLocationCoordinate2D centerCoordinate;
@property (retain) ASIHTTPRequest *request;

@end


@implementation SceneController

@synthesize checkinScrollView, venueScrollView, venueDetailNib, movieThumbnailImageView, locationManager, allVenues, scene, mvFoursquare, pinsLoaded, userCurrentLocation, checkinView, sceneTitle, checkInIntructions, refreshButton, activityIndicator, leftScroll, rightScroll, centerCoordinate;
@synthesize moviePlayer, request;



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
    if ([items count] == 0) {
        UILabel *nameLabel = (UILabel *)[venueDetailNib viewWithTag:1];
        [nameLabel setFont:[UIFont fontWithName:@"Rockwell" size:24]];
        [nameLabel setText:@"Nothing around. Try again."];
        UIColor *redText = [UIColor colorWithRed:212.0/255.0 green:83.0/255.0 blue:88.0/255.0 alpha:1.0];
        [nameLabel setTextColor:redText];
        [nameLabel setClearsContextBeforeDrawing:YES];
        [venueView addSubview:venueDetailNib];
        return;
    }
    
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
        //UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        [nameLabel setFont:[UIFont fontWithName:@"Rockwell" size:24]];
        //[nameLabel setTextAlignment:UITextAlignmentCenter];
        [nameLabel setText:name];
        UIColor *redText = [UIColor colorWithRed:212.0/255.0 green:83.0/255.0 blue:88.0/255.0 alpha:1.0];
        [nameLabel setTextColor:redText];
        [nameLabel setClearsContextBeforeDrawing:YES];

        offset = (int)(nibwidth + padding) * i; 
        CGPoint nibCenter = CGPointMake(offset + (nibwidth / 2), nibheight/2);
        [venueDetailNib setCenter:nibCenter];
        
        // push venue details into a dictionary for future lookup
        NSString *viewId = [NSString stringWithFormat:@"%d", [venueDetailNib hash]];
        [allVenues setObject:ven forKey:viewId];
        
        // capture events
        UITapGestureRecognizer *tapHandler = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
        [nameLabel addGestureRecognizer:tapHandler];
        
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
    //moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    //[self presentMoviePlayerViewControllerAnimated:moviePlayer];
    
    MPMoviePlayerController *movie = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    movie.scalingMode=MPMovieScalingModeAspectFill;
    [movie setFullscreen:YES animated:YES];
    movie.useApplicationAudioSession = NO;
    [self.view addSubview:movie.view];
    [movie play];
}

- (void) searchSetup
{
    NSLog(@"search setup");
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator startAnimating];
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"has location, using refresh");
        NSString *lat = [NSString stringWithFormat:@"%f", centerCoordinate.latitude];
        NSString *lon = [NSString stringWithFormat:@"%f", centerCoordinate.longitude];
        request = [Foursquare searchVenuesNearByLatitude:lat longitude:lon categoryId:scene.categoryId];
        [request setTimeOutSeconds:20];
        /*
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSError *err;
            NSLog(@"searchVenues requestFinished REFRESH IN BLOCK");        
            NSDictionary *venuesDict = [NSDictionary dictionaryWithJSONString:responseString error:&err];
            scene.recentSearchVenueResults = venuesDict;
            //NSLog(@"venuesdict %@", venuesDict);
            [self processVenues:[[[[venuesDict objectForKey:@"response"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"]];
        }];
        [request setFailedBlock:^{
            NSError *error = [request error];
            NSLog(@"error REFRESH IN BLOCK! %@", error);
        }];
         */
        [request setDelegate:self];
        [request startAsynchronous]; 
        MKCoordinateRegion region = { centerCoordinate, { 0.009f , 0.009f } };
        [mvFoursquare setRegion: region animated: YES];
    }

}

- (IBAction)refreshSearch:(id)sender
{
    [venueView removeFromSuperview];
    scene.recentSearchVenueResults = Nil;
    [activityIndicator startAnimating];
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

#pragma mark - 
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
}

#pragma mark -
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
    /*
    request = [Foursquare searchVenuesNearByLatitude:lat longitude:lon categoryId:scene.categoryId];
    [request setTimeOutSeconds:20];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSError *err;
        NSLog(@"searchVenues requestFinished IN BLOCK");        
        NSDictionary *venuesDict = [NSDictionary dictionaryWithJSONString:responseString error:&err];
        scene.recentSearchVenueResults = venuesDict;
        //NSLog(@"venuesdict %@", venuesDict);
        [self processVenues:[[[[venuesDict objectForKey:@"response"] objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"]];
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"error IN BLOCK! %@", error);
    }];
     */
    [request startAsynchronous];    
    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location error is called - %@", error);
    
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
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    MKCoordinateRegion region;
    centerCoordinate = mapView.region.center;
    region.center= centerCoordinate;
    
    NSLog(@"%f,%f",centerCoordinate.latitude, centerCoordinate.longitude);
}

#pragma mark -
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
        if ([scene.name isEqualToString:@"No Man's Land"]) {
            UIImage *introImage = [UIImage imageNamed:@"intro_text_placeholder.jpg"];
            UIImageView *copyIntro = [[UIImageView alloc] initWithImage:introImage];
            copyIntro.frame = CGRectMake(75, 260, introImage.size.width, introImage.size.height);
            [checkinView addSubview:copyIntro];
        }
        else if ([scene.name isEqualToString:@"The End"])
        {
            UIImage *outroImage = [UIImage imageNamed:@"outro_text_placeholder.jpg"];
            UIImageView *copyOutro = [[UIImageView alloc] initWithImage:outroImage];
            copyOutro.frame = CGRectMake(75, 260, outroImage.size.width, outroImage.size.height);
            [checkinView addSubview:copyOutro];
        }
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
