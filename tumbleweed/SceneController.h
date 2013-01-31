//
//  SceneController.h
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FoursquareAnnotation.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
#import "Scene.h"



@interface SceneController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UIScrollViewDelegate>
{
    IBOutlet UIScrollView *sceneScrollView;
    IBOutlet UIView *sceneSVView;
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
    //MKMapView *mvFoursquare;
    IBOutlet UIView *venueView;
    
}

@property (nonatomic, retain) UIScrollView *sceneScrollView;
@property (nonatomic, retain) UIScrollView *venueScrollView;
@property (nonatomic, retain) UILabel *sceneTitle;
@property (nonatomic, retain) UILabel *checkInIntructions;
@property (nonatomic, retain) UIView *sceneSVView;
@property (nonatomic, retain) UIView *venueDetailNib;
@property (nonatomic, retain) UIView *venueView;
@property (nonatomic, retain) UIImageView *movieThumbnailImageView;
@property (nonatomic, retain) CLLocationManager *locationManager; 
@property (nonatomic, retain) MPMoviePlayerViewController *moviePlayer;
@property (nonatomic, retain) NSMutableDictionary *allVenues;
@property (nonatomic, retain) MKMapView *mvFoursquare;
@property (nonatomic, getter = isPinsLoaded) BOOL pinsLoaded;
@property (nonatomic, retain) UIButton *refreshButton;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIButton *leftScroll;
@property (nonatomic, retain) UIButton *rightScroll;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic, readonly) Scene *scene;

//initializers
- (id) initWithScene: (Scene *) scn;

// touch events
- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender;
- (IBAction) dismissModal:(id)sender;
- (IBAction) playVideo:(id)sender;
- (IBAction)refreshSearch:(id)sender;
- (IBAction)leftScroll :(id)sender;
- (IBAction)rightScroll :(id)sender;

- (void) processVenues: (NSArray *) items : (NSError*) err;
- (void) animateRewards;
- (void) searchSetup;


@end
