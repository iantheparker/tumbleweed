//
//  SceneController.m
//  tumbleweed
//
//  Created by David Cascino on 1/25/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "SceneController.h"

#import "CJSONDeserializer.h"
#import "NSDictionary_JSONExtensions.h"

@implementation SceneController

//-- Event Handlers
- (IBAction)dismissModal:(id)sender
{
    NSLog(@"dismissing modal");
    [self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"];
    
    // build the url with query string
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?oauth_token=%@&ll=%@",access_token, @"40.759011,-73.9844722"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *err;
    
    // fetch the data (TODO async)
    NSString *venues = [NSString stringWithContentsOfURL:url 
                                                encoding:NSUTF8StringEncoding 
           
                                                   error:&err];
    // parse into dict
    NSDictionary *venuesDict = [NSDictionary dictionaryWithJSONString:venues 
                                                                error:&err];
    
    // loop through each venue and add a label to the venue
    
    NSLog(@"venues %@", venuesDict);
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
