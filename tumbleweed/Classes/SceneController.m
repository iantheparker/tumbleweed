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
#import <UIImageView+AFNetworking.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MCSpriteLayer.h"

#define MINIMUM_ZOOM_ARC 0.007 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.0
#define MAP_LATITUDE_OFFSET .0014
#define MAX_DEGREES_ARC 360
#define DISTANCE_UNLOCK_RADIUS 1000.0

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


typedef enum {
    kSearch,
    kExplore,
    kDistance
} SearchType;

@interface SceneController()

@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSString *sectionId;
@property (nonatomic, retain) NSString *noveltyId;
@property (nonatomic, retain) NSString *queryString;
@property (nonatomic, retain) NSString *sceneTypeName;
@property (nonatomic,retain) NSDictionary *sceneTypeDict;
@property (nonatomic, retain) NSString *movieName;
@property (nonatomic, retain) NSString *checkInCopy;
@property (nonatomic, retain) NSString *bonusUrl;
@property (nonatomic, retain) NSString *categoryHint;
@property (nonatomic, retain) NSString *radius;
@property (nonatomic, retain) NSString *friendVisits;
@property (nonatomic, retain) NSString *backupVenueID;


@property (nonatomic) unsigned int venueSVPos;

-(void) zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated;
-(void) gameSavetNotif: (NSNotification *) notif;
-(void) refreshView;
-(void) launchCheckinVC: (id)sender : (NSDictionary*) dict;
- (IBAction) launchBonusWebView;
- (void) willPresentError:(NSError *)error;
- (void) bypassCheckin;
- (void) processVenues: (NSInteger) searchType : (NSArray *) items : (NSError*) err;
- (void) searchSetup;
- (void) tapSpriteAdvancer: (unsigned int) tapNum;
- (void) removeTapView;
- (void) resetTapView: (BOOL) fromStart;
- (void) starringTapButton;


@end


@implementation SceneController {
@private
    CLLocationCoordinate2D userCoordinate;
    UIColor *redC;
    UIColor *brownC;
    UIColor *beigeC;
    NSMutableArray *allVenues;
    SystemSoundID checkinSound;
    unsigned int tapNumber;
    BOOL tappedOut;
    UILabel *tapLabel1;
    UILabel *tapLabel2;
    UILabel *tapLabel3;
    UIImageView *tapImage1;
    NSMutableArray *fsqannotations;
    BOOL middleOfNowhere;
    
}
//plist properties
@synthesize name, movieName, checkInCopy, bonusUrl;
@synthesize categoryId, sectionId, noveltyId, categoryHint, queryString, sceneTypeName, sceneTypeDict, radius, friendVisits, backupVenueID;
//map properties
@synthesize locationManager, mvFoursquare, pinsLoaded;
//checkin properties
@synthesize venueScrollView, venueDetailNib, venueView, leftScroll, rightScroll, venueSVPos, refreshButton, activityIndicator;
//generic properties
@synthesize unlockCopy, movieThumbnailButton, extrasView, moviePlayer, movieView, checkinButton, successfulVenueName, checkinInstructions, sceneTitleIV, playButton, tapView, lockedTapImage, lockedTapImageText;


- (id) initWithScene:(Scene *) scn
{
    self = [super initWithNibName:@"SceneController" bundle:nil];
    // Did the superclass's designated initializer succeed?
    if (self) {
        _scene = scn;
        name = [scn.pListDetails objectForKey:@"name"];
        sceneTypeName = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"type"];
        categoryId = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"categoryId"];
        categoryHint = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"categoryHint"];
        sectionId = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"sectionId"];
        noveltyId = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"novelty"];
        radius = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"radius"];
        friendVisits = [[scn.pListDetails objectForKey:@"sceneType"] objectForKey:@"friendVisits"];
        movieName = [scn.pListDetails objectForKey:@"movieName"];
        checkInCopy = [scn.pListDetails objectForKey:@"checkInCopy"];
        bonusUrl = [NSString stringWithFormat:@"%d", scn.level];
        backupVenueID = [scn.pListDetails objectForKey:@"bonusvID"];
    }
    return self;
}

#pragma mark -
#pragma mark Button Handlers


