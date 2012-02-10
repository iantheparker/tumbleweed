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

#import "CJSONDeserializer.h"
#import "NSDictionary_JSONExtensions.h"

#import "ASIFormDataRequest.h"

@implementation SceneController

@synthesize venueScrollView, venueDetailNib, rewardScrollView, rewardView, locationManager, moviePlayer, allVenues;

//-- Event Handlers
- (IBAction)dismissModal:(id)sender
{
    //NSLog(@"dismissing modal");
    [self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        allVenues = [[NSMutableDictionary alloc] init];
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
    CheckInController *checkIn = [[CheckInController alloc] init];
    [checkIn setVenueDetails:venueDetails];
    [self presentModalViewController:checkIn animated:YES];
}

#pragma mark - View lifecycle


- (void) processVenues: (NSArray*) items
{
    
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
        int distance = [[[ven objectForKey: @"location"] objectForKey: @"distance"] intValue];
        int hereCount = [[[ven objectForKey: @"hereNow"] objectForKey:@"count"] intValue]; 

        [[NSBundle mainBundle] loadNibNamed:@"ListItemScrollView" owner:self options:nil];
       
        UILabel *nameLabel = (UILabel *)[venueDetailNib viewWithTag:1];
        UILabel *addressLabel = (UILabel *)[venueDetailNib viewWithTag:2];
        UILabel *distanceLabel = (UILabel *)[venueDetailNib viewWithTag:3];
        UILabel *peopleLabel = (UILabel *)[venueDetailNib viewWithTag:4];
        UIImageView *icon = (UIImageView *) [venueDetailNib viewWithTag:5];
        
        [nameLabel setText:name];
        [addressLabel setText:address];
        [distanceLabel setText:[NSString stringWithFormat:@"%d meters", distance]];
        [peopleLabel setText:[NSString stringWithFormat:@"%d people here now", hereCount]];

        //[icon setImage:[UIImage imageNamed:@"bubble5"]];
        NSString *iconURL = [[[ven objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"icon"];
        NSLog(@"iconpath %@", iconURL);
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
    int rewardsForScene = 4;
    float scrollWidth = 1200;
    CGSize rewardSize = CGSizeMake(scrollWidth, rewardScrollView.contentSize.height);    
    rewardScrollView.contentSize = rewardSize;
    int offset = 0;
    for (int i = 0; i < rewardsForScene; i++) {        
        NSLog(@"processing rewards for loop");
        UIImageView *rewardicon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble5"]];
        float nibwidth = 100;
        float nibheight = 100; 
        int padding = 2;
        offset = (int)(nibwidth + padding) * i; 
        CGPoint rewardCenter = CGPointMake(offset + (nibwidth / 2), nibheight/2);
        [rewardicon setFrame:CGRectMake(0, 0, 100, 100)];
        [rewardicon setCenter:rewardCenter];
        [rewardView addSubview:rewardicon];
        
        
    }

}


// Required CoreLocation methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"location update is called");
    [locationManager stopUpdatingLocation];
    
    NSString *lat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    
    ASIHTTPRequest *request = [Foursquare searchVenuesNearByLatitude:lat longitude:lon categoryId:GAS_TRAVEL_catId];
    [request setDelegate:self];
    [request startAsynchronous];    
     
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location errors is called");

}

// end Required CoreLocation methods


// Required ASI Asynchronous request methods 

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

//end Required ASI Asychronous request methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
