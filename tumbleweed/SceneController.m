//
//  SceneController.m
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "SceneController.h"
#import "CheckInController.h"
#import "AFFoursquareAPIClient.h"
#import "BonusWebViewController.h"



#define MINIMUM_ZOOM_ARC 0.008 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.0
#define MAX_DEGREES_ARC 360

@interface SceneController()

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSString *movieName;
@property (nonatomic, retain) NSString *movieThumbnail;
@property (nonatomic, retain) NSString *posterArt;
@property (nonatomic, retain) NSString *checkInCopy;
@property (nonatomic, retain) NSString *bonusUrl;
@property (nonatomic) unsigned int venueSVPos;
@property (strong, nonatomic) NSTimer *locationTimer;

-(void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated;
-(void) gameSavetNotif: (NSNotification *) notif;
-(void) refreshView;
-(void) launchCheckinVC: (NSDictionary*) dict;
-(void) launchBonusWebView;
- (void) willPresentError:(NSError *)error;
- (void)stopUpdatingLocations;


@end


@implementation SceneController {
@private
    CLLocationCoordinate2D userCoordinate;
    
    
}
//plist properties
@synthesize name, categoryId, movieName, movieThumbnail, posterArt, checkInCopy, bonusUrl;
//map properties
@synthesize locationManager, mvFoursquare, pinsLoaded;
//checkin properties
@synthesize venueScrollView, venueDetailNib, venueView, allVenues, sceneSVView, leftScroll, rightScroll, venueSVPos, locationTimer, refreshButton, activityIndicator;
//generic properties
@synthesize sceneScrollView, movieThumbnailImageView, sceneTitle, checkInIntructions, playButton, moviePlayer;


- (id) initWithScene:(Scene *) scn
{
    self = [super init];
    // Did the superclass's designated initializer succeed?
    if (self) {
        _scene = scn;
        
        name = scn.name;
        categoryId = scn.categoryId;
        movieName = scn.movieName;
        movieThumbnail = scn.movieThumbnail;
        posterArt = scn.posterArt;
        checkInCopy = scn.checkInCopy;
        bonusUrl = scn.bonus;
         
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    return self;
}

#pragma mark -
#pragma mark Button Handlers


- (IBAction)dismissModal:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [Foursquare cancelSearchVenues];
        [locationManager stopUpdatingLocation];
        mvFoursquare.showsUserLocation = NO;
    }];
}
- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender {
    NSString *viewId = [NSString stringWithFormat:@"%d", [sender.view hash]];    ;
    NSDictionary *venueDetails = [allVenues objectForKey:viewId];
    [self launchCheckinVC:venueDetails];
    
}
- (void) launchCheckinVC: (NSDictionary*) dict
{
    NSLog(@"venue name %@ : id %@", [dict objectForKey:@"name"], [dict objectForKey:@"id"]);
    CheckInController *checkIn = [[CheckInController alloc] initWithSenderId:self];
    [checkIn setVenueDetails:dict];
    [checkIn setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentViewController:checkIn animated:YES completion:NULL];
}
- (void) launchBonusWebView
{
    NSLog(@"launching bonus webview");
    BonusWebViewController *bonusView = [[BonusWebViewController alloc] initWithUrl:bonusUrl];
    [self presentViewController:bonusView animated:YES completion:^{}];
    
}
- (IBAction) playVideo:(id)sender
{
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:movieName
                                                                             ofType:@"mp4"]];
    moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    // prevent mute switch from switching off audio from movie player
    NSError *_error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &_error];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
}
- (IBAction)refreshSearch:(id)sender
{
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
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
- (IBAction)rightScroll:(id)sender
{
    self.venueSVPos += 1;
    if ([mvFoursquare annotations]){
        [mvFoursquare selectAnnotation:[[mvFoursquare annotations] objectAtIndex:venueSVPos] animated:YES];
    }


}
- (IBAction)leftScroll:(id)sender
{
    self.venueSVPos -= 1;
    if ([mvFoursquare annotations]){
        [mvFoursquare selectAnnotation:[[mvFoursquare annotations] objectAtIndex:venueSVPos] animated:YES];
    }

}
- (void) setVenueSVPos:(unsigned int)position
{
    NSLog(@"venuesvpos = %i", position);
    // use this line if trying to determin position from scrollview
    //pos = venueScrollView.contentOffset.x / venueScrollView.frame.size.width;
    if (position == venueSVPos) return;
    
    if ( position == 0) leftScroll.enabled = NO;
    if (position > 0 && position < [allVenues count] -1){
        leftScroll.enabled = YES;
        rightScroll.enabled = YES;
    }
    else if (position >= [allVenues count] -1) {
        position = [allVenues count]-1;
        rightScroll.enabled = NO;
    }
    
    [venueScrollView setContentOffset:CGPointMake(position*venueScrollView.frame.size.width, 0) animated:TRUE];
    
    venueSVPos = position;
}
- (void) willPresentError:(NSError *)error {
    
    NSString *errorTitle;
    NSString *errorMessage;
    NSLog(@"presenting alert error");
    if ([[error domain] isEqualToString:kCLErrorDomain] || [[error domain] isEqualToString:NSURLErrorDomain]) {
        switch([error code]) {
            case kCLAuthorizationStatusAuthorized:
            case kCLErrorDenied:
            { // Private method of custom subclass.
                errorTitle = @"Location Services Disabled";
                errorMessage = @"To re-enable, please go to Settings and turn on Location Service for this app.";
            }
            default:
                errorTitle = @"Get Some Internet";
                errorMessage = @"You need some reception for this to work. Hit the re-search button on the map when you're ready.";
                break;
                
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                           message:errorMessage
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];
        
    }
    
}

- (void) processVenues: (NSArray*) items : (NSError*) err
{
    [activityIndicator stopAnimating];
    NSLog(@"processing foursquare venues");
    
    //init view sizes
    float nibwidth = venueScrollView.frame.size.width;
    float nibheight = venueScrollView.frame.size.height;
    int padding = 0;

    int itemsArrayLength = [items count];
    if (!itemsArrayLength) itemsArrayLength = 1;
    float scrollWidth = (nibwidth + padding) * itemsArrayLength;
    CGSize contentSize = CGSizeMake(scrollWidth, venueScrollView.contentSize.height);
    venueScrollView.contentSize = contentSize;

    
    //if re-search was hit, reset all the views and values
    venueView = nil;
    venueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollWidth, venueScrollView.frame.size.height)];
    
    [venueScrollView addSubview:venueView];
    
    // If there are no search results, throw up "Nothing found."
    if ([items count] == 0 || err) {
        [[NSBundle mainBundle] loadNibNamed:@"ListItemScrollView" owner:self options:nil];
        UILabel *nameLabel = (UILabel *)[venueDetailNib viewWithTag:1];
        if (err) {
            [nameLabel setText:@"You need some internets."];
            [self willPresentError:err];
        }
        else [nameLabel setText:@"Nothing nearby? Weird."];
        
        NSLog(@"items %@, itemsArrayLength %d, error %@, namelable %@", items, itemsArrayLength, err.domain, nameLabel.text);
        [nameLabel setFont:[UIFont fontWithName:@"Rockwell" size:24]];
        UIColor *redText = [UIColor colorWithRed:212.0/255.0 green:83.0/255.0 blue:88.0/255.0 alpha:1.0];
        [nameLabel setTextColor:redText];
        [nameLabel setClearsContextBeforeDrawing:YES];
        [venueDetailNib setCenter:CGPointMake(nibwidth/2, nibheight/2)];
        [venueView addSubview:venueDetailNib];
        rightScroll.enabled = NO;
    }
    else{
        if (items.count > 1) rightScroll.enabled = YES;
        allVenues = nil;
        allVenues = [[NSMutableDictionary alloc] init];

        int offset = 0;
        NSMutableArray *annotations = [[NSMutableArray alloc] init];
        for (int i = 0; i < [items count]; i++) {
            NSDictionary *ven = [items objectAtIndex:i];
            NSString *vID = [ven objectForKey:@"id"];
            NSString *vName = [ven objectForKey:@"name"];
            NSString *address = [[ven objectForKey: @"location"]  objectForKey:@"address"];
            //float distance = [[[ven objectForKey: @"location"] objectForKey: @"distance"] floatValue] *.00062;
            //int hereCount = [[[ven objectForKey: @"hereNow"] objectForKey:@"count"] intValue]; 
            CGFloat latitude = [[[ven objectForKey: @"location"] objectForKey: @"lat"] floatValue];
            CGFloat longitude = [[[ven objectForKey: @"location"] objectForKey: @"lng"] floatValue];
            NSString *iconURL = [[[[ven objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"] objectForKey:@"prefix"];
            iconURL = [iconURL stringByAppendingString:@"64.png"];
            //use afnetworking call for this
            
            UIImage *icon = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconURL]]];
            //UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
            //[imageView setImageWithURL:[NSURL URLWithString:iconURL] placeholderImage:[UIImage imageNamed:@"appicon_114"]];
            /* load local images
             
             iconURL = [iconURL stringByReplacingOccurrencesOfString:@"https://foursquare.com/img/categories_v2/" withString:@""];
             iconURL = [iconURL stringByReplacingOccurrencesOfString: @"/" withString: @"_"];
             if ( [iconURL length] > 0) iconURL = [iconURL substringToIndex:[iconURL length] - 1];
             UIImage *icon = [UIImage imageNamed:iconURL];
             
             if (!icon) {
             NSLog(@"no icon for %@ at %@", vName, iconURL);
             iconURL = [NSString stringWithFormat:@"%@_default", [[iconURL componentsSeparatedByString:@"_"] objectAtIndex:0]];
             //iconURL = [iconURL stringByReplacingOccurrencesOfString:[[iconURL componentsSeparatedByString:@"_"] lastObject] withString:@"_default"];
             NSLog(@"iconurl now %@", iconURL);
             icon = [UIImage imageNamed:iconURL];
             }
             */
            
            //NSLog(@"lat%f, long%f", latitude, longitude);
            
            [[NSBundle mainBundle] loadNibNamed:@"ListItemScrollView" owner:self options:nil];
            
            UILabel *nameLabel = (UILabel *)[venueDetailNib viewWithTag:1];
            //UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, venueScrollView.frame.size.width, venueScrollView.frame.size.height)];
            [nameLabel setFont:[UIFont fontWithName:@"Rockwell" size:24]];
            //[nameLabel setTextAlignment:UITextAlignmentCenter];
            [nameLabel setText:vName];
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
            [venueDetailNib addGestureRecognizer:tapHandler];
            
            // add it to the content view
            [venueView addSubview:venueDetailNib];
            
            // create and initialise the annotation
            FoursquareAnnotation *foursquareAnnotation = [[FoursquareAnnotation alloc] init];
            // create the map region for the coordinate
            MKCoordinateRegion region = { { latitude , longitude } , { 0.001f , 0.001f } };
            
            // set all properties with the necessary details
            [foursquareAnnotation setCoordinate: region.center];
            [foursquareAnnotation setTitle: vName];
            [foursquareAnnotation setSubtitle: address];
            [foursquareAnnotation setVenueId: vID];
            [foursquareAnnotation setIcon:icon];
            [foursquareAnnotation setIconUrl:iconURL];
            [foursquareAnnotation setArrayPos:((unsigned int) i)];
            
            // add the annotation object to the container
            [annotations addObject: foursquareAnnotation];
            
        }
        [mvFoursquare addAnnotations: annotations];
    }
    [venueScrollView.subviews makeObjectsPerformSelector:@selector(setNeedsDisplay)];
}