- (IBAction)dismissModal:(id)sender
{
    [UIView animateWithDuration:0.35
                     animations:^{
                         //[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
                     } completion:^(BOOL finished) {}];
    [self.navigationController popViewControllerAnimated:NO];
    NSLog(@"dismissing view");
}
- (void) launchCheckinVC: (id)sender : (NSDictionary*) dict
{
    if (!((FoursquareAnnotation*)[[mvFoursquare selectedAnnotations] objectAtIndex:0]).venueId) {
        [self willPresentError:[NSError errorWithDomain:nil code:0 userInfo:nil]];
        return;
    }
    NSDictionary *launchDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                ((FoursquareAnnotation*)[[mvFoursquare selectedAnnotations] objectAtIndex:0]).venueId, @"id",
                                ((FoursquareAnnotation*)[[mvFoursquare selectedAnnotations] objectAtIndex:0]).title, @"name", nil];
    NSLog(@"venue name %@ : id %@", [launchDict objectForKey:@"name"], [launchDict objectForKey:@"id"]);
    CheckInController *checkIn = [[CheckInController alloc] initWithSenderId:self];
    [checkIn setVenueDetails:launchDict];
    [UIView animateWithDuration:0.50
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:checkIn animated:YES];
                     } completion:^(BOOL finished) {}];
}
- (void) launchBonusWebView
{
    //nml extras page - 371737246292829
    // gdc page - 122858321793
    NSString* facebookURL = [NSString stringWithFormat: @"fb://profile/371737246292829"];
    BOOL canOpenFacebookApp = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: facebookURL]];
    if (canOpenFacebookApp) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: facebookURL]];
    }
    else
    {
        //western blog - http://western.goddamncobras.com/
        NSString *baseBonusURL = @"https://www.facebook.com/tumbleweedme";
        NSURL *URL = [NSURL URLWithString:baseBonusURL];
        BOOL result = [[UIApplication sharedApplication] openURL:URL];
        if (!result) {
            NSLog(@"*** %s: cannot open url \"%@\"", __PRETTY_FUNCTION__, URL);
        }
    }
    
    
}
- (IBAction) resetButton:(id)sender
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Reset"
                                                      message:@"Are you sure you want to reset No Man's Land?"
                                                     delegate:self
                                            cancelButtonTitle:@"Nahh"
                                            otherButtonTitles:@"YEAH!", nil];
    [message show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"YEAH!"])
    {
        NSLog(@"Button 1 was selected.");
        [[Tumbleweed sharedClient] resetLevel];
        [[TumbleweedViewController sharedClient] addProgressBar];
        [self dismissModal:nil];
    }
    if([title isEqualToString:@"Yup!"])
    {
        //increment level
        //animate rewards
        //add gps to foursquare list item
        [[Tumbleweed sharedClient] updateLevel:(_scene.level + 1) withVenue:@"#middleOfNowhere"];
        [Foursquare addListItem:[[NSUserDefaults standardUserDefaults] stringForKey:@"fsqListId"] venue:backupVenueID itemText:[NSString stringWithFormat:@"I unlocked this cool scene from the movie No Man's Land at these #middleOfNowhere coordinates %.0f, %.0f  ( but this venue is the place it was actually shot at! ) Thanks tumbleweed.me", userCoordinate.latitude, userCoordinate.longitude]];
        [self animateRewards:1:YES];
    }
}
- (void) resetScene
{
    tappedOut = NO;
    [movieView removeFromSuperview];
    [self.view addSubview:tapView];
    tapView.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width/2 +25);
    tapNumber = 0;
    [self tapSpriteAdvancer:tapNumber];
    tapView.alpha = 1;
    
}
- (IBAction) fsqListButton:(id)sender
{
    NSURL *URL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"fsqListUrl"]];
    BOOL result = [[UIApplication sharedApplication] openURL:URL];
    if (!result) {
        NSLog(@"*** %s: cannot open url \"%@\"", __PRETTY_FUNCTION__, URL);
    }
}
- (IBAction) playVideo:(id)sender 
{
    
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:movieName
                                                                             ofType:@"mp4"]];
    moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    
    // prevent mute switch from switching off audio from movie player
    NSError *_error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &_error];
    
    [[TumbleweedViewController sharedClient] tryPlayMusic:TRUE];
    
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];

    /*
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    [[moviePlayer view] setFrame:[[self view] bounds]];
    [[self view] addSubview: [moviePlayer view]];
    
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    //moviePlayer.controlStyle =  MPMovieControlStyleEmbedded;
    [moviePlayer setFullscreen:YES animated:YES];
    //[moviePlayer prepareToPlay];
    [moviePlayer setShouldAutoplay:YES];
    [moviePlayer play];
     
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerPlaybackDidFinish:) name:MPMoviePlayerDidExitFullscreenNotification object:self.moviePlayer];

    
    
    
     
    [[moviePlayer moviePlayer] prepareToPlay];
    [[moviePlayer moviePlayer] setUseApplicationAudioSession:YES];
    [[moviePlayer moviePlayer] setShouldAutoplay:YES];
    [[moviePlayer moviePlayer] setControlStyle:2];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer.moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    
    // Initialize the movie player view controller with a video URL string
    MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    
    // Remove the movie player view controller from the "playback did finish" notification observers
    [[NSNotificationCenter defaultCenter] removeObserver:playerVC
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:playerVC.moviePlayer];
    
    // Register this class as an observer instead
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:playerVC.moviePlayer];
    // Register for the “Done” button notification.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieExitFullscreen:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:playerVC.moviePlayer];
    
    // Set the modal transition style of your choice
    playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // Present the movie player view controller
    [self presentModalViewController:playerVC animated:YES];
    
    // Start playback
    [playerVC.moviePlayer prepareToPlay];
    [playerVC.moviePlayer play];
     */

}
- (IBAction)rightScroll:(id)sender
{
    self.venueSVPos += 1;
}
- (IBAction)leftScroll:(id)sender
{
    self.venueSVPos -= 1;
}
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
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
    
    //[venueScrollView setContentOffset:CGPointMake(venueSVPos*venueScrollView.frame.size.width, 0) animated:TRUE];
    [mvFoursquare removeAnnotations:fsqannotations];
    [mvFoursquare addAnnotation: [fsqannotations objectAtIndex:venueSVPos]];
    
    for (id<MKAnnotation> currentAnnotation in mvFoursquare.annotations) {
        if ([currentAnnotation isKindOfClass:[FoursquareAnnotation class]]){
            if (((FoursquareAnnotation*)currentAnnotation).arrayPos == venueSVPos) {
                [mvFoursquare selectAnnotation:(FoursquareAnnotation*)currentAnnotation animated:YES];
                //NSLog(@"mv selected %@", [[mvFoursquare selectedAnnotations] objectAtIndex:0]);
            }
        }
    }
    NSLog(@"venuesvpos = %i", venueSVPos);

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
    
    [Foursquare exploreVenuesNearByLatitude:userCoordinate.latitude longitude:userCoordinate.longitude sectionId:sectionId noveltyId:noveltyId distance:nil friendVisits:friendVisits WithBlock:^(NSArray *venues, NSError *error) {
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
                [self zoomMapViewToFitAnnotations:mapView animated:YES];
                [mapView selectAnnotation:(FoursquareAnnotation*)currentAnnotation animated:YES];
                //NSLog(@"mv selected %@", [[mapView selectedAnnotations] objectAtIndex:0]);
                break;
            }
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

#pragma mark -
#pragma mark - SearchView methods
- (void) searchSetup
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
    /*
    if (!locationManager){
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
    }
    [locationManager startUpdatingLocation];
    */
     
    RCLocationManager *locationManagerRC = [RCLocationManager sharedManager];
    [locationManagerRC setUserDistanceFilter:kCLLocationAccuracyHundredMeters];
    [locationManagerRC setUserDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManagerRC setPurpose:@"Foursquare Search/Explore"];
    [locationManagerRC retriveUserLocationWithBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
        userCoordinate = [newLocation coordinate];

        if (middleOfNowhere) {
            sectionId = nil;
            categoryId = nil;
        }
        if ([sceneTypeName isEqualToString:@"FSQexplorenew"]) {
            [Foursquare exploreVenuesNearByLatitude:userCoordinate.latitude longitude:userCoordinate.longitude sectionId:sectionId noveltyId:noveltyId distance:radius friendVisits:friendVisits WithBlock:^(NSArray *venues, NSError *error) {
                if (error) {
                    NSLog(@"error %@", error);
                }
                [self processVenues:kExplore:venues :error];
            }];
        }
        else if ([sceneTypeName isEqualToString:@"FSQsearch"]) {
            [Foursquare searchVenuesNearByLatitude:userCoordinate.latitude longitude:userCoordinate.longitude categoryId:categoryId WithBlock:^(NSArray *venues, NSError *error) {
                if (error) {
                    NSLog(@"error %@", error);
                }
                [self processVenues:kSearch:venues :error];
            }];
        }
        
    } errorBlock:^(CLLocationManager *manager, NSError *error) {
        [self processVenues:0:nil :error];
    }];
    NSLog(@"categoryid %@ sectionid %@ noveltyid %@ radius %@", categoryId, sectionId, noveltyId, radius);

    
    
}
- (void) processVenues: (NSInteger) searchType : (NSArray*) items : (NSError*) err
{
    [activityIndicator stopAnimating];
    //[venueScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
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
    //venueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];
    //[venueScrollView addSubview:venueView];
    
    // If there are no search results, throw up "Nothing found."
    if ([items count] == 0 || err) {

        if (err) {
            //no connection
            [checkinButton setTitle:@"No Service" forState:UIControlStateDisabled];
            [self willPresentError:err];
        }
        else {
            //nothing nearby
            [checkinButton setTitle:@"Nothing Nearby" forState:UIControlStateDisabled];
            if (middleOfNowhere){
                [self bypassCheckin];
            }
            else [self willPresentError:[NSError errorWithDomain:kCLErrorDomain code:kCLErrorDeferredFailed userInfo:nil]];
        }
        
        //[venueView addSubview:nameLabel];
        rightScroll.enabled = NO;
        checkinButton.enabled = NO;
    }
    else{
        if (items.count > 1) rightScroll.enabled = YES;
        
        allVenues = [NSMutableArray arrayWithCapacity:itemsArrayLength];

        //int offset = 0;
        fsqannotations = [[NSMutableArray alloc] init];
        for (int i = 0; i < [items count]; i++) {
            
            NSDictionary *ven = [items objectAtIndex:i];
            NSString *vID = [ven objectForKey:@"id"];
            NSString *vName = [ven objectForKey:@"name"];
            NSString *address = [[ven objectForKey: @"location"]  objectForKey:@"address"];
            CGFloat latitude = [[[ven objectForKey: @"location"] objectForKey: @"lat"] floatValue];
            CGFloat longitude = [[[ven objectForKey: @"location"] objectForKey: @"lng"] floatValue];
            /*
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
            
            
            // capture events
            [nameButton addTarget:self action:@selector(launchCheckinVC::) forControlEvents:UIControlEventTouchDown];
            
            // add it to the content view
            [venueView addSubview:venueDetailNib];
             
            */
            NSLog(@"venue %d %@", i, vName);
            [allVenues addObject:ven];
            
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
            //[foursquareAnnotation setIconUrl:iconURL];
            [foursquareAnnotation setArrayPos:((unsigned int) i)];
            
            // add the annotation object to the container
            [fsqannotations addObject: foursquareAnnotation];
            
        }
        //[mvFoursquare addAnnotations: annotations];
        [mvFoursquare addAnnotation: [fsqannotations objectAtIndex:0]];
        checkinButton.enabled = YES;
    }
    [venueScrollView.subviews makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    self.venueSVPos = 0;


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
#pragma mark - Load/Unload methods

- (void) handleSingleTap:(UIGestureRecognizer *)sender
{
    tapNumber++;
    NSLog(@"tapnumber = %d", tapNumber);
    //NSLog(@"labelfontsize1 = %f, labelfontsize2 = %f, labelfontsize3 = %f", tapLabel1.font.pointSize, tapLabel2.font.pointSize, tapLabel3.font.pointSize);
    switch (tapNumber) {
        
        case 1:
        {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                lockedTapImage.alpha = 0;
                lockedTapImageText.alpha = 0;
            } completion:^(BOOL finished) {
                [lockedTapImage removeFromSuperview];
                [lockedTapImageText removeFromSuperview];
                [self resetTapView:false];
                [self tapSpriteAdvancer:tapNumber];
            }];
        }
            break;
         
        default:
        {
            [self tapSpriteAdvancer:tapNumber];
        }
            break;
            
        
    }
}
- (void) tapSpriteAdvancer: (unsigned int) tapNum
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        NSLog(@"displaying ios6 tap texts");
        if ([movieName isEqualToString:@"01_Intro"])
        {
            //NSLog(@"hiih");
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"HIT ME";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:40]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y);
                }
                    break;
                    
                case 2:
                {
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:200]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y - 30);
                    
                }
                    break;
                case 3:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"BANG!";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:28]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x + 20,tapLabel1.center.y );
                    
                }
                    break;
                case 4:
                {
                    tapLabel1.text = @"BANG! Your tap";
                    
                }
                    break;
                case 5:
                {
                    tapLabel1.text = @"BANG! Your tap is the trigger.";
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"easy, partner.";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:170]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y+70);
                }
                    break;
                    
                case 7:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"I think you got it.";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:30]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y);
                }
                    break;
                    
                case 8:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"this is a                 movie.";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:25]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y);
                    
                    tapLabel2.text = @"tappable";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:25]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x+3, tapLabel1.center.y + 2);
                }
                    break;
                    
                case 9:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"STARRING";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:170]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-30);
                    
                }
                    break;
                    
                case 10:
                {
                    [self resetTapView:false];
                    [lockedTapImage removeFromSuperview];
                    [lockedTapImageText removeFromSuperview];
                    tapLabel1.text = @"Eden Brolin";
                    tapLabel1.textAlignment = NSTextAlignmentRight;
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:30]];
                    tapLabel1.center = CGPointMake(0, tapLabel1.center.y-40);
                    
                    tapLabel2.text = @"as Lady Land";
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:30]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+30);
                    
                    tapImage1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-01_eden.jpg"]];
                    tapImage1.frame = CGRectMake(tapView.bounds.size.width/2, 0, tapImage1.image.size.width/1.2, tapImage1.image.size.height/1.2);
                    [tapView addSubview:tapImage1];
                    tapImage1.layer.cornerRadius = 17.0;
                    tapImage1.layer.masksToBounds = YES;
                    
                }
                    break;
                    
                case 11:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"Justin Johnson";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:30]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x*2, tapLabel1.center.y-40);
                    
                    tapLabel2.text = @"The Sheriff";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:30]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+30);
                    
                    tapImage1.image = [UIImage imageNamed:@"intro-02_bearClaw.jpg"];
                    tapImage1.frame = CGRectMake(40, 0, tapImage1.image.size.width/1.2, tapImage1.image.size.height/1.2);
                    [tapView addSubview:tapImage1];
                    
                    
                }
                    break;
                    
                case 12:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"Rich Awn";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:30]];
                    tapLabel1.center = CGPointMake(0, tapLabel1.center.y-40);
                    tapLabel1.textAlignment = NSTextAlignmentRight;
                    
                    tapLabel2.text = @"The Seersucker";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:30]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+30);
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    
                    
                    tapImage1.image = [UIImage imageNamed:@"intro-03_rich.jpg"];
                    tapImage1.frame = CGRectMake(tapView.bounds.size.width/2, 0, tapImage1.image.size.width/1.2, tapImage1.image.size.height/1.2);
                    [tapView addSubview:tapImage1];
                }
                    break;
                    
                case 13:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"James Brolin";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:30]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x*2, tapLabel1.center.y-40);
                    
                    tapLabel2.text = @"The Storyteller";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:30]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+30);
                    
                    tapImage1.image = [UIImage imageNamed:@"intro-04_james.jpg"];
                    tapImage1.frame = CGRectMake(40, 0, tapImage1.image.size.width/1.2, tapImage1.image.size.height/1.2);
                    [tapView addSubview:tapImage1];
                }
                    break;
                    
                case 14:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"Made by";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:30]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+75);
                    
                    tapLabel2.text = @"Goddamn Cobras Collective";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:30]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+30);
                    
                    tapImage1.image = [UIImage imageNamed:@"intro-05_cobras.jpg"];
                    tapImage1.frame = CGRectMake(50, -10, tapImage1.image.size.width, tapImage1.image.size.height);
                    [tapView addSubview:tapImage1];
                }
                    break;
                    
                case 15:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"Let's give this a shot.";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:60]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y);
                }
                    break;
                    
                case 16:
                {
                    [self removeTapView];
                    [self animateRewards:2 :YES];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"02_TheDeal"])
        {
            //NSLog(@"hiih");
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"so tell me";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:170]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-30);
                }
                    break;
                    
                case 2:
                {
                    tapLabel2.text = @"have you ever had to";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:28]];
                    tapLabel2.center = CGPointMake(tapLabel2.center.x,tapLabel1.center.y + 70);
                    
                }
                    break;
                case 3:
                {
                    tapLabel3.text = @"sell your soul?";
                    [tapLabel3 setFont:[UIFont fontWithName:@"Rockwell" size:28]];
                    tapLabel3.textAlignment = NSTextAlignmentRight;
                    tapLabel3.center = CGPointMake(tapLabel2.center.x,tapLabel2.center.y - 1.6);
                    
                }
                    break;
                case 4:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"what's it";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:28]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+84,tapView.bounds.size.height-40);
                    
                    tapLabel2.text = @"worth";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:28]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x,tapLabel1.center.y-1.6);
                    
                }
                    break;
                case 5:
                {
                    tapLabel3.text = @"to you?";
                    [tapLabel3 setFont:[UIFont fontWithName:@"Rockwell-Light" size:28]];
                    tapLabel3.textAlignment = NSTextAlignmentRight;
                    tapLabel3.center = CGPointMake(tapLabel3.center.x-94,tapLabel1.center.y);
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"would you strike a";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:40]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                    
                    tapLabel2.text = @"deal?";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:40]];
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x - 8,tapLabel1.center.y+3.6);
                }
                    break;
                    
                case 7:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"IF YOU DO";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:170]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-30);
                }
                    break;
                    
                case 8:
                {
                    tapLabel2.text = @"you better be damn sure to get a receipt";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:25]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y + 70);
                }
                    break;
                    
                case 9:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"03_Bar"])
        {
            //NSLog(@"hiih");
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"the devil";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:30]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                    
                }
                    break;
                    
                case 2:
                {
                    tapLabel2.text = @"wears many disguises.";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:30]];
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x - 12,tapLabel1.center.y - 4);
                    
                }
                    break;
                case 3:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"but the most cunning of all";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:24]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapView.bounds.size.height-15);
                    
                }
                    break;
                case 4:
                {
                    tapLabel1.text = @"but the most cunning of all...";
                    
                }
                    break;
                case 5:
                {
                    tapLabel1.text = @"but the most cunning of all...is his smile.";
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"SO WHEN YOU MEET HIM";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:50]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-20);
                }
                    break;
                    
                case 7:
                {
                    tapLabel2.text = @"keep a straight face";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:60]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+50);
                }
                    break;
                    
                case 8:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"because everyone falls";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:45]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-20);
                }
                    break;
                    
                case 9:
                {
                    tapLabel2.text = @"for the man buying drinks";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:40]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y + 40);
                }
                    break;
                    
                case 10:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"04_GasStation"])
        {
            //NSLog(@"hiih"); 04_GasStation
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"travelers need to ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:21]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                    
                    tapLabel2.text = @"fill up";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:21]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x - 29,tapLabel1.center.y + 2.4);
                    
                }
                    break;
                    
                case 2:
                {
                    tapLabel1.text = @"travelers need to            before splitting town.";
                    
                }
                    break;
                case 3:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"don't let him";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:170]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-60);
                    
                }
                    break;
                case 4:
                {
                    tapLabel2.text = @"get away";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:58]];
                    tapLabel2.center = CGPointMake(tapLabel2.center.x,tapLabel1.center.y + 90);
                    
                }
                    break;
                case 5:
                {
                    tapLabel2.text = @"get away just yet";
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"show him what his money's worth";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:20]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+10,tapLabel1.center.y);
                }
                    break;
                    
                case 7:
                {
                    tapLabel2.text = @" in ";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:20]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x+305,tapLabel1.center.y+2.6);
                }
                    break;
                    
                case 8:
                {
                    tapLabel2.text = @" in this ";
                }
                    break;
                    
                case 9:
                {
                    tapLabel2.text = @" in this town.";
                }
                    break;
                    
                case 10:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"and see if there's something else";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:50]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-5);
                }
                    break;
                    
                case 11:
                {
                    tapLabel2.text = @"he can't resist...";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:66]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+50);
                }
                    break;
                    
                case 12:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"05_Riverbed"])
        {
            //NSLog(@"hiih"); 05_Riverbed
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"who can resist ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:32]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                }
                    break;
                    
                case 2:
                {
                    tapLabel1.text = @"who can resist a ";
                    tapLabel2.text = @"good baptism?";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:32]];
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x,tapLabel1.center.y + 4.4);
                    
                }
                    break;
                case 3:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"especially when";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:20]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+20,tapLabel1.center.y+90);
                    
                }
                    break;
                case 4:
                {
                    tapLabel1.text = @"especially when you're led";
                    
                }
                    break;
                case 5:
                {
                    tapLabel1.text = @"especially when you're led by the pants...";
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"when the edge of the river";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:60]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-50);
                }
                    break;
                    
                case 7:
                {
                    tapLabel2.text = @"is as slick as his smile,";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:26]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y+50);
                }
                    break;
                    
                case 8:
                {
                    tapLabel2.text = @"is as slick as his smile, he might just slip";
                }
                    break;
                    
                case 9:
                {
                    tapLabel3.text = @"right";
                    [tapLabel3 setFont:[UIFont fontWithName:@"Rockwell-bold" size:47]];
                    tapLabel3.center = CGPointMake(tapLabel1.center.x+3,tapLabel2.center.y+40);
                }
                    break;
                    
                case 10:
                {
                    tapLabel3.text = @"right into";
                }
                    break;
                    
                case 11:
                {
                    tapLabel3.text = @"right into your hands";
                }
                    break;
                    
                case 12:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"grab the deed";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:170]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-30);
                }
                    break;
                    
                case 13:
                {
                    tapLabel2.text = @"and while you're at it";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:26]];
                    tapLabel2.center = CGPointMake(tapLabel2.center.x,tapLabel1.center.y + 70);
                    
                }
                    break;
                    
                case 14:
                {
                    tapLabel2.text = @"and while you're at it...";
                    
                }
                    break;
                case 15:
                {
                    tapLabel3.text = @"give him a scare";
                    [tapLabel3 setFont:[UIFont fontWithName:@"Rockwell" size:26]];
                    tapLabel3.textAlignment = NSTextAlignmentRight;
                    tapLabel3.center = CGPointMake(tapLabel2.center.x,tapLabel2.center.y - 2.4);
                    
                }
                    break;
                    
                case 16:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"06_Rivernight"])
        {
            //NSLog(@"hiih"); 06_Rivernight
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"what ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:22]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+75,tapLabel1.center.y);
                }
                    break;
                    
                case 2:
                {
                    tapLabel1.text = @"what news ";
                }
                    break;
                case 3:
                {
                    tapLabel1.text = @"what news will ";
                }
                    break;
                case 4:
                {
                    tapLabel1.text = @"what news will wash up ";
                }
                    break;
                case 5:
                {
                    tapLabel1.text = @"what news will wash up later?";
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"you?";
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:25]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                }
                    break;
                    
                case 7:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"your itchy trigger finger?";
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:70]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-10);
                }
                    break;
                    
                case 8:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"NEWS TRAVELS FAST";
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:70]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-40);
                }
                    break;
                    
                case 9:
                {
                    tapLabel2.text = @"you better get ahead of it";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:47]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y+55);
                }
                    break;
                    
                case 10:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"07_DesertChase"])
        {
            //NSLog(@"hiih"); 07_DesertChase
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"you took it ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:24]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+5,tapLabel1.center.y);
                }
                    break;
                    
                case 2:
                {
                    tapLabel1.text = @"you took it            .";
                    tapLabel2.text = @"too far";
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:24]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x-70,tapLabel1.center.y+3.2);
                }
                    break;
                case 3:
                {
                    tapLabel1.text = @"you took it            . now they're on to you.";
                }
                    break;
                case 4:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"they want justice ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:26]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x-2,tapLabel1.center.y);
                }
                    break;
                    
                case 5:
                {
                    //tapLabel1.text = @"they want justice the ";
                    tapLabel2.text = @"the old-fashioned way";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:25]];
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x+2,tapLabel1.center.y + 3.2);
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"PACK YOUR BAGS";
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:80]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-10);
                }
                    break;
                    
                case 7:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"you're not going to see ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:24]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                    
                    tapLabel2.text = @"home";
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:24]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x+62,tapLabel1.center.y+3.2);
                }
                    break;
                    
                case 8:
                {
                    tapLabel1.text = @"you're not going to see            for awhile";
                    
                }
                    break;
                    
                case 9:
                {
                    [self resetTapView:false];
                    tapLabel2.text = @"what about ";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:47]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x+15,tapLabel1.center.y+70);
                }
                    break;
                    
                case 10:
                {
                    tapLabel2.text = @"what about mexico?";
                }
                    break;
                    
                case 11:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"08_DesertLynch"])
        {
            //NSLog(@"hiih"); 08_DesertLynch
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"WATER";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:44]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-70);
                }
                    break;
                    
                case 2:
                {
                    tapLabel1.text = @"WATER SLEEP";
                }
                    break;
                case 3:
                {
                    tapLabel1.text = @"WATER SLEEP SHADE";
                }
                    break;
                case 4:
                {
                    tapLabel2.text = @"WATER";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:40]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x+18,tapLabel2.center.y);
                }
                    break;
                    
                case 5:
                {
                    tapLabel2.text = @"WATER SLEEP";
                    
                }
                    break;
                    
                case 6:
                {
                    tapLabel2.text = @"WATER SLEEP SHADE";
                }
                    break;
                    
                case 7:
                {
                    tapLabel3.text = @"WATER";
                    [tapLabel3 setFont:[UIFont fontWithName:@"Rockwell" size:36]];
                    tapLabel3.center = CGPointMake(tapLabel2.center.x+22,tapLabel2.center.y + 70);
                }
                    break;
                    
                case 8:
                {
                    tapLabel3.text = @"WATER SLEEP";
                    
                }
                    break;
                    
                case 9:
                {
                    tapLabel3.text = @"WATER SLEEP SHADE";
                }
                    break;
                    
                case 10:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"sounds so good right now";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:24]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+30,tapLabel1.center.y+110);
                }
                    break;
                    
                case 11:
                {
                    tapLabel1.text = @"sounds so good right now doesn't it?";
                }
                    break;
                    
                case 12:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"did you make it";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:32]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+20,tapLabel1.center.y);
                }
                    break;
                    
                case 13:
                {
                    tapLabel1.text = @"did you make it far enough?";
                }
                    break;
                    
                case 14:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"09_Campfire"])
        {
            //NSLog(@"hiih"); 09_Campfire
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"so tell me";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:170]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-30);
                }
                    break;
                    
                case 2:
                {
                    tapLabel2.text = @"LADY LAND,";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:28]];
                    tapLabel2.center = CGPointMake(tapLabel2.center.x,tapLabel1.center.y + 70);
                    
                }
                    break;
                case 3:
                {
                    tapLabel2.text = @"LADY LAND, was she good to you?";
                    //[tapLabel3 setFont:[UIFont fontWithName:@"Rockwell" size:28]];
                    //tapLabel3.textAlignment = NSTextAlignmentRight;
                    //tapLabel3.center = CGPointMake(tapLabel2.center.x,tapLabel2.center.y - 1.6);
                    
                }
                    break;
                case 4:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"was it worth the good fight?";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:22]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                }
                    break;
                    
                case 5:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"was it worth the cost of home?";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:30]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"DEAD";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:64]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+5,tapLabel1.center.y-25);
                }
                    break;
                    
                case 7:
                {
                    tapLabel1.text = @"DEAD BURIED";
                }
                    break;
                    
                case 8:
                {
                    tapLabel2.text = @"who's land is it now?";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:46]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y+50);
                    
                }
                    break;
                    
                case 9:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"WILD";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:56]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-25);
                }
                    break;
                    
                case 10:
                {
                    tapLabel1.text = @"WILD UNTAMED";
                }
                    break;
                    
                case 11:
                {
                    tapLabel2.text = @"did you catch her?";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:53]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y+50);
                    
                }
                    break;
                    
                case 12:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"did you catch her?";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:22]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                }
                    break;
                    
                case 13:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"at least tell me";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:21]];
                }
                    break;
                    
                case 14:
                {
                    tapLabel2.text = @"you got a good story out of it...";
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:22]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-1.8);
                }
                    break;
                    
                case 15:
                {
                    [self removeTapView];
                    [self animateRewards:2 :YES];
                }
                    break;
            }
        }
    }
    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        //NSLog(@"displaying ios7 tap texts");
        if ([movieName isEqualToString:@"01_Intro"])
        {
            //NSLog(@"hiih");
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"HIT ME";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:40]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y);
                }
                    break;
                    
                case 2:
                {
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:200]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y - 30);
                    
                }
                    break;
                case 3:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"BANG!";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:28]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x + 20,tapLabel1.center.y );
                    
                }
                    break;
                case 4:
                {
                    tapLabel1.text = @"BANG! Your tap";
                    
                }
                    break;
                case 5:
                {
                    tapLabel1.text = @"BANG! Your tap is the trigger.";
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"easy, partner.";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:170]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y+70);
                }
                    break;
                    
                case 7:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"I think you got it.";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:30]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y);
                }
                    break;
                    
                case 8:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"this is a                 movie.";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:25]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y);
                    
                    tapLabel2.text = @"tappable";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:25]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x+3, tapLabel1.center.y + 2);
                }
                    break;
                    
                case 9:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"STARRING";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:170]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-30);
                    
                }
                    break;
                    
                case 10:
                {
                    [self resetTapView:false];
                    [lockedTapImage removeFromSuperview];
                    [lockedTapImageText removeFromSuperview];
                    tapLabel1.text = @"Eden Brolin";
                    tapLabel1.textAlignment = NSTextAlignmentRight;
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:30]];
                    tapLabel1.center = CGPointMake(0, tapLabel1.center.y-40);
                    
                    tapLabel2.text = @"as Lady Land";
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:30]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+30);
                    
                    tapImage1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"intro-01_eden.jpg"]];
                    tapImage1.frame = CGRectMake(tapView.bounds.size.width/2, 0, tapImage1.image.size.width/1.2, tapImage1.image.size.height/1.2);
                    [tapView addSubview:tapImage1];
                    tapImage1.layer.cornerRadius = 17.0;
                    tapImage1.layer.masksToBounds = YES;
                    
                }
                    break;
                    
                case 11:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"Justin Johnson";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:30]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x*2, tapLabel1.center.y-40);
                    
                    tapLabel2.text = @"The Sheriff";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:30]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+30);
                    
                    tapImage1.image = [UIImage imageNamed:@"intro-02_bearClaw.jpg"];
                    tapImage1.frame = CGRectMake(40, 0, tapImage1.image.size.width/1.2, tapImage1.image.size.height/1.2);
                    [tapView addSubview:tapImage1];
                    
                    
                }
                    break;
                    
                case 12:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"Rich Awn";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:30]];
                    tapLabel1.center = CGPointMake(0, tapLabel1.center.y-40);
                    tapLabel1.textAlignment = NSTextAlignmentRight;
                    
                    tapLabel2.text = @"The Seersucker";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:30]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+30);
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    
                    
                    tapImage1.image = [UIImage imageNamed:@"intro-03_rich.jpg"];
                    tapImage1.frame = CGRectMake(tapView.bounds.size.width/2, 0, tapImage1.image.size.width/1.2, tapImage1.image.size.height/1.2);
                    [tapView addSubview:tapImage1];
                }
                    break;
                    
                case 13:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"James Brolin";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:30]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x*2, tapLabel1.center.y-40);
                    
                    tapLabel2.text = @"The Storyteller";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:30]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+30);
                    
                    tapImage1.image = [UIImage imageNamed:@"intro-04_james.jpg"];
                    tapImage1.frame = CGRectMake(40, 0, tapImage1.image.size.width/1.2, tapImage1.image.size.height/1.2);
                    [tapView addSubview:tapImage1];
                }
                    break;
                    
                case 14:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"Made by";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:30]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+75);
                    
                    tapLabel2.text = @"Goddamn Cobras Collective";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:30]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+30);
                    
                    tapImage1.image = [UIImage imageNamed:@"intro-05_cobras.jpg"];
                    tapImage1.frame = CGRectMake(50, -10, tapImage1.image.size.width, tapImage1.image.size.height);
                    [tapView addSubview:tapImage1];
                }
                    break;
                    
                case 15:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"Let's give this a shot.";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:40]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y);
                }
                    break;
                    
                case 16:
                {
                    [self removeTapView];
                    [self animateRewards:2 :YES];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"02_TheDeal"])
        {
            //NSLog(@"hiih");
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"so tell me";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:170]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-30);
                }
                    break;
                    
                case 2:
                {
                    tapLabel2.text = @"have you ever had to";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:28]];
                    tapLabel2.center = CGPointMake(tapLabel2.center.x,tapLabel1.center.y + 70);
                    
                }
                    break;
                case 3:
                {
                    tapLabel3.text = @"sell your soul?";
                    [tapLabel3 setFont:[UIFont fontWithName:@"Rockwell" size:27]];
                    tapLabel3.textAlignment = NSTextAlignmentRight;
                    tapLabel3.center = CGPointMake(tapLabel2.center.x-12,tapLabel2.center.y - 1.6);
                    
                }
                    break;
                case 4:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"what's it";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:28]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+84,tapView.bounds.size.height-40);
                    
                    tapLabel2.text = @"worth";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:28]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x,tapLabel1.center.y-2.6);
                    
                }
                    break;
                case 5:
                {
                    tapLabel3.text = @"to you?";
                    [tapLabel3 setFont:[UIFont fontWithName:@"Rockwell-Light" size:28]];
                    tapLabel3.textAlignment = NSTextAlignmentRight;
                    tapLabel3.center = CGPointMake(tapLabel3.center.x-94,tapLabel1.center.y);
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"would you strike a";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:40]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                    
                    tapLabel2.text = @"deal?";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:38]];
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x - 13,tapLabel1.center.y+4.8);
                }
                    break;
                    
                case 7:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"IF YOU DO";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:170]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-30);
                }
                    break;
                    
                case 8:
                {
                    tapLabel2.text = @"you better be damn sure to get a receipt";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:25]];
                    tapLabel2.adjustsFontSizeToFitWidth = YES;
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y + 70);
                }
                    break;
                    
                case 9:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"03_Bar"])
        {
            //NSLog(@"hiih");
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"the devil";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:30]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                    
                }
                    break;
                    
                case 2:
                {
                    tapLabel2.text = @"wears many disguises.";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:30]];
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x - 12,tapLabel1.center.y - 3.6);
                    
                }
                    break;
                case 3:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"but the most cunning of all";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:24]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapView.bounds.size.height-15);
                    
                }
                    break;
                case 4:
                {
                    tapLabel1.text = @"but the most cunning of all...";
                    
                }
                    break;
                case 5:
                {
                    tapLabel1.text = @"but the most cunning of all...is his smile.";
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"SO WHEN YOU MEET HIM";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:50]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-20);
                }
                    break;
                    
                case 7:
                {
                    tapLabel2.text = @"keep a straight face";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:60]];
                    tapLabel2.adjustsFontSizeToFitWidth = YES;
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+50);
                }
                    break;
                    
                case 8:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"because everyone falls";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:45]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-20);
                }
                    break;
                    
                case 9:
                {
                    tapLabel2.text = @"for the man buying drinks";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:40]];
                    tapLabel2.adjustsFontSizeToFitWidth = YES;
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y + 40);
                }
                    break;
                    
                case 10:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"04_GasStation"])
        {
            //NSLog(@"hiih"); 04_GasStation
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"travelers need to ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:21]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                    
                    tapLabel2.text = @"fill up";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:20]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x - 30,tapLabel1.center.y + 3.2);
                    
                }
                    break;
                    
                case 2:
                {
                    tapLabel1.text = @"travelers need to            before splitting town.";
                    
                }
                    break;
                case 3:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"don't let him";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:170]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-60);
                    
                }
                    break;
                case 4:
                {
                    tapLabel2.text = @"get away";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:57]];
                    tapLabel2.center = CGPointMake(tapLabel2.center.x,tapLabel1.center.y + 90);
                    
                }
                    break;
                case 5:
                {
                    tapLabel2.text = @"get away just yet";
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"show him what his money's worth";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:20]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+10,tapLabel1.center.y);
                }
                    break;
                    
                case 7:
                {
                    tapLabel2.text = @" in ";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:19]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x+305,tapLabel1.center.y+2.0);
                }
                    break;
                    
                case 8:
                {
                    tapLabel2.text = @" in this ";
                }
                    break;
                    
                case 9:
                {
                    tapLabel2.text = @" in this town.";
                }
                    break;
                    
                case 10:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"and see if there's something else";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:50]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-5);
                }
                    break;
                    
                case 11:
                {
                    tapLabel2.text = @"he can't resist...";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:66]];
                    tapLabel2.adjustsFontSizeToFitWidth = YES;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y+50);
                }
                    break;
                    
                case 12:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"05_Riverbed"])
        {
            //NSLog(@"hiih"); 05_Riverbed
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"who can resist ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:32]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                }
                    break;
                    
                case 2:
                {
                    tapLabel1.text = @"who can resist a ";
                    tapLabel2.text = @"good baptism?";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:31]];
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x-8,tapLabel1.center.y + 3.9);
                    
                }
                    break;
                case 3:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"especially when";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:20]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+20,tapLabel1.center.y+90);
                    
                }
                    break;
                case 4:
                {
                    tapLabel1.text = @"especially when you're led";
                    
                }
                    break;
                case 5:
                {
                    tapLabel1.text = @"especially when you're led by the pants...";
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"when the edge of the river";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:60]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-50);
                }
                    break;
                    
                case 7:
                {
                    tapLabel2.text = @"is as slick as his smile,";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:25]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y+50);
                }
                    break;
                    
                case 8:
                {
                    tapLabel2.text = @"is as slick as his smile, he might just slip";
                }
                    break;
                    
                case 9:
                {
                    tapLabel3.text = @"right";
                    [tapLabel3 setFont:[UIFont fontWithName:@"Rockwell-bold" size:47]];
                    tapLabel3.center = CGPointMake(tapLabel1.center.x,tapLabel2.center.y+45);
                }
                    break;
                    
                case 10:
                {
                    tapLabel3.text = @"right into";
                }
                    break;
                    
                case 11:
                {
                    tapLabel3.text = @"right into your hands";
                }
                    break;
                    
                case 12:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"grab the deed";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:170]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+10, tapLabel1.center.y-50);
                }
                    break;
                    
                case 13:
                {
                    tapLabel2.text = @"and while you're at it";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-Light" size:25]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y + 70);
                    
                }
                    break;
                    
                case 14:
                {
                    tapLabel2.text = @"and while you're at it...";
                    
                }
                    break;
                case 15:
                {
                    tapLabel2.text = @"and while you're at it...give him a scare";
                    
                }
                    break;
                    
                case 16:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"06_Rivernight"])
        {
            //NSLog(@"hiih"); 06_Rivernight
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"what ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:22]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+75,tapLabel1.center.y);
                }
                    break;
                    
                case 2:
                {
                    tapLabel1.text = @"what news ";
                }
                    break;
                case 3:
                {
                    tapLabel1.text = @"what news will ";
                }
                    break;
                case 4:
                {
                    tapLabel1.text = @"what news will wash up ";
                }
                    break;
                case 5:
                {
                    tapLabel1.text = @"what news will wash up later?";
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"you?";
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:25]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                }
                    break;
                    
                case 7:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"your itchy trigger finger?";
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:70]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-10);
                }
                    break;
                    
                case 8:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"NEWS TRAVELS FAST";
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:70]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-40);
                }
                    break;
                    
                case 9:
                {
                    tapLabel2.text = @"you better get ahead of it";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:44]];
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    tapLabel2.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y+55);
                }
                    break;
                    
                case 10:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"07_DesertChase"])
        {
            //NSLog(@"hiih"); 07_DesertChase
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"you took it ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:24]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+5,tapLabel1.center.y);
                }
                    break;
                    
                case 2:
                {
                    tapLabel1.text = @"you took it            .";
                    tapLabel2.text = @"too far";
                    tapLabel2.textAlignment = NSTextAlignmentCenter;
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:23]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x-70,tapLabel1.center.y+2.5);
                }
                    break;
                case 3:
                {
                    tapLabel1.text = @"you took it            .  now they're on to you.";
                }
                    break;
                case 4:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"they want justice ";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:26]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                }
                    break;
                    
                case 5:
                {
                    //tapLabel1.text = @"they want justice the ";
                    tapLabel2.text = @"the old-fashioned way";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:25]];
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    tapLabel2.center = CGPointMake(tapLabel2.center.x-2,tapLabel1.center.y + 2.8);
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"PACK YOUR BAGS";
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:80]];
                    tapLabel1.adjustsFontSizeToFitWidth = YES;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-10);
                }
                    break;
                    
                case 7:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"you're not going to see home";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:24]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                    
                    
                }
                    break;
                    
                case 8:
                {
                    tapLabel1.text = @"you're not going to see home for awhile";
                    
                }
                    break;
                    
                case 9:
                {
                    [self resetTapView:false];
                    tapLabel2.text = @"what about ";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell-bold" size:47]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x+15,tapLabel1.center.y+70);
                }
                    break;
                    
                case 10:
                {
                    tapLabel2.text = @"what about mexico?";
                }
                    break;
                    
                case 11:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"08_DesertLynch"])
        {
            //NSLog(@"hiih"); 08_DesertLynch
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"WATER";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:44]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-70);
                }
                    break;
                    
                case 2:
                {
                    tapLabel1.text = @"WATER SLEEP";
                }
                    break;
                case 3:
                {
                    tapLabel1.text = @"WATER SLEEP SHADE";
                }
                    break;
                case 4:
                {
                    tapLabel2.text = @"WATER";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:40]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x+18,tapLabel2.center.y);
                }
                    break;
                    
                case 5:
                {
                    tapLabel2.text = @"WATER SLEEP";
                    
                }
                    break;
                    
                case 6:
                {
                    tapLabel2.text = @"WATER SLEEP SHADE";
                }
                    break;
                    
                case 7:
                {
                    tapLabel3.text = @"WATER";
                    [tapLabel3 setFont:[UIFont fontWithName:@"Rockwell" size:36]];
                    tapLabel3.center = CGPointMake(tapLabel2.center.x+22,tapLabel2.center.y + 70);
                }
                    break;
                    
                case 8:
                {
                    tapLabel3.text = @"WATER SLEEP";
                    
                }
                    break;
                    
                case 9:
                {
                    tapLabel3.text = @"WATER SLEEP SHADE";
                }
                    break;
                    
                case 10:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"sounds so good right now";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:24]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+30,tapLabel1.center.y+110);
                }
                    break;
                    
                case 11:
                {
                    tapLabel1.text = @"sounds so good right now doesn't it?";
                }
                    break;
                    
                case 12:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"did you make it";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:32]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+20,tapLabel1.center.y);
                }
                    break;
                    
                case 13:
                {
                    tapLabel1.text = @"did you make it far enough?";
                }
                    break;
                    
                case 14:
                {
                    [self removeTapView];
                }
                    break;
            }
        }
        else if ([movieName isEqualToString:@"09_Campfire"])
        {
            //NSLog(@"hiih"); 09_Campfire
            
            switch (tapNum) {
                case 1:
                {
                    tapLabel1.text = @"so tell me";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:170]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x, tapLabel1.center.y-30);
                }
                    break;
                    
                case 2:
                {
                    tapLabel2.text = @"LADY LAND,";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:28]];
                    tapLabel2.center = CGPointMake(tapLabel2.center.x,tapLabel1.center.y + 70);
                    
                }
                    break;
                case 3:
                {
                    tapLabel2.text = @"LADY LAND, was she good to you?";
                    //[tapLabel3 setFont:[UIFont fontWithName:@"Rockwell" size:28]];
                    //tapLabel3.textAlignment = NSTextAlignmentRight;
                    //tapLabel3.center = CGPointMake(tapLabel2.center.x,tapLabel2.center.y - 1.6);
                    
                }
                    break;
                case 4:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"was it worth the good fight?";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:22]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                }
                    break;
                    
                case 5:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"was it worth the cost of home?";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell" size:30]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                    
                }
                    break;
                    
                case 6:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"DEAD";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:64]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x+5,tapLabel1.center.y-25);
                }
                    break;
                    
                case 7:
                {
                    tapLabel1.text = @"DEAD BURIED";
                }
                    break;
                    
                case 8:
                {
                    tapLabel2.text = @"who's land is it now?";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:46]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y+50);
                    
                }
                    break;
                    
                case 9:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"WILD";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:56]];
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y-25);
                }
                    break;
                    
                case 10:
                {
                    tapLabel1.text = @"WILD UNTAMED";
                }
                    break;
                    
                case 11:
                {
                    tapLabel2.text = @"did you catch her?";
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:53]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y+50);
                    
                }
                    break;
                    
                case 12:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"did you catch her?";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-Light" size:22]];
                    tapLabel1.textAlignment = NSTextAlignmentCenter;
                    tapLabel1.center = CGPointMake(tapLabel1.center.x,tapLabel1.center.y);
                }
                    break;
                    
                case 13:
                {
                    [self resetTapView:false];
                    tapLabel1.text = @"at least tell me";
                    [tapLabel1 setFont:[UIFont fontWithName:@"Rockwell-bold" size:21]];
                }
                    break;
                    
                case 14:
                {
                    tapLabel2.text = @"you got a good story out of it...";
                    tapLabel2.textAlignment = NSTextAlignmentRight;
                    [tapLabel2 setFont:[UIFont fontWithName:@"Rockwell" size:22]];
                    tapLabel2.center = CGPointMake(tapLabel1.center.x-2,tapLabel1.center.y-2.4);
                }
                    break;
                    
                case 15:
                {
                    [self removeTapView];
                    [self animateRewards:2 :YES];
                }
                    break;
            }
        }
    }
    
}

