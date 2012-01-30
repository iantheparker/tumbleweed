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


    

    //NSLog(@"venues %@", venuesDict);
    //NSLog(@"venues keys%@", venuesDict.allKeys);
    //NSLog(@"venues values%@", venuesDict.allValues);
    //NSLog(@"venues total %d", venuesDict.count);
    //NSLog(@"value for notifcations key%@", [venuesDict valueForKey:@"notifications"]);
    //NSLog(@"value for meta key%@", [venuesDict valueForKey:@"meta"]);
    //NSLog(@"value for response key%@", [venuesDict valueForKey:@"response"]);
    //NSLog(@"value for response key%@", [[venuesDict valueForKey:@"response"] allKeys]);
    NSDictionary *response = [venuesDict objectForKey:@"response"];
    NSArray *groups = [response objectForKey:@"groups"];
    NSDictionary *group1 = [groups objectAtIndex:0];
    NSArray *items = [group1 objectForKey:@"items"];
    for (int i = 0; i < [items count]; i++) {
        NSDictionary *ven = [items objectAtIndex:i];
        NSString *name = [ven objectForKey:@"name"];
        NSLog(@"item %d is called %@", i, name);
    }
    
    //NSArray *items = [[[venuesDict objectForKey:@"response"] objectForKey:@"groups"] objectForKey:@"items"];
    
    
    
    //NSLog(@"value for response values%@", [[venuesDict valueForKey:@"response"] allValues]);
    //NSLog(@"response = %d", items.count);
    
    NSLog(@"%d", [items count]);
    
    // loop through each venue and add a label to the venue
    
    //NSLog(@"venues %@", venuesDict);
    //NSLog(@"venues %@", venues);
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
