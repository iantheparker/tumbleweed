//
//  ViewController.m
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "TumbleweedViewController.h"
#import "SceneController.h"
#import "FoursquareAuthViewController.h"
#import "MCSpriteLayer.h"

@interface TumbleweedViewController() 

@property BOOL walkingForward;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) CALayer *map0CA;
@property (nonatomic, retain) CALayer *map1CA;
@property (nonatomic, retain) CALayer *map2CA;
@property (nonatomic, retain) CALayer *map4CA;
@property (nonatomic, retain) CALayer *janeAvatar;
@property (nonatomic, retain) UIView *mapCAView;
@property (nonatomic, retain) UIView *buttonContainer;
@property (nonatomic, retain) Tumbleweed *weed;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CALayer *blackPanel;

-(void)pauseLayer:(CALayer*)layer;
-(void)resumeLayer:(CALayer*)layer;
-(void) renderScreen: (BOOL) direction : (BOOL) moving;
-(CGRect) selectAvatarBounds:(float) position;
-(IBAction)toggleBlackPanel:(id)sender;

@end

@implementation TumbleweedViewController

@synthesize scrollView, map0CA, map1CA, map2CA, map4CA, mapCAView, janeAvatar, walkingForward, weed, locationManager;

//-- scene buttons
@synthesize foursquareConnectButton, introButton, gasStationButton, dealButton, barButton, riverBed1Button, riverBed2Button, desertChaseButton, desertLynchButton, campFireButton, buttonContainer, blackPanel;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        weed = [Tumbleweed weed];
        
        map0CA = [[CALayer alloc] init];
        map1CA = [[CALayer alloc] init];
        map2CA = [[CALayer alloc] init];
        map4CA = [[CALayer alloc] init];
        janeAvatar = [[CALayer alloc] init];
        mapCAView = [[UIView alloc] init];
        //buttonContainer = [[UIView alloc] init];
    }
    return self;
}

- (CGRect) selectAvatarBounds:(float) position
{
    static const CGRect sampleRects[7] = {
        
        {172, 0, 246, 465},
        {418, 0, 234, 467},
        {652, 0, 304, 465},
        {956, 0, 246, 471},
        {1202, 0, 234, 467},
        {1436, 0, 304, 465},
        {0, 0, 172, 463},       // still
    };
    
    //return still state
    if (position == -1)
        return sampleRects[6];

    int frameSize = 20;
    int imageCount = 6;
    int currentPosition = (int) position;
    unsigned int imageIndex = (currentPosition + (frameSize * imageCount)) % (frameSize * imageCount) / frameSize;
    return sampleRects[imageIndex];
}
- (void) saveAvatarPosition
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:scrollView.contentOffset.x forKey:@"scroll_view_position"];
    [defaults setBool:walkingForward forKey:@"walkingForward"];
    NSLog(@"saving Jane's position");
}
- (void) renderScreen: (BOOL) direction :(BOOL) moving
{
    double avatar_offset = 220;
    double janeLeftBound = 372;
    double janeRightBound = 5275;
    CGPoint center;
    CGRect bounds;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // if woken up and no avatar values, then set them
    //if (!janeAvatar.position.x) janeAvatar.position = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
    
    //set position
    if ([scrollView contentOffset].x <janeLeftBound - avatar_offset || [scrollView contentOffset].x >janeRightBound - avatar_offset || !moving)
    {
        bounds = [self selectAvatarBounds:-1];        
        if (janeAvatar.position.x <= janeLeftBound) center = CGPointMake(janeLeftBound, avatar_offset);
        else if (janeAvatar.position.x >= janeRightBound) center = CGPointMake(janeRightBound, avatar_offset);
        else center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
    }
    else {
        center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
        bounds = [self selectAvatarBounds:[scrollView contentOffset].x];
    }
    janeAvatar.bounds = CGRectMake(0, 0, bounds.size.width/2.5, bounds.size.height/2.5);
    janeAvatar.contentsRect = CGRectMake(bounds.origin.x/2048.0f, bounds.origin.y/512.0f, bounds.size.width/2048.0f, bounds.size.height/512.0f);
    
    [janeAvatar setPosition:center];
    
    //set direction
    if (!direction) {
        janeAvatar.transform = CATransform3DScale(CATransform3DMakeRotation(0, 0, 0, 1),
                                                  -1, 1, 1);
    }
    else {
        janeAvatar.transform = CATransform3DScale(CATransform3DMakeRotation(0, 0, 0, 1),
                                                  1, 1, 1);
    }
    
    //-sky position- CALayer - fix the hardcoded offset here
    CGPoint mapCenter = map1CA.position;
    float skyCoefficient = .9;
    float janeOffset = mapCenter.x - scrollView.contentOffset.x;
    CGPoint skyCenter = CGPointMake(avatar_offset+mapCenter.x - (janeOffset * skyCoefficient), [map0CA bounds].size.height/2.0);
    [map0CA setPosition:skyCenter];
    
    //--> mid-layer position
    float midlayerCoefficient = .02;
    CGPoint midlayerPos = CGPointMake(mapCenter.x - (janeOffset * midlayerCoefficient), map2CA.position.y);
    [map2CA setPosition:midlayerPos];
    
    //--> top layer position
    float toplayerCoefficient = 1.5;
    CGPoint toplayerPos = CGPointMake(avatar_offset+mapCenter.x + (janeOffset * toplayerCoefficient), map4CA.position.y);
    [map4CA setPosition:toplayerPos];
    
    //--> top layer buttons
    [buttonContainer setCenter:toplayerPos];
    
    [CATransaction commit];
    
    
} 
#pragma mark scrollView handlers

- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    if (lastContentOffset > scrollView.contentOffset.x)
    {
        walkingForward = NO;

    }
    else if (lastContentOffset < scrollView.contentOffset.x) 
    {
        walkingForward = YES;    
    }
    lastContentOffset = scrollView.contentOffset.x;
    [self renderScreen:walkingForward:TRUE];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    [self renderScreen:walkingForward:FALSE];
}
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self renderScreen:walkingForward:FALSE];
}

- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender
{
    /* 
    CALayer* layerThatWasTapped = [mapCAView.layer hitTest:[sender locationInView:mapCAView]];
    if ([[mapCAView.layer hitTest:[sender locationInView:mapCAView]].name isEqualToString:janeAvatar.name]) {
        NSLog(@"layer has a name ");
    }
   */
    CGPoint loc = [sender locationInView:mapCAView];
    NSLog(@"touched %f,%f ", loc.x, loc.y);
    for (CALayer *layer in mapCAView.layer.sublayers) {
        if ([layer containsPoint:[mapCAView.layer convertPoint:loc toLayer:layer]]) {
            if ([layer.name isEqualToString:[janeAvatar name]]) {
                NSLog(@"jane hit");
            }
        }
    }
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"hit");

        UITouch *touch = [[event allTouches] anyObject];
        
        CGPoint touchLocation = [touch locationInView:self.view];
}

#pragma mark animation controls

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

#pragma mark button handlers