- (void) animateRewards
{
    
    UIButton *bonusButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bonusButton.alpha = 0.0;
    [bonusButton setTitle:@"Bonus!" forState:UIControlStateNormal];
    bonusButton.frame = CGRectMake(220.0, 260.0, 160.0, 40.0);;
    [bonusButton addTarget:self action:@selector(launchBonusWebView) forControlEvents:UIControlEventTouchDown];
    [sceneScrollView addSubview:bonusButton];
    
    [UIView animateWithDuration:1 animations:^{
        //screenSize.height = 320; //CGSize screenSize = CGSizeMake(480, 320);
        CGSize screenSize = CGSizeMake(sceneSVView.bounds.size.width, 320);
        sceneScrollView.contentSize = screenSize;
        checkInIntructions.text = @"check out the extras!";
        mvFoursquare.layer.opacity = 0.0;
        searchView.layer.opacity = 0.0;
    } completion:^(BOOL finished) {
        [searchView removeFromSuperview];
        [UIView transitionWithView:movieThumbnailImageView
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            movieThumbnailImageView.image = [UIImage imageNamed:movieThumbnail];
                            playButton.enabled = YES;
                            bonusButton.alpha = 1.0;
                            
                        } completion:NULL];
    }];

}
- (void) refreshView
{
    UIImage *movieThumb = [UIImage imageNamed:movieThumbnail];

    if (_scene.level == [Tumbleweed weed].tumbleweedLevel) {
        // load up initial state
        //checkInIntructions.text = checkInCopy;
        //playButton.enabled = NO;
        
        if (categoryId) {
            //load map, locate user, start foursquare search
            //screenSize = [UIScreen mainScreen].bounds.size;
            //NSLog(@"screensize %f %f, window = %@", screenSize.width, screenSize.height, NSStringFromCGRect(sceneSVView.bounds)  );
            //screenSize = CGSizeMake(480, 540);
            [self searchSetup];
            
        }
        else{
            //load alternate view
            //screenSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 320);
            //[searchView removeFromSuperview];
            if ([name isEqualToString:@"No Man's Land"] ||
                [name isEqualToString:@"The End"]) {
                [self animateRewards];
            }
        }
        //sepia image if locked
        {
            CIImage *inputImage = [[CIImage alloc] initWithCGImage:[[UIImage imageNamed:movieThumbnail] CGImage]];
            CIFilter *adjustmentFilter = [CIFilter filterWithName:@"CISepiaTone"];
            [adjustmentFilter setDefaults];
            [adjustmentFilter setValue:inputImage forKey:@"inputImage"];
            [adjustmentFilter setValue:[NSNumber numberWithFloat:1.0f] forKey:@"inputIntensity"];
            CIImage *outputImage = [adjustmentFilter valueForKey:@"outputImage"];
            CIContext* context = [CIContext contextWithOptions:nil];
            CGImageRef imgRef = [context createCGImage:outputImage fromRect:outputImage.extent] ;
            movieThumb = [UIImage imageWithCGImage:imgRef scale:1.0 orientation:UIImageOrientationUp];
            
        }
    }
    else{
        //load unlocked state
        [self animateRewards];
        
    }
    movieThumbnailImageView.image = movieThumb;

}
- (void) searchSetup
{
    NSLog(@"search setup");
    
    //clear all previous results
    self.venueSVPos = 0;
    [venueScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];    
    [mvFoursquare removeAnnotations:mvFoursquare.annotations];
    [activityIndicator startAnimating];
    
    //guarantees the the mapView didUpdateUserLocation is called
    mvFoursquare.userTrackingMode = MKUserTrackingModeNone;
    [self setPinsLoaded:NO];
    mvFoursquare.showsUserLocation = YES;
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(stopUpdatingLocations) userInfo:nil repeats:NO];
    [locationManager startUpdatingLocation];

}
-(void) gameSavetNotif: (NSNotification *) notif
{
    //dismiss view if game state is saved - saving occurs when app enters background or receives update from server
    if ([[notif name] isEqualToString:@"gameSaved"])
    {
        //should swap this for refresh view when i get the chance, otherwise if someone gets a slow update
        //this viewcontroller will close in the middle of them using it.
        //[self refreshView];
        [self dismissModalViewControllerAnimated:NO];
        
    }
    else if ([[notif name] isEqualToString:@"enteredBackground"])
    {
        [self dismissModalViewControllerAnimated:NO];
    }
    
}

