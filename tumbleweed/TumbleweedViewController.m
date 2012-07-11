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



@implementation TumbleweedViewController

@synthesize scrollView, map0CA, map1CA, map2CA, map4CA, mapCAView, janeAvatar, sprites, walkingForward, weed, locationManager;

//-- scene buttons
@synthesize foursquareConnectButton, gasStationButton, dealButton, barButton, riverBed1Button, riverBed2Button, desertChaseButton, desertLynchButton, campFireButton;


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
    }
    return self;
}

- (CGRect) selectAvatarBounds:(float) position
{
    static const CGRect sampleRects[7] = {
        
        {652, 0, 117, 300},
        {528, 0, 122, 300},
        {0, 0, 203, 300},
        {771, 0, 117, 300},
        {402, 0, 124, 300},
        {205, 0, 195, 300},
        {890, 0, 103, 300},       // still
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
    double avatar_offset = 200;
    double janeLeftBound = 372;
    double janeRightBound = 5332;
    CGPoint center;
    CGRect bounds;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // if woken up and no avatar values, then set them
    //if (!janeAvatar.position.x) janeAvatar.position = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
    
    //set position
    if ([scrollView contentOffset].x <janeLeftBound - avatar_offset || [scrollView contentOffset].x >janeRightBound - avatar_offset || !moving)
    {
        //img = [UIImage imageNamed:@"JANE_walkcycle0.png"];
        bounds = [self selectAvatarBounds:-1];        
        if (janeAvatar.position.x <= janeLeftBound) center = CGPointMake(janeLeftBound, avatar_offset);
        else if (janeAvatar.position.x >= janeRightBound) center = CGPointMake(janeRightBound, avatar_offset);
        else center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
    }
    else {
        center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
        //img = [self selectAvatarImage:[scrollView contentOffset].x];
        bounds = [self selectAvatarBounds:[scrollView contentOffset].x];
        //NSLog(@"cgrect %@", NSStringFromCGRect([self selectAvatarBounds:[scrollView contentOffset].x]));
    }
    janeAvatar.bounds = CGRectMake(0, 0, bounds.size.width/2, bounds.size.height/2);
    janeAvatar.contentsRect = CGRectMake(bounds.origin.x/1024.0f, bounds.origin.y/512.0f, bounds.size.width/1024.0f, bounds.size.height/512.0f);
    
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
    CGPoint skyCenter = CGPointMake(220+mapCenter.x - (janeOffset * skyCoefficient), [map0CA bounds].size.height/2.0);
    [map0CA setPosition:skyCenter];
    
    //--> mid-layer position
    float midlayerCoefficient = .1;
    CGPoint midlayerPos = CGPointMake(mapCenter.x - (janeOffset * midlayerCoefficient), map2CA.position.y);
    [map2CA setPosition:midlayerPos];
    
    //--> top layer position
    float toplayerCoefficient = .1;
    CGPoint toplayerPos = CGPointMake(mapCenter.x - (janeOffset * toplayerCoefficient), map4CA.position.y);
    [map4CA setPosition:toplayerPos];
    
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

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    NSLog(@"touched");
    CGPoint p = [(UITouch*)[touches anyObject] locationInView:self.mapCAView];
    for (CALayer *layer in self.view.layer.sublayers) {
        if ([layer containsPoint:[self.view.layer convertPoint:p toLayer:layer]]) {
            NSLog(@"touched");
        }
    }
}

- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender
{
    NSLog(@"touched");
    //CALayer* layerThatWasTapped = [mapCAView.layer hitTest:[sender locationInView:mapCAView]];
    //layerThatWasTapped.position = CGPointMake(67, 23);

}


#pragma mark button handlers


- (IBAction) foursquareConnect:(UIButton *)sender
{
    NSLog(@"pressed");
    FoursquareAuthViewController *fsq = [[FoursquareAuthViewController alloc] init];
    //[fsq setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentViewController:fsq animated:YES completion:NULL];  

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
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"])
    {
        SceneController *gasStationScene = [[SceneController alloc] initWithScene:weed.gasStation];
        //[gasStationScene setModalTransitionStyle:UIModalTransitionStylePartialCurl];
        [self presentModalViewController:gasStationScene animated:YES]; 
    }
    else 
    {
        //throw hint to log in
    }
    
}
- (IBAction)riverbed1Pressed:(UIButton *)sender
{
    if (weed.riverBed1.accessible)
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
    if (weed.riverBed2.accessible)
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
    if (weed.desertChase.accessible)
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
    if (weed.desertLynch.accessible)
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
    if (weed.campFire.accessible)
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGSize screenSize = CGSizeMake(5782, 320.0);
    scrollView.contentSize = screenSize;
    mapCAView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    //mapCAView.bounds = CGRectMake(0, 0, screenSize.width, screenSize.height);

    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    [scrollView setDelegate:self];
    [scrollView addSubview:mapCAView];
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -2000;
    
    //--> sky
    UIImage *skyImage = [UIImage imageNamed:@"gdw_parallax_cropped_layer=sky.jpg"];
    CGRect skyFrame = CGRectMake(0, 0, skyImage.size.width/2, skyImage.size.height/2);
    [map0CA setBounds:skyFrame];
    [map0CA setPosition:CGPointMake(screenSize.width/2, mapCAView.frame.size.height)];
    //CGImageRef map0Image = [[UIImage imageNamed:@"gdw_parallax_cropped_layer=sky.jpg"] CGImage];
    CGImageRef map0Image = [skyImage CGImage];
    [map0CA setContents:(__bridge id)map0Image];
    [map0CA setZPosition:-5];
    map0CA.shouldRasterize = YES;
    map0CA.opaque = YES;
    [mapCAView.layer addSublayer:map0CA];

    
    //--> layer1
    CGRect mapFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [map1CA setBounds:mapFrame];
    [map1CA setPosition:CGPointMake(screenSize.width/2, screenSize.height/2)];
    //CGImageRef map1Image = [[UIImage imageNamed:@"map1-8.png"] CGImage];
    //[map1CA setContents:(__bridge id)map1Image];
    [map1CA setZPosition:0];
    map1CA.opaque = YES;
    
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"mapLayer1" ofType:@"plist"];
    NSDictionary *mainDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *array = [NSArray arrayWithArray:[mainDict objectForKey:@"mapLayer1"]];
    CALayer *subLayer1;
    CALayer *subLayer2;

    for (int i=0; i<array.count/2; i++)
    {
        subLayer1 = [[CALayer alloc] init];
        subLayer2 = [[CALayer alloc] init];
        NSString *imageName1 = [array objectAtIndex:i];
        //NSLog(@"i = %d", i);
        NSString *imageName2 = [array objectAtIndex:i+array.count/2];
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
        subLayer1.opaque = YES;
        subLayer2.opaque = YES;
        
        
        //[map1CA addSublayer:subLayer1];
        //[map1CA addSublayer:subLayer2];
        [mapCAView.layer addSublayer:subLayer1];
        [mapCAView.layer addSublayer:subLayer2];
    }
    
    //[mapCAView.layer addSublayer:map1CA];
    
    //--> layer2
    CGRect map2Frame = CGRectMake(0, 0, screenSize.width *1.01, screenSize.height);
    [map2CA setBounds:map2Frame];
    [map2CA setPosition:CGPointMake(screenSize.width/2, screenSize.height/2)];
    //CGImageRef map2Image = [[UIImage imageNamed:@"map2.png"] CGImage];
    //[map2CA setContents:(__bridge id) map2Image];
    [map2CA setZPosition:2];
    map2CA.opaque = YES;
    map2CA.shouldRasterize = YES;
    //[mapCAView.layer addSublayer:map2CA];
    
    //--> layer4
    CGRect map4Frame = CGRectMake(0, 0, screenSize.width *1.1, screenSize.height);
    [map4CA setBounds:map4Frame];
    [map4CA setPosition:CGPointMake(screenSize.width/2, screenSize.height/2)];
    //CGImageRef map4Image = [[UIImage imageNamed:@"map4.png"] CGImage];
    //[map4CA setContents:(__bridge id) map4Image];
    [map4CA setZPosition:5];
    map4CA.opaque = YES;
    map4CA.shouldRasterize = YES;
    [mapCAView.layer addSublayer:map4CA];
    
    CALayer *hangnoose1 = [CALayer layer];
    UIImage *hangnoose1img = [UIImage imageNamed:@"hangnoose_post.png"];
    hangnoose1.bounds = CGRectMake(0, 0, hangnoose1img.size.width/2, hangnoose1img.size.height/2);
    hangnoose1.position = CGPointMake(screenSize.width/2, screenSize.height/2);
    CGImageRef hangnoose1Image = [hangnoose1img CGImage];
    [hangnoose1 setContents:(__bridge id)hangnoose1Image];
    [map4CA addSublayer:hangnoose1];
    CALayer *hangnoose2 = [CALayer layer];
    UIImage *hangnoose2img = [UIImage imageNamed:@"hangnoose_noose.png"];
    hangnoose2.bounds = CGRectMake(0, 0, hangnoose2img.size.width, hangnoose2img.size.height);
    hangnoose2.position = CGPointMake(30, 220);
    hangnoose2.anchorPoint = CGPointMake(.5, 1);
    CGImageRef hangnoose2Image = [hangnoose2img CGImage];
    [hangnoose2 setContents:(__bridge id)hangnoose2Image];
    [hangnoose1 addSublayer:hangnoose2];
    
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    animation.fromValue = [NSNumber numberWithFloat:0.0 * M_PI];
    animation.toValue = [NSNumber numberWithFloat:1.0 * M_PI];
    animation.duration = 1.0;
    //animation.cumulative = YES;
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VAL;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [hangnoose2 addAnimation:animation forKey:@"transform.rotation.z"];



    //--> avatar
    //CGRect avatarFrame = CGRectMake(890, 0, 103, 300);
    //[janeAvatar setBounds:avatarFrame];
    //[janeAvatar setPosition:CGPointMake(572, screenSize.height/2)];
    CGImageRef avatarImage = [[UIImage imageNamed:@"janeSprite_default.png"] CGImage];
    [janeAvatar setContents:(__bridge id)avatarImage];
    //[janeAvatar setContentsGravity:kCAGravityCenter];
    [janeAvatar setZPosition:2];
    [mapCAView.layer addSublayer:janeAvatar];
    //janeAvatar.opaque = YES;
    //janeAvatar.shouldRasterize = YES;
    //NSNumber* radians = [NSNumber numberWithInt:3];
    //[janeAvatar setValue:radians forKeyPath:@"transform.rotation.x"];
    [self renderScreen:[[NSUserDefaults standardUserDefaults] boolForKey:@"walkingForward"]:FALSE];
    
    [mapCAView bringSubviewToFront:foursquareConnectButton];
    [mapCAView bringSubviewToFront:gasStationButton];
    UITapGestureRecognizer *tapHandler = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
    [mapCAView addGestureRecognizer:tapHandler];
    
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
        [[Tumbleweed weed] registerUser];
    }
    [self gameState];

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
