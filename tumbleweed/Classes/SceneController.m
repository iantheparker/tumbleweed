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
#import <UIImageView+AFNetworking.h>
#import "RegionAnnotation.h"
#import "RegionAnnotationView.h"

#define MINIMUM_ZOOM_ARC 0.008 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.0
#define MAP_LATITUDE_OFFSET .0014
#define MAX_DEGREES_ARC 360
#define DISTANCE_UNLOCK_RADIUS 1000.0

typedef enum {
    kSearch,
    kExplore,
    kDistance
} SearchType;

@interface SceneController()

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSString *sectionId;
@property (nonatomic, retain) NSString *noveltyId;
@property (nonatomic, retain) NSString *queryString;
@property (nonatomic, retain) NSString *sceneTypeName;
@property (nonatomic,retain) NSDictionary *sceneTypeDict;
@property (nonatomic, retain) NSString *movieName;
@property (nonatomic, retain) NSString *checkInCopy;
@property (nonatomic, retain) NSString *bonusUrl;

@property (nonatomic) unsigned int venueSVPos;

-(void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated;
-(void) gameSavetNotif: (NSNotification *) notif;
-(void) refreshView;
-(void) launchCheckinVC: (id)sender : (NSDictionary*) dict;
-(IBAction) launchBonusWebView;
-(void) willPresentError:(NSError *)error;
-(void)updateTimer:(NSTimer *)timer;
-(void) killTimer;
- (void) processVenues: (NSInteger) searchType : (NSArray *) items : (NSError*) err;
- (void) searchSetup : (NSInteger) searchType;
- (void) addDistanceMonitoringRegion : (CLLocation*) toLocation;

@end


@implementation SceneController {
@private
    CLLocationCoordinate2D userCoordinate;
    NSTimer *countDownTimer;
    int currentTime;
    UIColor *redC;
    UIColor *brownC;
    UIColor *beigeC;
    NSMutableArray *allVenues;
    
}
//plist properties
@synthesize name, movieName, checkInCopy, bonusUrl;
@synthesize categoryId, sectionId, noveltyId, queryString, sceneTypeName, sceneTypeDict;
//map properties
@synthesize locationManager, mvFoursquare, pinsLoaded;
//checkin properties
@synthesize venueScrollView, venueDetailNib, venueView, sceneSVView, leftScroll, rightScroll, venueSVPos, refreshButton, activityIndicator;
//generic properties
@synthesize sceneScrollView, sceneTitle, checkInIntructions, movieThumbnailButton, moviePlayer, extrasView;


- (id) initWithScene:(Scene *) scn
{
    self = [super init];
    // Did the superclass's designated initializer succeed?
    if (self) {
        _scene = scn;
        
        name = [scn.pListDetails objectForKey:@"name"];
        sceneTypeName = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"type"];
        categoryId = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"categoryId"];
        sectionId = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"sectionId"];
        noveltyId = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"noveltyId"];
        movieName = [scn.pListDetails objectForKey:@"movieName"];
        checkInCopy = [scn.pListDetails objectForKey:@"checkInCopy"];
        bonusUrl = [NSString stringWithFormat:@"%d", scn.level];
    }
    return self;
}

#pragma mark -
#pragma mark Button Handlers


