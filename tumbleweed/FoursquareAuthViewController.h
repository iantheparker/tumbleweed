//
//  FoursquareAuthViewController.h
//  CoreDataTalk
//
//  Created by Anoop Ranganath on 2/19/11.
//  Copyright 2011 foursquare. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FoursquareAuthViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
}

@property (nonatomic, retain) UIWebView *webView;

- (IBAction) dismissModal:(id)sender;


@end
