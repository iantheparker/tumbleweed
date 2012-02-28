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
#import <MediaPlayer/MediaPlayer.h>
#import "Scene.h"
#import "FoursquareAnnotation.h"
#import <MapKit/MapKit.h>


@interface SceneController : UIViewController <CLLocationManagerDelegate, ASIHTTPRequestDelegate, MKMapViewDelegate>
{
    IBOutlet UIView *rewardBar;
    IBOutlet UIScrollView *venueScrollView;
    IBOutlet UIView *venueDetailNib;
    IBOutlet UIImageView *movieThumbnailImageView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIButton *mapButton;
    CLLocationManager *locationManager;
    MPMoviePlayerViewController *moviePlayer;
    NSMutableDictionary *allVenues;
    Scene *scene;
    MKMapView *mvFoursquare;
    
}

@property (nonatomic, retain) UIScrollView *venueScrollView;
@property (nonatomic, retain) UIView *venueDetailNib;
@property (nonatomic, retain) UIImageView *movieThumbnailImageView;
@property (nonatomic, retain) IBOutlet UIButton *mapButton;
@property (nonatomic, retain) CLLocationManager *locationManager; 
@property (nonatomic, retain) MPMoviePlayerViewController *moviePlayer;
@property (nonatomic, retain) NSMutableDictionary *allVenues;
@property (nonatomic, retain) Scene *scene;
@property (nonatomic, retain) IBOutlet MKMapView *mvFoursquare;
@property (nonatomic, getter = isPinsLoaded) BOOL pinsLoaded;
@property (nonatomic, retain) MKUserLocation *userCurrentLocation;


//initializers
- (id) initWithScene: (Scene *) scn;

- (IBAction) dismissModal:(id)sender;
- (IBAction) mapLaunch;
- (void) launchVideoPlayer;
- (void) processVenues: (NSArray *) items;
- (void) processRewards;
- (void) animateRewards;

// touch events
- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender;


@end