- (IBAction)dismissModal:(id)sender
{
    [UIView animateWithDuration:0.35
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
                     } completion:^(BOOL finished) {}];
    [self.navigationController popViewControllerAnimated:NO];
}
- (void) launchCheckinVC: (id)sender : (NSDictionary*) dict
{
    NSDictionary *launchDict;
    if ([sender isKindOfClass:[UIButton class]]) {
        [(UIButton*)sender setSelected:YES];
        [(UIButton*)sender setBackgroundColor:redC];
        launchDict = [NSDictionary dictionaryWithDictionary:[allVenues objectAtIndex:[(UIButton*)sender tag]]];
    }
    else
    {
        launchDict = [NSDictionary dictionaryWithDictionary:dict];
    }
    NSLog(@"venue name %@ : id %@", [launchDict objectForKey:@"name"], [launchDict objectForKey:@"id"]);
    CheckInController *checkIn = [[CheckInController alloc] initWithSenderId:self];
    [checkIn setVenueDetails:launchDict];
    //[self presentViewController:checkIn animated:YES completion:^{}];
    [UIView animateWithDuration:0.50
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:checkIn animated:YES];
                         //[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
                     } completion:^(BOOL finished) {
                         [(UIButton*)sender setSelected:NO];
                         [(UIButton*)sender setBackgroundColor:[UIColor clearColor]];
                     }];
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
- (IBAction)rightScroll:(id)sender
{
    self.venueSVPos += 1;
}
- (IBAction)leftScroll:(id)sender
{
    self.venueSVPos -= 1;
}
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.venueSVPos = venueScrollView.contentOffset.x / venueScrollView.frame.size.width;
}
- (void) setVenueSVPos:(unsigned int)position
{
    // use this line if trying to determin position from scrollview
    //pos = venueScrollView.contentOffset.x / venueScrollView.frame.size.width;
    if (position == venueSVPos) return;
    
    if ( position == 0) {
        leftScroll.enabled = NO;
        if ([allVenues count] > 1) {
            rightScroll.enabled = YES;
        }
    }
    if (position > 0 && position < [allVenues count] -1){
        leftScroll.enabled = YES;
        rightScroll.enabled = YES;
    }
    else if (position >= [allVenues count] -1) {
        position = [allVenues count]-1;
        rightScroll.enabled = NO;
        if ([allVenues count] > 1){
            leftScroll.enabled = YES;
        }
    }
    venueSVPos = position;
    
    [venueScrollView setContentOffset:CGPointMake(venueSVPos*venueScrollView.frame.size.width, 0) animated:TRUE];
    
    for (id<MKAnnotation> currentAnnotation in mvFoursquare.annotations) {
        if ([currentAnnotation isKindOfClass:[FoursquareAnnotation class]]){
            if (((FoursquareAnnotation*)currentAnnotation).arrayPos == venueSVPos) {
                [mvFoursquare selectAnnotation:(FoursquareAnnotation*)currentAnnotation animated:YES];
                //NSLog(@"mv selected %@", [[mvFoursquare selectedAnnotations] objectAtIndex:0]);
            }
        }
    }
    NSLog(@"venuesvpos = %i", venueSVPos);
    
    //update pagecontrol
    pageControl.currentPage = venueSVPos;

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
    [locationManager stopUpdatingLocation];
    userCoordinate = [locations.lastObject coordinate];
    
    NSLog(@"locationmanager latlong %f,%f ", userCoordinate.latitude, userCoordinate.longitude);
    
    [Foursquare exploreVenuesNearByLatitude:userCoordinate.latitude longitude:userCoordinate.longitude sectionId:sectionId noveltyId:noveltyId WithBlock:^(NSArray *venues, NSError *error) {
        if (error) {
            NSLog(@"error %@", error);
        }
        //[self processVenues:venues :error];
        
    }];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location error is called - %@", error);
    [locationManager stopUpdatingLocation];
    //[self processVenues:nil :error];
    
}

