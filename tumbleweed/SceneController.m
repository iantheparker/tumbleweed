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




#define MINIMUM_ZOOM_ARC 0.008 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.0
#define MAP_LATITUDE_OFFSET .0014
#define MAX_DEGREES_ARC 360

typedef enum {
    kSceneEmpty,
    kSceneMap,
    kSceneTimer
} SceneType;

@interface SceneController()

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSString *movieName;
@property (nonatomic, retain) NSString *posterArt;
@property (nonatomic, retain) NSString *checkInCopy;
@property (nonatomic, retain) NSString *bonusUrl;
@property (nonatomic, assign) SceneType type;

@property (nonatomic) unsigned int venueSVPos;

-(void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated;
-(void) gameSavetNotif: (NSNotification *) notif;
-(void) refreshView;
-(void) launchCheckinVC: (NSDictionary*) dict;
-(IBAction) launchBonusWebView;
-(void) willPresentError:(NSError *)error;
-(void)updateTimer:(NSTimer *)timer;

@end


@implementation SceneController {
@private
    CLLocationCoordinate2D userCoordinate;
    NSTimer *countDownTimer;
    int currentTime;
    UIColor *redC;
    UIColor *brownC;
    
}
//plist properties
@synthesize name, categoryId, movieName, posterArt, checkInCopy, bonusUrl;
//map properties
@synthesize locationManager, mvFoursquare, pinsLoaded;
//checkin properties
@synthesize venueScrollView, venueDetailNib, venueView, allVenues, sceneSVView, leftScroll, rightScroll, venueSVPos, refreshButton, activityIndicator;
//generic properties
@synthesize sceneScrollView, sceneTitle, checkInIntructions, movieThumbnailButton, moviePlayer, extrasView;


- (id) initWithScene:(Scene *) scn
{
    self = [super init];
    // Did the superclass's designated initializer succeed?
    if (self) {
        _scene = scn;
        
        name = [scn.pListDetails objectForKey:@"name"];
        categoryId = [scn.pListDetails objectForKey:@"categoryId"];
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
    //[checkIn setModalTransitionStyle:UIModalTransitionStylePartialCurl];
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
}
- (IBAction)leftScroll:(id)sender
{
    self.venueSVPos -= 1;
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
    allVenues = nil;
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
        [nameLabel setTextColor:redC];
        [nameLabel setClearsContextBeforeDrawing:YES];
        [venueDetailNib setCenter:CGPointMake(nibwidth/2, nibheight/2)];
        [venueView addSubview:venueDetailNib];
        rightScroll.enabled = NO;
    }
    else{
        if (items.count > 1) rightScroll.enabled = YES;
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
            
            [[NSBundle mainBundle] loadNibNamed:@"ListItemScrollView" owner:self options:nil];
            
            UILabel *nameLabel = (UILabel *)[venueDetailNib viewWithTag:1];
            //UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, venueScrollView.frame.size.width, venueScrollView.frame.size.height)];
            [nameLabel setFont:[UIFont fontWithName:@"Rockwell" size:24]];
            //[nameLabel setTextAlignment:UITextAlignmentCenter];
            [nameLabel setText:vName];
            [nameLabel setTextColor:redC];
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
            [venueView setUserInteractionEnabled:YES];
            [venueDetailNib setUserInteractionEnabled:YES];
            
            // create and initialise the annotation
            FoursquareAnnotation *foursquareAnnotation = [[FoursquareAnnotation alloc] init];
            // create the map region for the coordinate
            MKCoordinateRegion region = { { latitude , longitude } , { 0.001f , 0.001f } };
            
            // set all properties with the necessary details
            [foursquareAnnotation setCoordinate: region.center];
            [foursquareAnnotation setTitle: vName];
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
}
- (void) animateRewards
{
    extrasView.hidden = NO;
    [UIView animateWithDuration:1 animations:^{
        CGSize screenSize = CGSizeMake(sceneSVView.bounds.size.width, 320);
        sceneScrollView.contentSize = screenSize;
        checkInIntructions.alpha = 0.0;
        mvFoursquare.layer.opacity = 0.0;
        searchView.layer.opacity = 0.0;
    } completion:^(BOOL finished) {
        [searchView removeFromSuperview];
        [checkInIntructions removeFromSuperview];
        [UIView transitionWithView:movieThumbnailButton
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            movieThumbnailButton.enabled = YES;
                            extrasView.alpha = 1.0;
                            
                        } completion:NULL];
    }];

}
- (void) refreshView
{

    if (_scene.level == [Tumbleweed weed].tumbleweedLevel) {
        // load up initial state
        //checkInIntructions.text = checkInCopy;
        movieThumbnailButton.enabled = NO;
        
        if (categoryId) {
            [self searchSetup];
            
        }
        else{
            //load alternate view
            
            if ([name isEqualToString:@"No Man's Land"] ||
                [name isEqualToString:@"The End"]) {
                [self animateRewards];
            }
            else{
                [searchView removeFromSuperview];
                currentTime = 3600;
                countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
                [timerLabel setFont:[UIFont fontWithName:@"Rockwell" size:26]];
                [timerLabel setTextColor:redC];
                timerLabel.hidden = NO;
                sceneScrollView.contentSize = CGSizeMake(sceneScrollView.contentSize.width, 320);
            }
        }
        
    }
    else{
        //load unlocked state
        [self animateRewards];
        
    }

}
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
    if (!locationManager){
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
    }
    [locationManager startUpdatingLocation];


}
-(void)updateTimer:(NSTimer *)timer {
    currentTime -= 1 ;
    [self populateLabelwithTime:currentTime];
    if(currentTime <=0)
        [countDownTimer invalidate];
    //NSLog(@"updatetimer");
}


