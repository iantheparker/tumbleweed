//
//  FoursquareAnnotation.h
//  Foursquare Test
//
//  Created by Angelo Villegas on 8/26/11.
//  Copyright 2011 Studio Villegas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotation.h>

@interface FoursquareAnnotation : UIView <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) UIImage *icon;

@end