#pragma mark -
#pragma mark - Map View Delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:MKUserLocation.class]) return nil;
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
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 32, 32);
        rightButton.imageView.layer.cornerRadius = 10.0;
        [rightButton setImage:[UIImage imageNamed:@"4sq_map_button_checkin"] forState:UIControlStateNormal];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        [annotationView setRightCalloutAccessoryView:rightButton];
        
        
        UIImageView *leftIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [leftIcon setImageWithURL:[NSURL URLWithString:((FoursquareAnnotation *)annotation).iconUrl] placeholderImage:[UIImage imageNamed:@"fsq_catIcon_none"]];
        //[annotationView setLeftCalloutAccessoryView:leftIcon];
        
        return annotationView;
    }
    if([annotation isKindOfClass:[RegionAnnotation class]]) {
		RegionAnnotation *currentAnnotation = (RegionAnnotation *)annotation;
		NSString *annotationIdentifier = [currentAnnotation title];
		RegionAnnotationView *regionView = (RegionAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		
		if (!regionView) {
			regionView = [[RegionAnnotationView alloc] initWithAnnotation:annotation];
			regionView.map = mapView;
            
			
		} else {
			regionView.annotation = annotation;
			regionView.theAnnotation = annotation;
		}
		
		// Update or add the overlay displaying the radius of the region around the annotation.
		[regionView updateRadiusOverlay];
		
		return regionView;
	}
    
    return nil;
}
- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //this should animate the venuescrollview to the selected pin
    //the second if helps detect between a touch and a programmatic select
    if ([view.annotation isKindOfClass:MKUserLocation.class]) return;
    if ([[view annotation] isKindOfClass:[FoursquareAnnotation class]]){
        if (((FoursquareAnnotation*)[view annotation]).arrayPos != venueSVPos){
            //NSLog(@"foursquare annotationvew number %u", ((FoursquareAnnotation*)[view annotation]).arrayPos);
            self.venueSVPos = ((FoursquareAnnotation*)[view annotation]).arrayPos;
        }
    }
}
- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    //this won't get called as long as the left annotation button is custom instead of infoDark
    if ([(UIButton*)control buttonType] == UIButtonTypeInfoDark){
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
        
    } else if([(UIButton*)control buttonType] ==  UIButtonTypeCustom) {
        // Do your thing when the infoDarkButton is touched
        NSLog(@"infoDarkButton for longitude: %f and latitude: %f and address is %@",
              [(FoursquareAnnotation*)[view annotation] coordinate].longitude,
              [(FoursquareAnnotation*)[view annotation] coordinate].latitude, (FoursquareAnnotation*)[view annotation].subtitle);
        
        [self launchCheckinVC: nil:[NSDictionary dictionaryWithObjectsAndKeys:
                                    ((FoursquareAnnotation*)[view annotation]).venueId, @"id",
                                    ((FoursquareAnnotation*)[view annotation]).title, @"name", nil]];
        
    }
}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (id<MKAnnotation> currentAnnotation in mapView.annotations) {
        if ([currentAnnotation isKindOfClass:[FoursquareAnnotation class]]){
            if (((FoursquareAnnotation*)currentAnnotation).arrayPos == 0) {
                [mapView selectAnnotation:(FoursquareAnnotation*)currentAnnotation animated:YES];
                //NSLog(@"mv selected %@", [[mapView selectedAnnotations] objectAtIndex:0]);
                [self zoomMapViewToFitAnnotations:mapView animated:YES];
                break;
            }
        }
        else if ([currentAnnotation isKindOfClass:[RegionAnnotation class]]){
            break;
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
    region.center.latitude += MAP_LATITUDE_OFFSET;
    [mapView setRegion:region animated:animated];
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	if([overlay isKindOfClass:[MKCircle class]]) {
		// Create the view for the radius overlay.
		MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
		circleView.strokeColor = [UIColor purpleColor];
		circleView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.4];
		
		return circleView;
	}
	
	return nil;
}