- (void)populateLabelwithTime:(int)seconds {
    //int seconds = milliseconds/1000;
    int minutes = seconds / 60;
    int hours = minutes / 60;
    
    seconds -= minutes * 60;
    minutes -= hours * 60;
    
    NSString * result1 = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    timerLabel.text = result1;
    
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
    [locationManager stopUpdatingLocation];
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
    [locationManager stopUpdatingLocation];
    [self processVenues:nil :error];
    
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
        [annotationView setLeftCalloutAccessoryView:leftIcon];
        
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
        
        [self launchCheckinVC:[NSDictionary dictionaryWithObjectsAndKeys:
                               ((FoursquareAnnotation*)[view annotation]).venueId, @"id",
                               ((FoursquareAnnotation*)[view annotation]).title, @"name", nil]];
        
    }
}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    [self zoomMapViewToFitAnnotations:mapView animated:YES];

    for (id<MKAnnotation> currentAnnotation in mapView.annotations) {
        if ([currentAnnotation isKindOfClass:[FoursquareAnnotation class]]){
            if (((FoursquareAnnotation*)currentAnnotation).arrayPos == 0) {
                [mapView selectAnnotation:(FoursquareAnnotation*)currentAnnotation animated:YES];
                //NSLog(@"mv selected %@", [[mapView selectedAnnotations] objectAtIndex:0]);
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
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self refreshView];
    
    //set UIColors
    brownC = [UIColor colorWithRed:62.0/255.0 green:43.0/255.0 blue:26.0/255.0 alpha:1.0];
    redC = [UIColor colorWithRed:212.0/255.0 green:83.0/255.0 blue:88.0/255.0 alpha:1.0];
        
    sceneTitle.text = name;
    sceneTitle.font = [UIFont fontWithName:@"rockwell-bold" size:30];
    [sceneTitle setTextColor:brownC];
    checkInIntructions.font = [UIFont fontWithName:@"rockwell" size:18];
    [checkInIntructions setTextColor:brownC];
    checkInIntructions.text = checkInCopy;
    
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
    
    CGSize screenSize = CGSizeMake(sceneSVView.bounds.size.width, sceneSVView.bounds.size.height);
    sceneScrollView.contentSize = screenSize;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameSavetNotif:)
                                                 name:@"enteredBackground" object:nil];
     
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
