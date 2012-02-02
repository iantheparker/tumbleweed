//
//  SceneController.h
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIHTTPRequestDelegate.h"

@interface SceneController : UIViewController <CLLocationManagerDelegate, ASIHTTPRequestDelegate>
{
    IBOutlet UIScrollView *venueScrollView;
    IBOutlet UIView *venueView;
    IBOutlet UIView *venueDetailNib;
    CLLocationManager *locationManager;
    NSString *categoryId;
    
}

@property (nonatomic, retain) UIScrollView *venueScrollView;
@property (nonatomic, retain) UIView *venueView;
@property (nonatomic, retain) UIView *venueDetailNib;
@property (nonatomic, retain) CLLocationManager *locationManager; 
@property (nonatomic, retain) NSString *categoryId; 

- (IBAction) dismissModal:(id)sender;
- (void) processVenues: (NSDictionary *) dict;
- (void) checkInFoursquare:(NSString *) venueID;

@end