#pragma mark -
#pragma mark - SearchView methods
- (void) searchSetup  : (NSInteger) searchType
{
    NSLog(@"search setup");
    
    //clear all previous results
    [venueScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [mvFoursquare removeAnnotations:mvFoursquare.annotations];
    [activityIndicator startAnimating];
    
    //guarantees the the mapView didUpdateUserLocation is called
    mvFoursquare.userTrackingMode = MKUserTrackingModeNone;
    mvFoursquare.showsUserLocation = YES;
    [self setPinsLoaded:NO];
    if (!locationManager){
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
    }
    //[locationManager startUpdatingLocation];
    
    RCLocationManager *locationManagerRC = [RCLocationManager sharedManager];
    [locationManagerRC setUserDistanceFilter:kCLLocationAccuracyHundredMeters];
    [locationManagerRC setUserDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManagerRC setPurpose:@"Foursquare Search/Explore"];
    [locationManagerRC retriveUserLocationWithBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
        userCoordinate = [newLocation coordinate];

        if (searchType == kExplore) {
            [Foursquare exploreVenuesNearByLatitude:userCoordinate.latitude longitude:userCoordinate.longitude sectionId:sectionId noveltyId:noveltyId WithBlock:^(NSArray *venues, NSError *error) {
                if (error) {
                    NSLog(@"error %@", error);
                }
                [self processVenues:searchType:venues :error];
            }];
        }
        else if (searchType == kSearch) {
            [Foursquare searchVenuesNearByLatitude:userCoordinate.latitude longitude:userCoordinate.longitude categoryId:categoryId WithBlock:^(NSArray *venues, NSError *error) {
                if (error) {
                    NSLog(@"error %@", error);
                }
                [self processVenues:searchType:venues :error];
            }];
        }
        
    } errorBlock:^(CLLocationManager *manager, NSError *error) {
        [self processVenues:searchType:nil :error];
    }];
    
    
}
- (void) processVenues: (NSInteger) searchType : (NSArray*) items : (NSError*) err
{
    [activityIndicator stopAnimating];
    [venueScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //init view sizes
    float nibwidth = venueScrollView.frame.size.width;
    float nibheight = venueScrollView.frame.size.height;
    int padding = 0;

    int itemsArrayLength = [items count];
    if (!itemsArrayLength) itemsArrayLength = 1;
    float scrollWidth = (nibwidth + padding) * itemsArrayLength;
    CGSize contentSize = CGSizeMake(scrollWidth, nibheight);
    venueScrollView.contentSize = contentSize;
    NSLog(@"processing %d foursquare venues", itemsArrayLength);
    
    //if re-search was hit, reset all the views and values
    //allVenues = nil;
    //venueView = nil;
    venueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];
    [venueScrollView addSubview:venueView];
    
    // If there are no search results, throw up "Nothing found."
    if ([items count] == 0 || err) {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];
        [nameLabel setTextAlignment:UITextAlignmentCenter];
        if (err) {
            [nameLabel setText:@"You need some internets."];
            [self willPresentError:err];
        }
        else [nameLabel setText:@"Nothing nearby? Weird."];
        
        NSLog(@"items %@, itemsArrayLength %d, error %@, namelable %@", items, itemsArrayLength, err.domain, nameLabel.text);
        [nameLabel setFont:[UIFont fontWithName:@"Rockwell" size:24]];
        [nameLabel setTextColor:beigeC];
        [nameLabel setClearsContextBeforeDrawing:YES];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setCenter:CGPointMake(nibwidth/2, nibheight/2)];
        [venueView addSubview:nameLabel];
        rightScroll.enabled = NO;
    }
    else{
        if (items.count > 1) rightScroll.enabled = YES;
        
        allVenues = [NSMutableArray arrayWithCapacity:itemsArrayLength];

        int offset = 0;
        NSMutableArray *annotations = [[NSMutableArray alloc] init];
        for (int i = 0; i < [items count]; i++) {
            
            NSDictionary *ven = [items objectAtIndex:i];
            NSString *vID = [ven objectForKey:@"id"];
            NSString *vName = [ven objectForKey:@"name"];
            NSString *address = [[ven objectForKey: @"location"]  objectForKey:@"address"];
            CGFloat latitude = [[[ven objectForKey: @"location"] objectForKey: @"lat"] floatValue];
            CGFloat longitude = [[[ven objectForKey: @"location"] objectForKey: @"lng"] floatValue];
            NSArray *venCats = [ven objectForKey:@"categories"];
            NSString *iconURL;
            if (venCats.count) {
                if (searchType == kSearch) {
                    iconURL = [[[venCats objectAtIndex:0] objectForKey:@"icon"] objectForKey:@"prefix"];
                    iconURL = [iconURL stringByAppendingString:@"64.png"];
                }
                else if (searchType == kExplore){
                    iconURL = [[venCats objectAtIndex:0] objectForKey:@"icon"];
                    iconURL = [iconURL stringByReplacingOccurrencesOfString:@".png" withString:@"_64.png"];
                }
            }
            
            [[NSBundle mainBundle] loadNibNamed:@"ListItemScrollView" owner:self options:nil];
            UIButton *nameButton = (UIButton *)[venueDetailNib viewWithTag:1];
            [[nameButton titleLabel] setFont:[UIFont fontWithName:@"Rockwell" size:24]];
            [[nameButton titleLabel] setBackgroundColor:[UIColor clearColor]];
            [nameButton setTitle:vName forState:UIControlStateNormal];
            [nameButton setTitleColor:redC forState:UIControlStateNormal];
            [nameButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateHighlighted | UIControlStateSelected)];
            
            [nameButton.layer setBorderColor:[[UIColor colorWithRed:163.0/255.0 green:151.0/255.0 blue:128.0/255.0 alpha:0.2] CGColor]];
            [nameButton.layer setBorderWidth:2.0];
            
            offset = (int)(nibwidth + padding) * i; 
            CGPoint nibCenter = CGPointMake(offset + (nibwidth / 2), nibheight/2);
            [venueDetailNib setCenter:nibCenter];
            
            // push venue details into a tag for future lookup            
            nameButton.tag = i;
            [allVenues addObject:ven];
            
            // capture events
            [nameButton addTarget:self action:@selector(launchCheckinVC::) forControlEvents:UIControlEventTouchDown];
            
            // add it to the content view
            [venueView addSubview:venueDetailNib];
            
            // create and initialise the annotation
            FoursquareAnnotation *foursquareAnnotation = [[FoursquareAnnotation alloc] init];
            // create the map region for the coordinate
            MKCoordinateRegion region = { { latitude , longitude } , { 0.001f , 0.001f } };
            
            // set all properties with the necessary details
            [foursquareAnnotation setCoordinate: region.center];
            [foursquareAnnotation setTitle: vName];
            //[foursquareAnnotation setTitle: [NSString stringWithFormat:@"%d", i+1]];
            [foursquareAnnotation setSubtitle: address];
            [foursquareAnnotation setVenueId: vID];
            [foursquareAnnotation setIconUrl:iconURL];
            [foursquareAnnotation setArrayPos:((unsigned int) i)];
            
            // add the annotation object to the container
            [annotations addObject: foursquareAnnotation];
            
        }
        [mvFoursquare addAnnotations: annotations];
    }
    [venueScrollView.subviews makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    self.venueSVPos = 0;
    //update pagecontrol
    pageControl.numberOfPages = [allVenues count];

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
                         [self refreshView];
                     }];
    
}
#pragma mark -
#pragma mark - Timer methods
-(void) killTimer
{
    [countDownTimer invalidate];
}
-(void)updateTimer:(NSTimer *)timer
{
    currentTime -= 1 ;
    if(currentTime <=0){
        [countDownTimer invalidate];
        [self animateRewards:1:YES];
        [[Tumbleweed sharedClient] updateLevel:(_scene.level + 1)];
    }else
        [self populateLabelwithTime:currentTime];

}
- (void)populateLabelwithTime:(int)seconds
{
    if ([activityIndicator isAnimating]) {
        [activityIndicator stopAnimating];
    }
    
    int minutes = seconds / 60;
    int hours = minutes / 60;
    
    seconds -= minutes * 60;
    minutes -= hours * 60;
    
    NSString * result1 = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    timerLabel.text = result1;
    
}
#pragma mark - 
#pragma mark - Distance methods
- (void) addDistanceMonitoringRegion : (CLLocation*) toLocation
{
    [activityIndicator stopAnimating];
    if ([RCLocationManager regionMonitoringAvailable]) {    
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(toLocation.coordinate.latitude, toLocation.coordinate.longitude);
        CLRegion *newRegion = [[CLRegion alloc] initCircularRegionWithCenter:coord
                                                                      radius:DISTANCE_UNLOCK_RADIUS
                                                                  identifier:[NSString stringWithFormat:@"%f, %f", toLocation.coordinate.latitude, toLocation.coordinate.longitude]];
        
        // Create an annotation to show where the region is located on the map.
        RegionAnnotation *myRegionAnnotation = [[RegionAnnotation alloc] initWithCLRegion:newRegion];
        myRegionAnnotation.coordinate = newRegion.center;
        myRegionAnnotation.radius = newRegion.radius;
        [mvFoursquare addAnnotation:myRegionAnnotation];
        
        MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(toLocation.coordinate, 2.5 * DISTANCE_UNLOCK_RADIUS, 2.5 * DISTANCE_UNLOCK_RADIUS);
        [mvFoursquare setRegion:userLocation animated:YES];
        mvFoursquare.showsUserLocation = YES;
        mvFoursquare.userTrackingMode = MKUserTrackingModeNone;
        
        // Start monitoring the newly created region.
        [[RCLocationManager sharedManager] addRegionForMonitoring:newRegion desiredAccuracy:kCLLocationAccuracyBest updateBlock:^(CLLocationManager *manager, CLRegion *region, BOOL enter) {
            if (enter) {
                NSLog(@"Enter to region %@", region);
                
            } else {
                NSLog(@"Exit from region %@", region);
                [[Tumbleweed sharedClient] updateLevel:(_scene.level + 1)];
                [[RCLocationManager sharedManager] stopMonitoringAllRegions];
                [self animateRewards:1:YES];
            }
            
        } errorBlock:^(CLLocationManager *manager, CLRegion *region, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            [self processVenues:0 :nil :error];
        }];
        
	}
	else {
		NSLog(@"Region monitoring is not available.");
	}
    
    [[RCLocationManager sharedManager] startUpdatingLocationWithBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
        [venueScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        float distance = DISTANCE_UNLOCK_RADIUS-[[[Tumbleweed sharedClient] lastKnownLocation] distanceFromLocation:newLocation];
        if (distance <= 0) {
            [[Tumbleweed sharedClient] updateLevel:(_scene.level + 1)];
            [[RCLocationManager sharedManager] stopMonitoringAllRegions];
            [[RCLocationManager sharedManager] stopUpdatingLocation];
            [self animateRewards:1:YES];
        }
        timerLabel.text = [NSString stringWithFormat:@"%.f meters to go", distance];
    } errorBlock:^(CLLocationManager *manager, NSError *error) {
        [self processVenues:0 :nil :error];
    }];

}
#pragma mark -
#pragma mark - Load/Unload methods
- (void) animateRewards : (NSTimeInterval) duration : (BOOL) withVideo
{
    extrasView.hidden = NO;
    [UIView animateWithDuration:duration animations:^{
        CGSize screenSize = CGSizeMake(sceneSVView.bounds.size.width, 320);
        sceneScrollView.contentSize = screenSize;
        checkInIntructions.alpha = 0.0;
        contentView.layer.opacity = 0.0;
    } completion:^(BOOL finished) {
        [contentView removeFromSuperview];
        [checkInIntructions removeFromSuperview];
        [UIView transitionWithView:movieThumbnailButton
                          duration:0.4f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            movieThumbnailButton.enabled = YES;
                            extrasView.alpha = 1.0;
                            
                        } completion:^(BOOL finished){
                            if (withVideo)[self playVideo:nil];
                        }];
        
    }];
    
}
-(void) gameSavetNotif: (NSNotification *) notif
{
    //dismiss view if game state is saved - saving occurs when app enters background or receives update from server
    if ([[notif name] isEqualToString:@"gameSaved"]){
        [self refreshView];
    }
    
}
- (void) willPresentError:(NSError *)error
{
    
    NSString *errorTitle;
    NSString *errorMessage;
    NSLog(@"presenting alert error");
    if ([[error domain] isEqualToString:kCLErrorDomain] || [[error domain] isEqualToString:NSURLErrorDomain]) {
        switch([error code]) {
            case kCLAuthorizationStatusAuthorized:
            case kCLErrorDenied:
                errorTitle = @"Location Services Disabled";
                errorMessage = @"To re-enable, please go to Settings and turn on Location Service for this app.";
                break;
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
- (void) refreshView
{
    NSLog(@"refreshing view");
    if ([sceneTypeName isEqualToString:@"Empty"])
    {
        movieThumbnailButton.enabled = YES;
        if ([movieName isEqualToString:@"intro"]) {
            [contentView addSubview:introView];
            introView.center = CGPointMake(contentView.bounds.size.width/2, introView.center.y);
            for (UILabel *loopLabel in introView.subviews) {
                if ([loopLabel isKindOfClass:[UILabel class]]) {
                    loopLabel.font = [UIFont fontWithName:@"rockwell" size:loopLabel.font.pointSize];
                    loopLabel.textColor = brownC;
                }
            }
        }
        else if ([movieName isEqualToString:@"campfire"])
        {
            [self animateRewards:0:NO];
        }
        
    }
    else
    {
        if (_scene.level < [Tumbleweed sharedClient].tumbleweedLevel) [self animateRewards:1:NO];
        else
        {
            if ([sceneTypeName isEqualToString:@"FSQsearch"])
            {
                [contentView addSubview:searchView];
                searchView.center = CGPointMake(contentView.bounds.size.width/2, searchView.center.y);
                venueScrollView.delegate = self;
                [self searchSetup:kSearch];
            }
            else if ([sceneTypeName isEqualToString:@"Timer"])
            {
                [activityIndicator startAnimating];
                [contentView addSubview:timerLabel];
                timerLabel.center = CGPointMake(contentView.bounds.size.width/2, timerLabel.center.y);
                [contentView addSubview:activityIndicator];
                sceneScrollView.contentSize = CGSizeMake(sceneScrollView.contentSize.width, 320);

                if (![[Tumbleweed sharedClient] lastLevelUpdate]) {
                    [[Tumbleweed sharedClient] setLastLevelUpdate:[NSDate date]];
                }
                currentTime = 1000 + (int)[[[Tumbleweed sharedClient] lastLevelUpdate] timeIntervalSinceNow];
                [countDownTimer invalidate];
                countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
                
            }
            else if ([sceneTypeName isEqualToString:@"FSQexplorenew"])
            {
                [contentView addSubview:searchView];
                searchView.center = CGPointMake(contentView.bounds.size.width/2, searchView.center.y);
                venueScrollView.delegate = self;
                [self searchSetup:kExplore];

            }
            else if ([sceneTypeName isEqualToString:@"FSQdistance"])
            {
                [contentView addSubview:searchView];
                searchView.center = CGPointMake(contentView.bounds.size.width/2, searchView.center.y);
                [contentView addSubview:timerLabel];
                timerLabel.center = CGPointMake(contentView.bounds.size.width/2, timerLabel.center.y);
                [activityIndicator startAnimating];
                [leftScroll removeFromSuperview];
                [rightScroll removeFromSuperview];
                [[RCLocationManager sharedManager] stopMonitoringAllRegions];
                
                if ([[Tumbleweed sharedClient] lastKnownLocation]) {
                    [self addDistanceMonitoringRegion: [[Tumbleweed sharedClient] lastKnownLocation]];
                }
                else{
                    [[RCLocationManager sharedManager] retriveUserLocationWithBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
                        [[Tumbleweed sharedClient] setLastKnownLocation:newLocation];
                        [self addDistanceMonitoringRegion:newLocation];
                        NSLog(@"retriveloc for add region");
                    } errorBlock:^(CLLocationManager *manager, NSError *error) {
                        NSLog(@"addregion error 1");
                        [self processVenues:0 :nil :error];
                    }];
                }
                
                
            }
        }
    }
    
    
}

#pragma mark -
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set UIColors
    brownC = [UIColor colorWithRed:62.0/255.0 green:43.0/255.0 blue:26.0/255.0 alpha:1.0];
    redC = [UIColor colorWithRed:212.0/255.0 green:83.0/255.0 blue:88.0/255.0 alpha:1.0];
    beigeC = beigeC = [UIColor colorWithRed:163.0/255.0 green:151.0/255.0 blue:128.0/255.0 alpha:1.0];
        
    sceneTitle.text = name;
    sceneTitle.font = [UIFont fontWithName:@"rockwell-bold" size:30];
    [sceneTitle setTextColor:brownC];
    checkInIntructions.font = [UIFont fontWithName:@"rockwell" size:18];
    [checkInIntructions setTextColor:brownC];
    checkInIntructions.text = checkInCopy;
    [timerLabel setFont:[UIFont fontWithName:@"rockwell" size:26]];
    [timerLabel setTextColor:beigeC];
    
    //movieButton settings
    {
        NSString *imgName1 =[_scene.pListDetails objectForKey:@"movieButtonOn"];
        UIImage *buttonImg = [UIImage imageNamed:imgName1];
        [movieThumbnailButton setImage:buttonImg forState:UIControlStateNormal];
        
        NSString *imgName2 =[_scene.pListDetails objectForKey:@"movieButtonPressed"];
        UIImage *buttonImg2 = [UIImage imageNamed:imgName2];
        [movieThumbnailButton setImage:buttonImg2 forState:UIControlStateHighlighted];
        
        if ([_scene.pListDetails objectForKey:@"movieButtonOff"]) {
            NSString *imgName3 =[_scene.pListDetails objectForKey:@"movieButtonOff"];
            UIImage *buttonImg3 = [UIImage imageNamed:imgName3];
            [movieThumbnailButton setImage:buttonImg3 forState:UIControlStateDisabled];
        }
    }
    
    [sceneSVView.layer setContents:(__bridge id)[[UIImage imageNamed:@"check-in_bg.jpg"] CGImage]];
    
    CGSize screenSize = CGSizeMake(sceneSVView.bounds.size.width, sceneSVView.bounds.size.height);
    if ([sceneSVView.subviews containsObject:contentView]) sceneScrollView.contentSize = screenSize;
    [sceneScrollView addSubview:sceneSVView];
    
    mvFoursquare.layer.cornerRadius = 10.0;
    
    [self refreshView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self refreshView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameSavetNotif:)
                                                 name:@"gameSave" object:nil];     
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[RCLocationManager sharedManager] stopUpdatingLocation];
    [[RCLocationManager sharedManager] stopMonitoringAllRegions];
    [Foursquare cancelSearchVenues];
    [self killTimer];
    
    [locationManager stopUpdatingLocation];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