#pragma mark -
#pragma mark -  CoreLocation delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // didUpdateUserLocation tend to repeat at times
	// so to not get a duplicated pin(s)
    CLLocationAccuracy accuracy = [locations.lastObject horizontalAccuracy];
    NSLog(@"%f accuracy", accuracy);
    if ([self isPinsLoaded] || !(accuracy > 0)) return;
	
	[self setPinsLoaded: YES];
    [manager stopUpdatingLocation];
    [locationTimer invalidate];
    userCoordinate = [locations.lastObject coordinate];
    
    NSString *lat = [NSString stringWithFormat:@"%f", [locations.lastObject coordinate].latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", [locations.lastObject coordinate].longitude];
    NSLog(@"locationmanager lat %@ long %@", lat, lon);
    
    [Foursquare searchVenuesNearByLatitude:lat longitude:lon categoryId:categoryId WithBlock:^(NSArray *venues, NSError *error) {
        if (error) {
            NSLog(@"error %@", error);
        } 
        [self processVenues:venues :error];
        
    }];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location error is called - %@", error);
    [self processVenues:nil :error];
    
}
- (void)stopUpdatingLocations
{
    [locationManager stopUpdatingLocation];
    [locationTimer invalidate];
    NSError *err = [NSError errorWithDomain:NSURLErrorDomain code:kCFErrorHTTPConnectionLost userInfo:nil];
    [self processVenues:nil :err];
}


