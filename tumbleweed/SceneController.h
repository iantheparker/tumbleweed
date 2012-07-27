//
//  SceneController.h
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
//#import "ASIHTTPRequestDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Scene.h"
#import "FoursquareAnnotation.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>


@interface SceneController : UIViewController <CLLocationManagerDelegate, ASIHTTPRequestDelegate, MKMapViewDelegate, UIScrollViewDelegate>
{
    IBOutlet UIScrollView *checkinScrollView;
    IBOutlet UIView *checkinView;
    IBOutlet UILabel *sceneTitle;
    IBOutlet UILabel *checkInIntructions;
    IBOutlet UIScrollView *venueScrollView;
    IBOutlet UIView *venueDetailNib;
    IBOutlet UIImageView *movieThumbnailImageView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIButton *refreshButton;
    IBOutlet UIButton *leftScroll;
    IBOutlet UIButton *rightScroll;
    IBOutlet MKMapView *mvFoursquare;
    IBOutlet UIView *searchView;
    IBOutlet UIButton *playButton;
    CLLocationManager *locationManager;
    MPMoviePlayerViewController *moviePlayer;
    NSMutableDictionary *allVenues;
    Scene *scene;
    //MKMapView *mvFoursquare;
    //__unsafe_unretained __block ASIHTTPRequest *request;
    ASIHTTPRequest *request;
    UIView *venueView;
    
}

@property (nonatomic, retain) UIScrollView *checkinScrollView;
@property (nonatomic, retain) UIScrollView *venueScrollView;
@property (nonatomic, retain) UILabel *sceneTitle;
@property (nonatomic, retain) UILabel *checkInIntructions;
@property (nonatomic, retain) UIView *checkinView;
@property (nonatomic, retain) UIView *venueDetailNib;
@property (nonatomic, retain) UIImageView *movieThumbnailImageView;
@property (nonatomic, retain) CLLocationManager *locationManager; 
@property (nonatomic, retain) MPMoviePlayerViewController *moviePlayer;
@property (nonatomic, retain) NSMutableDictionary *allVenues;
@property (nonatomic, retain) Scene *scene;
@property (nonatomic, retain) MKMapView *mvFoursquare;
@property (nonatomic, getter = isPinsLoaded) BOOL pinsLoaded;
@property (nonatomic, retain) MKUserLocation *userCurrentLocation;
@property (nonatomic, retain) UIButton *refreshButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIButton *leftScroll;
@property (nonatomic, retain) UIButton *rightScroll;
@property (nonatomic, retain) UIButton *playButton;

//initializers
- (id) initWithScene: (Scene *) scn;

- (IBAction) dismissModal:(id)sender;
- (IBAction) playVideo:(id)sender;
- (void) launchVideoPlayer;
- (void) processVenues: (NSArray *) items;
- (void) processRewards;
- (void) animateRewards;
- (void) searchSetup;
- (IBAction)refreshSearch:(id)sender;

// touch events
- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender;


@end