- (IBAction) foursquareConnect:(UIButton *)sender
{
    NSLog(@"pressed");
    FoursquareAuthViewController *fsq = [[FoursquareAuthViewController alloc] init];
    [fsq setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentViewController:fsq animated:YES completion:NULL];  

}
- (IBAction)introPressed:(UIButton *)sender
{
    SceneController *introScene = [[SceneController alloc] initWithScene:weed.intro];
    [self presentModalViewController:introScene animated:YES];
}
- (IBAction)dealPressed:(UIButton *)sender
{
    //NSLog(@"pressed");
    SceneController *dealScene = [[SceneController alloc] initWithScene:weed.deal];
    [self presentModalViewController:dealScene animated:YES];
}
- (IBAction) barPressed:(UIButton *)sender
{
    //NSLog(@"pressed");
    SceneController *barScene = [[SceneController alloc] initWithScene:weed.bar];
    [self presentModalViewController:barScene animated:YES];
    NSLog(@"start at %@, scheduled notif2 %@", weed.riverBed1.date, [[UIApplication sharedApplication] scheduledLocalNotifications]);

}
- (IBAction)gasStationPressed:(UIButton *)sender
{    
    NSLog(@"gasstation checkin response %@", weed.gasStation.checkInResponse);
    NSLog(@"is the scene unlocked? %@", weed.gasStation.unlocked ? @"YES": @"NO");
    //if ([[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"])
    {
        SceneController *gasStationScene = [[SceneController alloc] initWithScene:weed.gasStation];
        //[gasStationScene setModalTransitionStyle:UIModalTransitionStylePartialCurl];
        [self presentModalViewController:gasStationScene animated:YES]; 
    }
    //else 
    {
        //throw hint to log in
    }
    
}
- (IBAction)riverbed1Pressed:(UIButton *)sender
{
    if (!weed.riverBed1.accessible)
    {
        SceneController *riverbedScene = [[SceneController alloc] initWithScene:weed.riverBed1];
        [self presentModalViewController:riverbedScene animated:YES];
    }
    else
    {
        //pop up hint
    }
}
- (IBAction) riverbed2Pressed:(UIButton *)sender
{
    if (!weed.riverBed2.accessible)
    {
        SceneController *riverbedScene = [[SceneController alloc] initWithScene:weed.riverBed2];
        [self presentModalViewController:riverbedScene animated:YES];
    }
    else
    {
        //pop up hint
    }
}
- (IBAction) desertChasePressed:(UIButton *)sender
{
    if (!weed.desertChase.accessible)
    {
        SceneController *riverbedScene = [[SceneController alloc] initWithScene:weed.desertChase];
        [self presentModalViewController:riverbedScene animated:YES];
    }
    else
    {
        //pop up hint
    }
}
- (IBAction) desertLynchPressed:(UIButton *)sender
{
    if (!weed.desertLynch.accessible)
    {
        SceneController *riverbedScene = [[SceneController alloc] initWithScene:weed.desertLynch];
        [self presentModalViewController:riverbedScene animated:YES];
    }
    else
    {
        //pop up hint
    }
}
- (IBAction) campFirePressed:(UIButton *)sender
{
    if (!weed.campFire.accessible)
    {
        SceneController *riverbedScene = [[SceneController alloc] initWithScene:weed.campFire];
        [self presentModalViewController:riverbedScene animated:YES];
    }
    else
    {
        //pop up hint
    }
}

- (void) gameState
{
    /*
     visible <=> accessible
     what about tips and push notifications? the relationship between them.
     "force tip" for the campfire scene
     button states
     server notifications
     enum game state?
     //allOtherScenes.visible = false;
     //allOtherScenes.hint = @"You should probably check somewhere else...1, 2, or 3";
     
     */
     
     
    //start state - 
    gasStationButton.enabled = weed.gasStation.accessible; 
    //dealButton.enabled = true; 
    //barButton.enabled = true;
    //riverBed1Button.enabled = false; 

     
    //state 2 -
    if ( weed.gasStation.unlocked && weed.deal.unlocked && weed.bar.unlocked ) { 
        weed.riverBed1.accessible = true; 
    }
     
    //state 3 - 
    if (weed.riverBed1.unlocked) {
        weed.riverBed2.accessible = true;
        // turn on region monitoring - ([weed.riverBed1.date timeIntervalSinceNow] < -3600))
        if (!weed.riverBed2.unlocked && ![[UIApplication sharedApplication] scheduledLocalNotifications])
        {
            [self scheduleNotificationWithDate:weed.riverBed1.date intervalTime:10];
        }
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"notification"] && ([weed.riverBed1.date timeIntervalSinceNow] < -10))
        {
            weed.riverBed2.unlocked = true;
        }
    }
    if (weed.riverBed2.unlocked)  {
        weed.desertChase.accessible = true;
        //turn on region monitoring - ( [newLocation distanceFromLocation:riverbed2.location] > 2000) - then set weed.desertChase.unlocked = true;
        if  (weed.desertChase.unlocked){ 
            weed.desertLynch.accessible = true;
        }
        else { //state 4 - 
            [self startSignificantChangeUpdates];
            //when finishes must unlock desertChase then launch a notification
        }
    }

    //state 5 -
    if (weed.desertLynch.unlocked){
        weed.campFire.accessible = true;
        weed.campFire.unlocked = true;
    }
    /* 
    //state 6 -
    if ( weed.campFire.watched ) {
        //end--reset game option, dviz printout or end credits?
    }
    */ 
     
     
     
}