#pragma mark - 
#pragma mark - Map View Delegate methods
/*
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	// didUpdateUserLocation tend to repeat at times
	// so to not get a duplicated pin(s)
    CLLocationAccuracy accuracy = userLocation.location.horizontalAccuracy;
	if ([self isPinsLoaded] || !(accuracy > 0)) return;
    
    [self setPinsLoaded: YES];
    
    //figure out how to keep showing location without frequent updates
    mvFoursquare.showsUserLocation = NO;
    
    NSLog(@"mapdidupdate location accuracy %f", accuracy);
    userCoordinate = [userLocation coordinate];
    
    NSString *lat = [NSString stringWithFormat:@"%f", userLocation.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", userLocation.coordinate.longitude];
    [Foursquare searchVenuesNearByLatitude:lat longitude:lon categoryId:categoryId WithBlock:^(NSArray *venues, NSError *error) {
        if (error) {
            NSLog(@"error %@", error);
        }
        [self processVenues:venues : error];
        
    }];

}
- (void) mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"map location error is called - %@", error);
    [self processVenues:nil :error];
    
}
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[FoursquareAnnotation class]]) {
        
        //change all these back to MKAnnotationView when I'm sick of pins
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mvFoursquare dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation 
                              reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;        
        //annotationView.image = ((FoursquareAnnotation *)annotation).icon;
        
        // Create a UIButton object to add on the 
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        [annotationView setRightCalloutAccessoryView:rightButton];
        
        //UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 32, 32);
        [leftButton setImage:((FoursquareAnnotation *)annotation).icon forState:UIControlStateNormal];
        [leftButton setTitle:annotation.title forState:UIControlStateNormal];
        [annotationView setLeftCalloutAccessoryView:leftButton];
        
        return annotationView;
    }
    
    return nil; 
}
- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //this should animate the venuescrollview to the selected pin
    if ([[[mapView selectedAnnotations] objectAtIndex:0] isKindOfClass:[FoursquareAnnotation class]]) {
        NSLog(@"foursquare annotationvew number %u", ((FoursquareAnnotation*)[view annotation]).arrayPos);
        //needs to detect between a touch and a programmatic select
        //self.venueSVPos = ((FoursquareAnnotation*)[view annotation]).arrayPos;
    }
    NSLog(@"mapview annotation selected");
}
- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    //this won't get called as long as the left annotation button is custom instead of infoDark
    if ([(UIButton*)control buttonType] == UIButtonTypeCustom){
        // Do your thing when the detailDisclosureButton is touched - open another mapviewcontroller or whatever
        
        NSString* foursquareURL = [NSString stringWithFormat: @"foursquare://venues/%@",((FoursquareAnnotation*)[view annotation]).venueId];
        BOOL canOpenFoursquareApp = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: foursquareURL]];
        if (canOpenFoursquareApp) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: foursquareURL]]; 
        }
        else {
            NSString *formattedAddress = [[NSString stringWithFormat:@"%@",(FoursquareAnnotation*)[view annotation].subtitle] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSString *routeString = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@&dirflg=w",userCoordinate.latitude,userCoordinate.longitude,formattedAddress];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:routeString]];
        }
        
    } else if([(UIButton*)control buttonType] ==  UIButtonTypeDetailDisclosure) {
        // Do your thing when the infoDarkButton is touched
        NSLog(@"infoDarkButton for longitude: %f and latitude: %f and address is %@", 
              [(FoursquareAnnotation*)[view annotation] coordinate].longitude, 
              [(FoursquareAnnotation*)[view annotation] coordinate].latitude, (FoursquareAnnotation*)[view annotation].subtitle);
        
        [self launchCheckinVC:[NSDictionary dictionaryWithObjectsAndKeys:
                               ((FoursquareAnnotation*)[view annotation]).venueId, @"id",
                               ((FoursquareAnnotation*)[view annotation]).title, @"name", nil]];
        
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    //Here
    //sleep(3);
    for (id<MKAnnotation> currentAnnotation in mapView.annotations) {
        if ([currentAnnotation isKindOfClass:[FoursquareAnnotation class]] && ((FoursquareAnnotation*)currentAnnotation).arrayPos == 0) {
            
            [mapView selectAnnotation:(FoursquareAnnotation*)currentAnnotation animated:YES];
        }
        //NSLog(@"annotations array %u", ((FoursquareAnnotation*)currentAnnotation).arrayPos);
        NSLog(@"annotations array %@", [currentAnnotation description]);
    }
    [self zoomMapViewToFitAnnotations:mapView animated:YES];
    for (int i = 0; i < views.count; i++)
    {
        if ([[[views objectAtIndex:i] annotation] isKindOfClass:[FoursquareAnnotation class]]) {
            //NSLog(@"view # %d matches foursquareannotation %d", i, ((FoursquareAnnotation*)[[views objectAtIndex:i] annotation]).arrayPos);
            NSLog(@"view # %d matches foursquareannotation %@", i, [[[views objectAtIndex:i] annotation] description]);


        }
    }
}

- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated
{
    NSArray *annotations = mapView.annotations;
    int count = [mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
}


#pragma mark -
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self refreshView];
        

    [playButton setImage:[UIImage imageNamed:@"play_icon.png"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"lock_icon.png"] forState:UIControlStateDisabled];

    sceneTitle.text = name;
    sceneTitle.font = [UIFont fontWithName:@"rockwell-bold" size:30];
    UIColor *brownText = [UIColor colorWithRed:62.0/255.0 green:43.0/255.0 blue:26.0/255.0 alpha:1.0];
    [sceneTitle setTextColor:brownText];
    checkInIntructions.font = [UIFont fontWithName:@"rockwell" size:18];
    [checkInIntructions setTextColor:brownText];
    checkInIntructions.text = checkInCopy;
    
    CGSize screenSize = CGSizeMake(sceneSVView.bounds.size.width, sceneSVView.bounds.size.height);
    sceneScrollView.contentSize = screenSize;
    [sceneScrollView setDelegate:self];
    [sceneScrollView addSubview:sceneSVView];
    mvFoursquare.layer.cornerRadius = 10.0;
    

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
    /*
    if ([Tumbleweed weed].tumbleweedLevel > _scene.level) {
        [self animateRewards];
    }
     */
    [self refreshView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameSavetNotif:)
                                                 name:@"gameSave" object:nil];
     
}
- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"disappearing scenecontroller");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
