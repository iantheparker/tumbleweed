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
{
    NSString *venueId;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *venueId;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, assign) unsigned int arrayPos;

@end