- (void)scheduleNotificationWithDate:(NSDate *)date intervalTime:(int) timeinterval{
   
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    if (!date) {
        //date = [NSDate date];
    }
    localNotif.fireDate = [date dateByAddingTimeInterval:timeinterval];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    //localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"%@ in %i minutes.", nil), item.eventName, minutesBefore];
    //localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    localNotif.alertBody = @"You just unlocked the next scene...";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    //localNotif.applicationIconBadgeNumber = 1;
    
    //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventName forKey:ToDoItemKey];
    //localNotif.userInfo = infoDict;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:timeinterval forKey:@"notification"];
    [defaults synchronize];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

#pragma mark - CLLocationManagerDelegate

- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers;
    [locationManager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 300.0)
    {
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        [locationManager stopMonitoringSignificantLocationChanges];
        weed.desertChase.unlocked = true;
        // notify the unlocking -- animate the unlocking when back to app
        [self scheduleNotificationWithDate:weed.riverBed2.date intervalTime:5];
        
    }
    
   
}

-(IBAction)toggleBlackPanel:(id)sender
{
    [blackPanel removeFromSuperlayer];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGSize screenSize = CGSizeMake(5759, 320.0);
    scrollView.contentSize = screenSize;    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    [scrollView setDelegate:self];
    
    mapCAView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [scrollView addSubview:mapCAView];
    
    //--> sky
    UIImage *skyImage = [UIImage imageNamed:@"sky.jpg"];
    CGRect skyFrame = CGRectMake(0, 0, skyImage.size.width/2, skyImage.size.height/2);
    [map0CA setBounds:skyFrame];
    [map0CA setPosition:CGPointMake(screenSize.width/2, mapCAView.frame.size.height)];
    CGImageRef map0Image = [skyImage CGImage];
    [map0CA setContents:(__bridge id)map0Image];
    [map0CA setZPosition:-5];
    map0CA.shouldRasterize = YES;
    map0CA.opaque = YES;
    [mapCAView.layer addSublayer:map0CA];

    
    //--> layer1 --main map
    CGRect mapFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [map1CA setBounds:mapFrame];
    [map1CA setPosition:CGPointMake(screenSize.width/2, screenSize.height/2)];
    //CGImageRef map1Image = [[UIImage imageNamed:@"map1-8.png"] CGImage];
    //[map1CA setContents:(__bridge id)map1Image];
    [map1CA setZPosition:0];
    map1CA.opaque = YES;
    [mapCAView.layer addSublayer:map1CA];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"mapLayers" ofType:@"plist"];
    NSDictionary *mainDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *mapLayer1 = [NSArray arrayWithArray:[mainDict objectForKey:@"mapLayer1"]];
    
    for (int i=0; i<mapLayer1.count/2; i++)
    {
        CALayer *subLayer1 = [CALayer layer];
        CALayer *subLayer2 = [CALayer layer];
        NSString *imageName1 = [mapLayer1 objectAtIndex:i];
        NSString *imageName2 = [mapLayer1 objectAtIndex:i+mapLayer1.count/2];
        UIImage *image1 = [UIImage imageNamed:imageName1];
        UIImage *image2 = [UIImage imageNamed:imageName2];
        subLayer1.contents = (id)[UIImage 
                                 imageWithCGImage:[image1 CGImage] 
                                 scale:1.0 
                                 orientation:UIImageOrientationRight].CGImage;
        subLayer2.contents = (id)[UIImage 
                                  imageWithCGImage:[image2 CGImage] 
                                  scale:1.0 
                                  orientation:UIImageOrientationRight].CGImage; 
        subLayer1.frame = CGRectMake(i * image1.size.width/2, 0,image1.size.width/2,image1.size.height/2);
        subLayer2.frame = CGRectMake(i * image1.size.width/2, image1.size.height/2,image2.size.width/2,image2.size.height/2);
        //NSLog(@"layer %d frame %@", i, NSStringFromCGRect(subLayer1.frame));
        //NSLog(@"layer %d frame %@", i+array.count/2, NSStringFromCGRect(subLayer2.frame));
        subLayer1.opaque = YES;
        subLayer2.opaque = YES;
        
        
        [map1CA addSublayer:subLayer1];
        [map1CA addSublayer:subLayer2];
        //[mapCAView.layer addSublayer:subLayer1];
        //[mapCAView.layer addSublayer:subLayer2];
    }
    
    //--> layer1 extras
    
    CALayer *rock = [CALayer layer];
    UIImage *rockImg = [UIImage imageNamed:@"top_lvl4_objs_11.png"];
    //rock.bounds = CGRectMake(0, 0, rockImg.size.width, rockImg.size.height);
    //rock.position = CGPointMake(5275, screenSize.height - rock.bounds.size.height/2);
    rock.frame = CGRectMake(5100, screenSize.height - rockImg.size.height/2, rockImg.size.width/2, rockImg.size.height/2);    
    CGImageRef rockCGImage = [rockImg CGImage];
    [rock setContents:(__bridge id)rockCGImage];
    rock.zPosition = 3;
    [mapCAView.layer addSublayer:rock];
    
    //--> layer2 --town, saloon, stuff
    CGRect map2Frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [map2CA setBounds:map2Frame];
    [map2CA setPosition:CGPointMake(screenSize.width/2, screenSize.height/2)];
    //CGImageRef map2Image = [[UIImage imageNamed:@"map2.png"] CGImage];
    //[map2CA setContents:(__bridge id) map2Image];
    [map2CA setZPosition:2];
    map2CA.opaque = YES;
    map2CA.shouldRasterize = YES;
    [mapCAView.layer addSublayer:map2CA];
    
    //--> layer4
    CGRect map4Frame = CGRectMake(0, 0, screenSize.width*2.7, screenSize.height);
    [map4CA setBounds:map4Frame];
    [map4CA setPosition:CGPointMake(screenSize.width/2, screenSize.height/2)];
    [map4CA setZPosition:5];
    [mapCAView.layer addSublayer:map4CA];
    
    buttonContainer.bounds = map4Frame;   //CGRectMake(0, 0, map4Frame.size.width, 100);
    buttonContainer.center = CGPointMake(map4CA.position.x, 0);
    NSMutableArray *buttonArray = [NSMutableArray arrayWithObjects:introButton, dealButton, barButton,gasStationButton, riverBed1Button, riverBed2Button, desertChaseButton, desertLynchButton, nil];
    //NSMutableArray *buttonArray = [NSMutableArray arrayWithObjects:riv, nil];
    //riverbed2, chase, intro, lynch, deal, gas, bar, riverbed1
    NSMutableDictionary *topLayerDict = [NSMutableDictionary dictionaryWithDictionary:[mainDict objectForKey:@"mapLayer4"]];
    int i = 0;
    for (NSString *key in topLayerDict) 
    {
        NSDictionary *sceneDict = [topLayerDict objectForKey:key];
        CALayer *subLayer1 = [CALayer layer];
        NSString *imageName1 = [sceneDict objectForKey:@"img"];
        UIImage *image1 = [UIImage imageNamed:imageName1];
        subLayer1.contents = (id)[UIImage 
                                  imageWithCGImage:[image1 CGImage] 
                                  scale:1.0 
                                  orientation:UIImageOrientationRight].CGImage;
        NSString *positionString = [sceneDict objectForKey:@"position"];
        positionString = [positionString stringByReplacingOccurrencesOfString:@"{" withString:@""];
        positionString = [positionString stringByReplacingOccurrencesOfString:@" " withString:@""];
        positionString = [positionString stringByReplacingOccurrencesOfString:@"}" withString:@""];
        NSArray *strings = [positionString componentsSeparatedByString:@","];
        
        float originX = [[strings objectAtIndex:0] floatValue];
        //float originY = [[strings objectAtIndex:1] intValue];
        
        subLayer1.bounds = CGRectMake(0, 0, image1.size.width/2, image1.size.height/2);
        //subLayer1.position = CGPointMake((map4Frame.size.width/12 *(i+1)), screenSize.height-subLayer1.bounds.size.height/2);
        subLayer1.position = CGPointMake(originX, screenSize.height-subLayer1.bounds.size.height/2);
        [map4CA addSublayer:subLayer1]; 
        
                
        if ([sceneDict objectForKey:@"buttonPosition"]) 
        {
            if ([key isEqualToString:@"introSign"]) i=0; 
            if ([key isEqualToString:@"town"]) i=1;   
            if ([key isEqualToString:@"bar"]) i=2; 
            if ([key isEqualToString:@"gas"]) i=3; 
            if ([key isEqualToString:@"riverbed1"]) i=4; 
            if ([key isEqualToString:@"riverbed2"]) i=5; 
            if ([key isEqualToString:@"chase-cactus"]) i=6;
            if ([key isEqualToString:@"lynch-noose"]) i=7; 
            
            NSString *positionString = [sceneDict objectForKey:@"buttonPosition"];
            positionString = [positionString stringByReplacingOccurrencesOfString:@"{" withString:@""];
            positionString = [positionString stringByReplacingOccurrencesOfString:@" " withString:@""];
            positionString = [positionString stringByReplacingOccurrencesOfString:@"}" withString:@""];
            NSArray *strings = [positionString componentsSeparatedByString:@","];
            
            float originX = [[strings objectAtIndex:0] floatValue];
            float originY = [[strings objectAtIndex:1] floatValue];
            [[buttonArray objectAtIndex:i] setCenter:CGPointMake(originX, originY)];
            //i--;
            NSString *imgName1 =[sceneDict objectForKey:@"buttonAccessible"];
            UIImage *buttonImg = [UIImage imageNamed:imgName1];
            [[buttonArray objectAtIndex:i] setImage:buttonImg forState:UIControlStateNormal];
        }
        
    }
    [scrollView addSubview:buttonContainer];    
    
    //-->noose animation test
    {
        CALayer *hangnoose2 = [CALayer layer];
        UIImage *hangnoose2img = [UIImage imageNamed:@"top_lvl4_objs_10B.png"];
        hangnoose2.bounds = CGRectMake(0, 0, hangnoose2img.size.width/2, hangnoose2img.size.height/2);
        hangnoose2.position = CGPointMake(11557, 27);
        hangnoose2.anchorPoint = CGPointMake(.5, 0);
        CGImageRef hangnoose2Image = [hangnoose2img CGImage];
        [hangnoose2 setContents:(__bridge id)hangnoose2Image];
        [map4CA addSublayer:hangnoose2];
        
        CABasicAnimation* nooseAnimation;
        nooseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        nooseAnimation.fromValue = [NSNumber numberWithFloat:2.0 * M_PI];
        nooseAnimation.toValue = [NSNumber numberWithFloat:2.01 * M_PI];
        nooseAnimation.duration = 2.0;
        //animation.cumulative = YES;
        nooseAnimation.autoreverses = YES;
        nooseAnimation.repeatCount = HUGE_VAL;
        nooseAnimation.removedOnCompletion = NO;
        nooseAnimation.fillMode = kCAFillModeForwards;
        nooseAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        [hangnoose2 addAnimation:nooseAnimation forKey:@"transform.rotation.z"];
    }
    //-->campFire
    {
        blackPanel = [CALayer layer];
        [blackPanel setBounds:CGRectMake(0, 0, 340, screenSize.height)];
        [blackPanel setPosition:CGPointMake(screenSize.width - blackPanel.bounds.size.width/2, screenSize.height/2)];
        blackPanel.backgroundColor = [UIColor blackColor].CGColor;
        blackPanel.zPosition = 3;
        [mapCAView.layer addSublayer:blackPanel];
        
        //the colors for the gradient.  highColor is at the right, lowColor as at the left
        UIColor * highColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        UIColor * lowColor = [UIColor colorWithRed:.4 green:.1 blue:.1 alpha:0];
        
        CAGradientLayer * gradient = [CAGradientLayer layer];
        [gradient setFrame:CGRectMake(0, 0, blackPanel.bounds.size.width*2, blackPanel.bounds.size.height)];
        [gradient setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil]];
        [gradient setStartPoint:CGPointMake(1, .5)];
        [gradient setEndPoint:CGPointMake(0, .5)];
        
        CALayer * roundRect = [CALayer layer];
        [roundRect setFrame:gradient.frame];
        [roundRect setPosition:CGPointMake(blackPanel.bounds.size.width - roundRect.frame.size.width, roundRect.frame.size.height/2)];
        [roundRect setMasksToBounds:YES];
        [roundRect addSublayer:gradient];
        [blackPanel addSublayer:roundRect];
        
        CGSize fixedSize = CGSizeMake(619, 152);
        CGImageRef eyesImage = [[UIImage imageNamed:@"eyeBlink.png"] CGImage];
        MCSpriteLayer* eyesSprite = [MCSpriteLayer layerWithImage:eyesImage sampleSize:fixedSize];
        eyesSprite.position = CGPointMake(blackPanel.bounds.size.width/2.5, blackPanel.bounds.size.height/2);
    
        CAKeyframeAnimation *eyesAnimation = [CAKeyframeAnimation animationWithKeyPath:@"sampleIndex"];
        eyesAnimation.duration = 3.0f;
        eyesAnimation.repeatCount = HUGE_VALF;
        eyesAnimation.calculationMode = kCAAnimationDiscrete;
        eyesAnimation.removedOnCompletion = NO;
        eyesAnimation.fillMode = kCAFillModeForwards;
        
        eyesAnimation.values = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:1],
                            [NSNumber numberWithInt:2],
                            [NSNumber numberWithInt:3],
                            [NSNumber numberWithInt:5], 
                            [NSNumber numberWithInt:4], 
                            [NSNumber numberWithInt:1], 
                            [NSNumber numberWithInt:1],nil]; //not called
        
        eyesAnimation.keyTimes = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.0], 
                              [NSNumber numberWithFloat:0.1], 
                              [NSNumber numberWithFloat:0.12], 
                              [NSNumber numberWithFloat:0.18], 
                              [NSNumber numberWithFloat:0.3], 
                              [NSNumber numberWithFloat:.4],
                              [NSNumber numberWithFloat:0], nil]; //not called 
        
        [eyesSprite addAnimation:eyesAnimation forKey:@"eyeBlink"];
        [blackPanel addSublayer:eyesSprite];
    }
    
    //--> avatar
    CGImageRef avatarImage = [[UIImage imageNamed:@"janeFixed.png"] CGImage];
    [janeAvatar setContents:(__bridge id)avatarImage];
    [janeAvatar setZPosition:2];
    janeAvatar.name = @"janeAvatar";
    [mapCAView.layer addSublayer:janeAvatar];
    [self renderScreen:[[NSUserDefaults standardUserDefaults] boolForKey:@"walkingForward"]:FALSE];
    NSLog(@"jane text %@ %@", janeAvatar.name, janeAvatar.description);
    
    //[mapCAView addSubview:foursquareConnectButton];
    [scrollView addSubview:foursquareConnectButton];
    [scrollView addSubview:campFireButton];
    //UITapGestureRecognizer *tapHandler = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
    //[buttonContainer addGestureRecognizer:tapHandler];
    
    [CATransaction commit];

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
    NSLog(@"saved center %f", center.x);
    scrollView.contentOffset = center;
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"]){
        NSLog(@"access token %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"]);
        foursquareConnectButton.enabled = NO;
        //[[Tumbleweed weed] registerUser];
    }
    //[self gameState];

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