- (void) resetTapView: (BOOL) fromStart
{
    if (fromStart) {
        [tapView addSubview:lockedTapImage];
        [tapView addSubview:lockedTapImageText];
        lockedTapImage.alpha = 1;
        lockedTapImageText.alpha = 1;
    }
    
    tapView.center = CGPointMake([UIScreen mainScreen].bounds.size.height/2, tapView.center.y);
    
    [tapLabel1 removeFromSuperview];
    [tapLabel2 removeFromSuperview];
    [tapLabel3 removeFromSuperview];
    [tapImage1 removeFromSuperview];
    
    CGRect labelRect = CGRectMake(0, 0, 450, 234);
    
    tapLabel1 = [[UILabel alloc] initWithFrame:labelRect];
    tapLabel1.center = CGPointMake(tapView.bounds.size.width/2, tapView.bounds.size.height/2);
    tapLabel1.textColor = redC;
    tapLabel1.backgroundColor = [UIColor clearColor];
    tapLabel1.numberOfLines = 1;
    tapLabel1.font = [UIFont fontWithName:@"Rockwell" size:50];
    tapLabel1.adjustsFontSizeToFitWidth = YES;
    tapLabel1.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    [tapView addSubview:tapLabel1];
    
    tapLabel2 = [[UILabel alloc] initWithFrame:labelRect];
    tapLabel2.center = CGPointMake(tapView.bounds.size.width/2, tapView.bounds.size.height/2);
    tapLabel2.textColor = redC;
    tapLabel2.backgroundColor = [UIColor clearColor];
    tapLabel2.numberOfLines = 1;
    tapLabel2.font = [UIFont fontWithName:@"Rockwell" size:50];
    tapLabel2.adjustsFontSizeToFitWidth = YES;
    tapLabel2.adjustsLetterSpacingToFitWidth = YES;
    tapLabel2.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    [tapView addSubview:tapLabel2];
    
    tapLabel3 = [[UILabel alloc] initWithFrame:labelRect];
    tapLabel3.center = CGPointMake(tapView.bounds.size.width/2, tapView.bounds.size.height/2);
    tapLabel3.textColor = redC;
    tapLabel3.backgroundColor = [UIColor clearColor];
    tapLabel3.numberOfLines = 1;
    tapLabel3.font = [UIFont fontWithName:@"Rockwell" size:50];
    tapLabel3.adjustsFontSizeToFitWidth = YES;
    tapLabel3.adjustsLetterSpacingToFitWidth = YES;
    tapLabel3.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    [tapView addSubview:tapLabel3];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        
        tapLabel1.adjustsLetterSpacingToFitWidth = YES;
        tapLabel2.adjustsLetterSpacingToFitWidth = YES;
        tapLabel3.adjustsLetterSpacingToFitWidth = YES;
    
    }
    
}
- (void) removeTapView
{
    [UIView animateWithDuration:0.5 animations:^{
        tapView.alpha = 0;
    } completion:^(BOOL finished) {
        [tapView removeFromSuperview];
        tappedOut = YES;
        [self refreshView];
    }];
    
}
- (void) handleDoubleTap:(UIGestureRecognizer *)sender
{
    NSLog(@"ignoring double tap");
}
- (void) starringTapButton;
{
    tappedOut = NO;
    [movieView removeFromSuperview];
    [self.view addSubview:tapView];
    tapView.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width/2 +25);
    tapNumber = 10;
    [self tapSpriteAdvancer:tapNumber];
    [UIView animateWithDuration:0.5 animations:^{
        tapView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void) animateRewards : (NSTimeInterval) duration : (BOOL) withVideo
{
    NSLog(@"hitting animate rewards");

    //check if it's already unlocked - it's playing twice at the moment
    if (duration ==1 ) {
        [[TumbleweedViewController sharedClient] playSystemSound:@"Good 3"];
    }
    
    [tapView removeFromSuperview];
    movieView.alpha = 0;
    [self.view addSubview:movieView];
    movieView.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width/2);
    [UIView animateWithDuration:duration animations:^{
        searchView.alpha = 0;
        movieView.alpha = 1;
        if ([[Tumbleweed sharedClient] successfulVenues].count > 0 && unlockCopy.hidden==NO)
        {
            NSLog(@"animate unlock");
            successfulVenueName = [[[Tumbleweed sharedClient] successfulVenues] objectAtIndex:_scene.level];
            unlockCopy.text = [NSString stringWithFormat:@"unlocked at: %@", successfulVenueName];
            if ([successfulVenueName isEqualToString:@""]) unlockCopy.text = [NSString stringWithFormat:@"uncovered"];
        }
    } completion:^(BOOL finished) {
        [searchView removeFromSuperview];
        searchView.alpha = 1;
        if (withVideo)[self playVideo:nil];
        
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
            case kCLErrorDeferredFailed:
                errorTitle = @"Nothing Nearby";
                errorMessage = [NSString stringWithFormat:@"You must be in the middle of nowhere. Hit the re-search button on the map when you're closer to %@.", categoryHint];
                middleOfNowhere = TRUE;
                break;
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
- (void) bypassCheckin
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Still Nothing Nearby"
                                                      message:[NSString stringWithFormat:@"Let's just say you are near %@ and call it a day?", categoryHint]
                                                     delegate:self
                                            cancelButtonTitle:@"Nahh"
                                            otherButtonTitles:@"Yup!", nil];
    [message show];
}
- (void) refreshView
{
    NSLog(@"refreshing view");
    tapNumber = 0;
    [self resetTapView:TRUE];
    checkinButton.enabled = false;
    
    if ([sceneTypeName isEqualToString:@"Empty"])
    {
        unlockCopy.hidden = YES;
        if ([movieName isEqualToString:@"01_Intro"])
        {
            UIImageView *tap2start = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap-to-start_scene.png"]];
            [lockedTapImage addSubview:tap2start];
            tap2start.center = CGPointMake(lockedTapImage.image.size.width, -15);
            if (!tappedOut) return;
            //so animate rewards doesn't fail
            [self animateRewards:0:NO];
            {
                UIButton *starringButton = [UIButton buttonWithType:UIButtonTypeCustom];
                starringButton.frame = CGRectMake(0, 0, 122, 40);
                starringButton.titleLabel.font = [UIFont fontWithName:@"rockwell-bold" size:20];
                starringButton.titleLabel.textColor = redC;
                starringButton.titleLabel.frame = starringButton.frame;
                
                [starringButton setBackgroundImage:[UIImage imageNamed:@"blank_button_Default.png"] forState:UIControlStateNormal];
                [starringButton setBackgroundImage:[UIImage imageNamed:@"blank_button_onPress.png"] forState:UIControlStateHighlighted];
                [starringButton setTitle:@"STARRING" forState:UIControlStateNormal&UIControlStateHighlighted];
                [starringButton setTitleColor:redC forState:UIControlStateNormal];
                [starringButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                
                [starringButton addTarget:self action:@selector(starringTapButton) forControlEvents:UIControlEventTouchUpInside];
                
                [movieView addSubview:starringButton];
                starringButton.center = CGPointMake(movieView.bounds.size.width/2, movieView.bounds.size.height-(starringButton.bounds.size.height/2 -3));
            }
        }
        else if ([movieName isEqualToString:@"09_Campfire"])
        {
            NSLog(@"in campfire");
            if (!tappedOut) return;
            [self animateRewards:0:NO];
            {
                UIButton *extrasButton = [UIButton buttonWithType:UIButtonTypeCustom];
                extrasButton.frame = CGRectMake(0, 0, 122, 40);
                extrasButton.titleLabel.font = [UIFont fontWithName:@"rockwell-bold" size:20];
                extrasButton.titleLabel.textColor = redC;
                extrasButton.titleLabel.frame = extrasButton.frame;
                
                [extrasButton setBackgroundImage:[UIImage imageNamed:@"blank_button_Default.png"] forState:UIControlStateNormal];
                [extrasButton setBackgroundImage:[UIImage imageNamed:@"blank_button_onPress.png"] forState:UIControlStateHighlighted];
                [extrasButton setTitle:@"EXTRAS" forState:UIControlStateNormal&UIControlStateHighlighted];
                [extrasButton setTitleColor:redC forState:UIControlStateNormal];
                [extrasButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [extrasButton addTarget:self action:@selector(launchBonusWebView) forControlEvents:UIControlEventTouchUpInside];
                [movieView addSubview:extrasButton];
                extrasButton.center = CGPointMake(movieView.bounds.size.width/2 - extrasButton.frame.size.width * 1.2, movieView.bounds.size.height-(extrasButton.bounds.size.height/2 -3));
                
                UIButton *fsqListButton = [UIButton buttonWithType:UIButtonTypeCustom];
                fsqListButton.frame = CGRectMake(0, 0, 122, 40);
                fsqListButton.titleLabel.font = [UIFont fontWithName:@"rockwell-bold" size:20];
                fsqListButton.titleLabel.textColor = redC;
                fsqListButton.titleLabel.frame = fsqListButton.frame;
                [fsqListButton setBackgroundImage:[UIImage imageNamed:@"blank_button_Default.png"] forState:UIControlStateNormal];
                [fsqListButton setBackgroundImage:[UIImage imageNamed:@"blank_button_onPress.png"] forState:UIControlStateHighlighted];
                [fsqListButton setTitle:@"MY PATH" forState:UIControlStateNormal&UIControlStateHighlighted];
                [fsqListButton setTitleColor:redC forState:UIControlStateNormal];
                [fsqListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [fsqListButton addTarget:self action:@selector(fsqListButton:) forControlEvents:UIControlEventTouchUpInside];
                [movieView addSubview:fsqListButton];
                fsqListButton.center = CGPointMake(movieView.bounds.size.width/2, movieView.bounds.size.height-(fsqListButton.bounds.size.height/2 -3));
                
                UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
                resetButton.frame = CGRectMake(0, 0, 122, 40);
                resetButton.titleLabel.font = [UIFont fontWithName:@"rockwell-bold" size:20];
                resetButton.titleLabel.textColor = redC;
                resetButton.titleLabel.frame = resetButton.frame;
                [resetButton setBackgroundImage:[UIImage imageNamed:@"blank_button_Default.png"] forState:UIControlStateNormal];
                [resetButton setBackgroundImage:[UIImage imageNamed:@"blank_button_onPress.png"] forState:UIControlStateHighlighted];
                [resetButton setTitle:@"RESET" forState:UIControlStateNormal&UIControlStateHighlighted];
                [resetButton setTitleColor:redC forState:UIControlStateNormal];
                [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [resetButton addTarget:self action:@selector(resetButton:) forControlEvents:UIControlEventTouchUpInside];
                [movieView addSubview:resetButton];
                resetButton.center = CGPointMake(movieView.bounds.size.width/2 + resetButton.frame.size.width * 1.2, movieView.bounds.size.height-(resetButton.bounds.size.height/2 -3));
                
                
            }
        }
    }
    else
    {
        if (_scene.level < [Tumbleweed sharedClient].tumbleweedLevel) [self animateRewards:0:NO];
        else {
            if (!tappedOut) return;
            [self.view addSubview:searchView];
            searchView.center = CGPointMake([[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width/2+18);
            [self searchSetup];
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
        
    unlockCopy.font = [UIFont fontWithName:@"rockwell" size:16];
    [unlockCopy setTextColor:beigeC];
    checkinInstructions.font = [UIFont fontWithName:@"Rockwell-Light" size:25];
    checkinInstructions.text = checkInCopy;
    [checkinInstructions setTextColor:brownC];
    sceneTitleIV.image = [UIImage imageNamed:[_scene.pListDetails objectForKey:@"movieTextOn"]];
    if ([_scene.pListDetails objectForKey:@"movieTextOff"]) {
        //[playButton setImage:[UIImage imageNamed:[_scene.pListDetails objectForKey:@"movieTextOff"]] forState:UIControlStateDisabled];
        lockedTapImageText.image = [UIImage imageNamed:[_scene.pListDetails objectForKey:@"movieTextOff"]];
    }
    [playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    checkinButton.titleLabel.font = [UIFont fontWithName:@"rockwell-bold" size:20];
    checkinButton.titleLabel.textColor = redC;
    checkinButton.titleLabel.frame = checkinButton.frame;    
    [checkinButton setTitle:@"Check In To Watch" forState:UIControlStateNormal&UIControlStateHighlighted];
    [checkinButton setTitle:@"Nothing Nearby" forState:UIControlStateDisabled];
    [checkinButton setTitleColor:redC forState:UIControlStateNormal];
    [checkinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [checkinButton setTitleColor:beigeC forState:UIControlStateDisabled];
    [checkinButton addTarget:self action:@selector(launchCheckinVC::) forControlEvents:UIControlEventTouchUpInside];

    
    //movieButton settings
    {
        NSString *imgName1 =[_scene.pListDetails objectForKey:@"movieButtonOn"];
        UIImage *buttonImg = [UIImage imageNamed:imgName1];
        [movieThumbnailButton setImage:buttonImg forState:UIControlStateNormal];
        
        if ([_scene.pListDetails objectForKey:@"movieButtonOff"]) {
            NSString *imgName3 =[_scene.pListDetails objectForKey:@"movieButtonOff"];
            UIImage *buttonImg3 = [UIImage imageNamed:imgName3];
            //[movieThumbnailButton setImage:buttonImg3 forState:UIControlStateDisabled];
            lockedTapImage.image = buttonImg3;
        }
        movieThumbnailButton.imageView.layer.masksToBounds = YES;
        movieThumbnailButton.imageView.layer.cornerRadius = 15.0;
    }
    
    //[self.view.layer setContents:(__bridge id)[[UIImage imageNamed:@"check-in_bg.jpg"] CGImage]];
    UIGraphicsBeginImageContext(CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width));
    [[UIImage imageNamed:@"check-in_bg.jpg"] drawInRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UITapGestureRecognizer *tapHandler = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
    tapHandler.numberOfTapsRequired = 1;
    [tapHandler setDelegate:self];
    [tapView addGestureRecognizer:tapHandler];
    
    //ignore double-tap
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleDoubleTap:)] ;
    doubleTap.numberOfTapsRequired = 2;
    [tapView addGestureRecognizer:doubleTap];
    //[tapHandler requireGestureRecognizerToFail:doubleTap];
    
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
    [Foursquare cancelSearchVenues];
    
    //[locationManager stopUpdatingLocation];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return (UIInterfaceOrientationLandscapeLeft
            | UIInterfaceOrientationLandscapeRight);
}

@end
