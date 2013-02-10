//
//  ViewController.m
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import "TumbleweedViewController.h"
#import "SceneController.h"
#import "FoursquareAuthViewController.h"
#import "MCSpriteLayer.h"

@interface TumbleweedViewController()



@property BOOL walkingForward;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) CALayer *map0CA;
@property (nonatomic, retain) CALayer *map1CA;
@property (nonatomic, retain) CALayer *map1BCA;
@property (nonatomic, retain) CALayer *map1CCA;
@property (nonatomic, retain) CALayer *map2CA;
@property (nonatomic, retain) CALayer *map4CA;
@property (nonatomic, retain) CALayer *janeAvatar;
@property (nonatomic, retain) UIView *mapCAView;
@property (nonatomic, retain) UIButton *buttonContainer;
@property (nonatomic, retain) CALayer *blackPanel;

-(void) gameSavetNotif: (NSNotification *) notif;
-(void) scenePressed:(UIButton*)sender;
//-(void)pauseLayer:(CALayer*)layer;
//-(void)resumeLayer:(CALayer*)layer;
-(void) renderScreen: (BOOL) direction : (BOOL) moving;
-(CGRect) selectAvatarBounds:(float) position;
-(void)startCampfire;
-(void) updateSceneButtonStates;
-(CGPoint) coordinatePListReader: (NSString*) positionString;
-(NSMutableArray*) mapLayerPListPlacer: (NSDictionary*) plist : (CGSize) screenSize : (CALayer*) parentLayer : (NSMutableArray*) sceneArray;
-(CALayer*) layerInitializer: (id) plistObject :(CGSize) screenSize : (CALayer*) parentLayer : (NSString*) layerName;

@end

@implementation TumbleweedViewController{
@private
    int lastContentOffset;
    BOOL walkingForward;

}

@synthesize scrollView, map0CA, map1CA, map1BCA, map1CCA, map2CA, map4CA, mapCAView, janeAvatar, walkingForward;

//-- scene buttons
@synthesize foursquareConnectButton, buttonContainer, blackPanel;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //weed = [Tumbleweed weed];
        
        map0CA = [[CALayer alloc] init];
        map1CA = [[CALayer alloc] init];
        map1BCA = [[CALayer alloc] init];
        map1CCA = [[CALayer alloc] init];
        map2CA = [[CALayer alloc] init];
        map4CA = [[CALayer alloc] init];
        janeAvatar = [[CALayer alloc] init];
        mapCAView = [[UIView alloc] init];
        //buttonContainer = [[UIView alloc] init];
    }
    return self;
}
#pragma mark -
#pragma mark screen renders

- (CGRect) selectAvatarBounds:(float) position
{
    static const CGRect sampleRects[7] = {
        
        {172, 0, 246, 465},
        {418, 0, 234, 467},
        {652, 0, 304, 465},
        {956, 0, 246, 471},
        {1202, 0, 234, 467},
        {1436, 0, 304, 465},
        {0, 0, 172, 463},       // still
    };
    
    //return still state
    if (position == -1)
        return sampleRects[6];

    int frameSize = 20;
    int imageCount = 6;
    int currentPosition = (int) position;
    unsigned int imageIndex = (currentPosition + (frameSize * imageCount)) % (frameSize * imageCount) / frameSize;
    return sampleRects[imageIndex];
}
- (void) saveAvatarPosition
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:scrollView.contentOffset.x forKey:@"scroll_view_position"];
    [defaults setBool:walkingForward forKey:@"walkingForward"];
    NSLog(@"saving Jane's position");
}
- (void) renderScreen: (BOOL) direction :(BOOL) moving
{
    double avatar_offset = 220;
    double janeLeftBound = 372;
    double janeRightBound = 5275;
    CGPoint center;
    CGRect bounds;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // if woken up and no avatar values, then set them
    //if (!janeAvatar.position.x) janeAvatar.position = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
    
    //set position
    if ([scrollView contentOffset].x <janeLeftBound - avatar_offset || [scrollView contentOffset].x >janeRightBound - avatar_offset || !moving)
    {
        bounds = [self selectAvatarBounds:-1];        
        if (janeAvatar.position.x <= janeLeftBound) center = CGPointMake(janeLeftBound, avatar_offset);
        else if (janeAvatar.position.x >= janeRightBound) center = CGPointMake(janeRightBound, avatar_offset);
        else center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
    }
    else {
        center = CGPointMake([scrollView contentOffset].x + avatar_offset, avatar_offset);
        bounds = [self selectAvatarBounds:[scrollView contentOffset].x];
    }
    janeAvatar.bounds = CGRectMake(0, 0, bounds.size.width/2.5, bounds.size.height/2.5);
    janeAvatar.contentsRect = CGRectMake(bounds.origin.x/2048.0f, bounds.origin.y/512.0f, bounds.size.width/2048.0f, bounds.size.height/512.0f);
    
    [janeAvatar setPosition:center];
    
    //set direction
    if (!direction) {
        janeAvatar.transform = CATransform3DScale(CATransform3DMakeRotation(0, 0, 0, 1),
                                                  -1, 1, 1);
    }
    else {
        janeAvatar.transform = CATransform3DScale(CATransform3DMakeRotation(0, 0, 0, 1),
                                                  1, 1, 1);
    }
    
    //-sky position- CALayer - fix the hardcoded offset here
    CGPoint mapCenter = map1CA.position;
    float skyCoefficient = .9;
    float janeOffset = mapCenter.x - scrollView.contentOffset.x;
    CGPoint skyCenter = CGPointMake(avatar_offset+mapCenter.x - (janeOffset * skyCoefficient), [map0CA bounds].size.height/2.0);
    [map0CA setPosition:skyCenter];
    
    //--> layer1C position
    float layer1CCoefficient = .4;
    CGPoint layer1CPos = CGPointMake(mapCenter.x - (janeOffset * layer1CCoefficient), map1CCA.position.y);
    [map1CCA setPosition:layer1CPos];
    
    //--> layer1B position
    float layer1BCoefficient = .03;
    CGPoint layer1BPos = CGPointMake(mapCenter.x + (janeOffset * layer1BCoefficient), map1BCA.position.y);
    [map1BCA setPosition:layer1BPos];
    
    //--> layer2 position
    float layer2Coefficient = .03;
    CGPoint layer2Pos = CGPointMake(mapCenter.x + (janeOffset * layer2Coefficient), map2CA.position.y);
    [map2CA setPosition:layer2Pos];
    
    //--> top layer position
    float toplayerCoefficient = 1.5;
    CGPoint toplayerPos = CGPointMake(avatar_offset+mapCenter.x + (janeOffset * toplayerCoefficient), map4CA.position.y);
    [map4CA setPosition:toplayerPos];
    
    //--> top layer buttons
    [buttonContainer setCenter:toplayerPos];
    
    [CATransaction commit];
    
    
} 
#pragma mark -
#pragma mark scrollView handlers

- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    if (lastContentOffset > scrollView.contentOffset.x)
    {
        walkingForward = NO;

    }
    else if (lastContentOffset < scrollView.contentOffset.x) 
    {
        walkingForward = YES;    
    }
    lastContentOffset = scrollView.contentOffset.x;
    [self renderScreen:walkingForward:TRUE];
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView
{
    [self renderScreen:walkingForward:FALSE];
}
- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self renderScreen:walkingForward:FALSE];
}

#pragma mark -
#pragma mark animation controls

-(void)pauseLayer:(CALayer*)layer
{
    if (!layer) layer = map1CA;
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}
-(void)resumeLayer:(CALayer*)layer
{
    if (!layer) layer = map1CA;
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}
-(void) startCampfire
{
    [blackPanel removeFromSuperlayer];
    
    //should read from plist if i want to support non-retina
    CGSize fixedSize = CGSizeMake(256, 289);
    CGImageRef campfireImage = [[UIImage imageNamed:@"campfire"] CGImage];
    MCSpriteLayer* campefireSprite = [MCSpriteLayer layerWithImage:campfireImage sampleSize:fixedSize];
    campefireSprite.position = CGPointMake(scrollView.contentSize.width - (fixedSize.width - 14), scrollView.contentSize.height/2 + 26);
    
    CABasicAnimation *campfireAnimation = [CABasicAnimation animationWithKeyPath:@"sampleIndex"];
    campfireAnimation.fromValue = [NSNumber numberWithInt:1];
    campfireAnimation.toValue = [NSNumber numberWithInt:5];
    campfireAnimation.duration = .40f;
    campfireAnimation.repeatCount = HUGE_VALF;
    
    [campefireSprite addAnimation:campfireAnimation forKey:nil];
    [map1CA addSublayer:campefireSprite];
    //add button
    
    [[scenes.lastObject button] setCenter:CGPointMake(campefireSprite.position.x-3, campefireSprite.position.y + 40)];
    [scrollView addSubview:[scenes.lastObject button]];
}
#pragma mark - 
#pragma mark button handlers

- (void) scenePressed:(UIButton *)sender
{
    if (![[scenes objectAtIndex:sender.tag] sceneVC]) {
        [[scenes objectAtIndex:sender.tag] setSceneVC:[[SceneController alloc] initWithScene:[scenes objectAtIndex:sender.tag]]];
        NSLog(@"pressed %@", [[scenes objectAtIndex:sender.tag] name ]);
    }
    [self presentViewController:[[scenes objectAtIndex:sender.tag] sceneVC] animated:YES completion:^{}];
    //[self.navigationController pushViewController:[[scenes objectAtIndex:sender.tag] sceneVC].navigationController animated:NO];
    /*
    [UIView transitionWithView:self.view
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{
                        [self.navigationController pushViewController:[[scenes objectAtIndex:sender.tag] sceneVC].navigationController animated:NO];
                    }
                    completion:NULL];
    */
}
- (IBAction) foursquareConnect:(UIButton *)sender
{
    //FoursquareAuthViewController *fsq = [[FoursquareAuthViewController alloc] init];
    //[fsq setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    //[self presentViewController:fsq animated:YES completion:NULL];
    [Foursquare startAuthorization];
}
- (IBAction)handleSingleTap:(UIGestureRecognizer *)sender
{
    CGPoint loc = [sender locationInView:mapCAView];
    //NSLog(@"touched %f,%f ", loc.x, loc.y);
    for (CALayer *layer in mapCAView.layer.sublayers) {
        if ([layer containsPoint:[mapCAView.layer convertPoint:loc toLayer:layer]]) {
            if ([layer.name isEqualToString:[janeAvatar name]]) {
                NSLog(@"jane hit");
            }
        }
    }
}

#pragma mark -
#pragma mark game state updates
-(void) gameSavetNotif: (NSNotification *) notif
{
    NSLog(@"in gameSaveNotif with %@", [notif name]);
    [self gameState];
}
- (void) gameState
{
    switch ([Tumbleweed weed].tumbleweedLevel) {
        
        case 4:
            //wait for notification from server when timer is up
            //if seems like it's been a long wait, double-check on foursquare's push and post an update
            break;
            
        case 5:
            //turn on region monitoring - ( [newLocation distanceFromLocation:riverbed2.location] > 2000)
            //[self startSignificantChangeUpdates];
            //when finishes must unlock desertChase then launch a notification
            break;
            
        case 6:
            break;
            
        case 7:
            [self performSelector:@selector(startCampfire)];
            break;
        default:
            //not logged in
            break;
            
    }
    [self updateSceneButtonStates];

}
-(void) updateSceneButtonStates
{
    NSLog(@"update scene with level %d", [Tumbleweed weed].tumbleweedLevel);
    //start this loop at 1 because scene 0 is the intro and that should always be accessible
    for (int i = 1; i < scenes.count; i++)
    {
        if (![[Tumbleweed weed] tumbleweedId]) {
            [[scenes objectAtIndex:i] button].enabled = NO;
        }
        else if (([[scenes objectAtIndex:i] level] > [Tumbleweed weed].tumbleweedLevel)) {
            [[scenes objectAtIndex:i] button].enabled = NO;
        }
        else if ([[scenes objectAtIndex:i] level] == [Tumbleweed weed].tumbleweedLevel) {
            //using scene unlock bool 
            [[scenes objectAtIndex:i] button].enabled = YES;
        }
        else if ([[scenes objectAtIndex:i] level] < [Tumbleweed weed].tumbleweedLevel){
            [[scenes objectAtIndex:i] button].selected = YES;
        }
    }
}

#pragma mark -
#pragma mark pList tools
-(CGPoint) coordinatePListReader:(NSString *)positionString
{
    positionString = [positionString stringByReplacingOccurrencesOfString:@"{" withString:@""];
    positionString = [positionString stringByReplacingOccurrencesOfString:@" " withString:@""];
    positionString = [positionString stringByReplacingOccurrencesOfString:@"}" withString:@""];
    NSArray *strings = [positionString componentsSeparatedByString:@","];
    
    float originX = [[strings objectAtIndex:0] floatValue];
    float originY = [[strings objectAtIndex:1] floatValue];
    return CGPointMake(originX, originY);
}
-(CALayer*) layerInitializer: (id) plistObject : (CGSize) screenSize : (CALayer*) parentLayer : (NSString*) layerName
{
    // plistObject is a single element in a plist dict. 
    int zPos = 0;
    CGPoint boundsMultiplier = CGPointMake(1, 1);
    if ([plistObject isKindOfClass:[NSDictionary class]]) {
        if ([plistObject objectForKey:@"zPosition"]) zPos =  [[plistObject objectForKey:@"zPosition"] integerValue];
        if ([plistObject objectForKey:@"boundsMultiplier"]) boundsMultiplier = [self coordinatePListReader:[plistObject objectForKey:@"boundsMultiplier"]];
    }
    CGRect mapFrame = CGRectMake(0, 0, screenSize.width * boundsMultiplier.x, screenSize.height * boundsMultiplier.y);
    CALayer *mapLayer = [CALayer layer];
    if (layerName) mapLayer.name = layerName;
    [mapLayer setBounds:mapFrame];
    [mapLayer setPosition:CGPointMake(screenSize.width/2, screenSize.height/2)];
    [mapLayer setZPosition:zPos];
    [parentLayer addSublayer:mapLayer];
    return mapLayer;
}
-(NSMutableArray*) mapLayerPListPlacer: (NSDictionary*) plist : (CGSize) screenSize : (CALayer*) parentLayer : (NSMutableArray*) sceneArray
{
    NSMutableArray *layerArray = [NSMutableArray array];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (NSString *key in plist)
    {
        CALayer *mapCALayer = [self layerInitializer:[plist objectForKey:key]  :screenSize : parentLayer : key];
        // This is for the double-placing an array, currently only maplayer1
        if ([[plist objectForKey:key] isKindOfClass:[NSArray class]])
        {
            NSArray *mapLayerArray = [plist objectForKey:key];
            float subLayerOriginX = 0;
            for (int i=0; i<mapLayerArray.count; i+=2)
            {
                CALayer *subLayer1 = [CALayer layer];
                CALayer *subLayer2 = [CALayer layer];
                NSString *imageName1 = [mapLayerArray objectAtIndex:i];
                NSString *imageName2 = [mapLayerArray objectAtIndex:i+1];
                UIImage *image1 = [UIImage imageNamed:imageName1];
                UIImage *image2 = [UIImage imageNamed:imageName2];
                subLayer1.contents = (id)[UIImage
                                          imageWithCGImage:[image1 CGImage]
                                          scale:1.0
                                          orientation:UIImageOrientationRight].CGImage;
                subLayer2.contents = (id)[UIImage
                                          imageWithCGImage:[image2 CGImage]
                                          scale:1.0
                                          orientation:UIImageOrientationRight].CGImage;
                subLayer1.frame = CGRectMake(subLayerOriginX, 0,image1.size.width/2,image1.size.height/2);
                subLayer2.frame = CGRectMake(subLayerOriginX, image1.size.height/2,image2.size.width/2,image2.size.height/2);
                subLayerOriginX += image1.size.width/2;
                //NSLog(@"layer %d frame %@", i, NSStringFromCGRect(subLayer1.frame));
                //NSLog(@"layer %d frame %@", i+array.count/2, NSStringFromCGRect(subLayer2.frame));
                //subLayer1.opaque = YES;
                subLayer2.opaque = YES;
                
                [mapCALayer addSublayer:subLayer1];
                [mapCALayer addSublayer:subLayer2];
            }
        }
        // for all dictionary-based base layers
        else
        {
            NSDictionary *mapLayerDict = [plist objectForKey:key];
            BOOL bottomAlignment = NO;
            if ([mapLayerDict objectForKey:@"bottomAlignment"]) bottomAlignment = YES;
            for (NSString *dictkey in mapLayerDict)
            {
                if (![[mapLayerDict objectForKey:dictkey] isKindOfClass:[NSDictionary class]]) continue;
                NSDictionary *sceneDict = [mapLayerDict objectForKey:dictkey];
                CALayer *subLayer1 = [CALayer layer];
                NSString *imageName1 = [sceneDict objectForKey:@"img"];
                UIImage *image1 = [UIImage imageNamed:imageName1];
                subLayer1.contents = (id)[UIImage
                                          imageWithCGImage:[image1 CGImage]
                                          scale:1.0
                                          orientation:UIImageOrientationRight].CGImage;
                CGPoint pos = [self coordinatePListReader:[sceneDict objectForKey:@"position"]];
                subLayer1.bounds = CGRectMake(0, 0, image1.size.width/2, image1.size.height/2);
                
                //for top layers that should be positioned at the bottom of the screen
                if (bottomAlignment)
                {
                    subLayer1.position = CGPointMake(pos.x, mapCALayer.bounds.size.height-subLayer1.bounds.size.height/2);
                }
                else subLayer1.position = pos;
                
                // if it's an image that holds a sceneButton, then position that button
                if ([sceneDict objectForKey:@"sceneButtonNumber"])
                {
                    int scenePosition = [[sceneDict objectForKey:@"sceneButtonNumber"] integerValue];
                    [[[sceneArray objectAtIndex:scenePosition] button] setCenter:[self coordinatePListReader:[sceneDict objectForKey:@"buttonPosition"]]];
                }
                 
                [mapCALayer addSublayer:subLayer1];
            }
        }
        [layerArray addObject:mapCALayer];
    }
    [CATransaction commit];
    // order by plist key name
    [layerArray sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(CALayer*)a name];
        NSString *second = [(CALayer*)b name];
        return [first compare:second];
    }];
    return layerArray;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGSize screenSize = CGSizeMake(5759, 320.0);
    scrollView.contentSize = screenSize;    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    [scrollView setDelegate:self];
    
    mapCAView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    [scrollView addSubview:mapCAView];
    UITapGestureRecognizer *tapHandler = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
    [scrollView addGestureRecognizer:tapHandler];
    
    
    NSString *sceneplistPath = [[NSBundle mainBundle] pathForResource:@"scenes" ofType:@"plist"];
    NSDictionary *scenemainDict = [NSDictionary dictionaryWithContentsOfFile:sceneplistPath];
    NSMutableArray *scenePList = [NSMutableArray arrayWithArray:[scenemainDict objectForKey:@"Scenes"]];
    scenes = [NSMutableArray arrayWithCapacity:scenePList.count];
    
    for (int i=0; i < scenePList.count; i++) {
        [scenes addObject:[[Scene alloc] initWithDictionary:[scenePList objectAtIndex:i]]];
        [[[scenes objectAtIndex:i] button] addTarget:self action:@selector(scenePressed:) forControlEvents:UIControlEventTouchDown];
        [[scenes objectAtIndex:i] button].tag = i;
        
        //stopping at count-1  to not add the campfire button to the toplayer container - need a better way
        if (i < scenePList.count - 1) [buttonContainer addSubview:[[scenes objectAtIndex:i] button]];
    }
    
    NSString *mapLayerPListPath = [[NSBundle mainBundle] pathForResource:@"mapLayers" ofType:@"plist"];
    NSDictionary *mapLayerPListMainDict = [NSDictionary dictionaryWithContentsOfFile:mapLayerPListPath];
    parallaxLayers = [self mapLayerPListPlacer:mapLayerPListMainDict :screenSize :mapCAView.layer : scenes];
    
    map1CA = [parallaxLayers objectAtIndex:0];
    map1BCA = [parallaxLayers objectAtIndex:1];
    map1CCA = [parallaxLayers objectAtIndex:2];
    map2CA = [parallaxLayers objectAtIndex:3];
    map4CA = [parallaxLayers objectAtIndex:4];
    
    buttonContainer.bounds = [(CALayer*)parallaxLayers.lastObject bounds];   //set bounds to toplayer
    buttonContainer.center = CGPointMake([(CALayer*)parallaxLayers.lastObject position].x, 0);
    [scrollView addSubview:buttonContainer];
    [scrollView addSubview:foursquareConnectButton];

    //--> sky
    {
        UIImage *skyImage = [UIImage imageNamed:@"sky.jpg"];
        CGRect skyFrame = CGRectMake(0, 0, skyImage.size.width/2, skyImage.size.height/2);
        [map0CA setBounds:skyFrame];
        [map0CA setPosition:CGPointMake(screenSize.width/2, mapCAView.frame.size.height)];
        CGImageRef map0Image = [skyImage CGImage];
        [map0CA setContents:(__bridge id)map0Image];
        [map0CA setZPosition:-5];
        map0CA.opaque = YES;
        [mapCAView.layer addSublayer:map0CA];
    }
    //--> rock
    {
        CALayer *rock = [CALayer layer];
        UIImage *rockImg = [UIImage imageNamed:@"top_lvl4_objs_11.png"];
        //rock.bounds = CGRectMake(0, 0, rockImg.size.width, rockImg.size.height);
        //rock.position = CGPointMake(5275, screenSize.height - rock.bounds.size.height/2);
        rock.frame = CGRectMake(5100, screenSize.height - rockImg.size.height/2, rockImg.size.width/2, rockImg.size.height/2);
        CGImageRef rockCGImage = [rockImg CGImage];
        [rock setContents:(__bridge id)rockCGImage];
        rock.zPosition = 3;
        [mapCAView.layer addSublayer:rock];
    }
    //-->noose animation
    {
        CALayer *hangnoose2 = [CALayer layer];
        UIImage *hangnoose2img = [UIImage imageNamed:@"top_lvl4_objs_10B.png"];
        hangnoose2.bounds = CGRectMake(0, 0, hangnoose2img.size.width/2, hangnoose2img.size.height/2);
        hangnoose2.position = CGPointMake(11557, 27);
        hangnoose2.anchorPoint = CGPointMake(.5, 0);
        CGImageRef hangnoose2Image = [hangnoose2img CGImage];
        [hangnoose2 setContents:(__bridge id)hangnoose2Image];
        [(CALayer*)parallaxLayers.lastObject addSublayer:hangnoose2];
        
        CABasicAnimation* nooseAnimation;
        nooseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        nooseAnimation.fromValue = [NSNumber numberWithFloat:2.0 * M_PI];
        nooseAnimation.toValue = [NSNumber numberWithFloat:2.02 * M_PI];
        nooseAnimation.duration = 1.5;
        //animation.cumulative = YES;
        nooseAnimation.autoreverses = YES;
        nooseAnimation.repeatCount = HUGE_VAL;
        nooseAnimation.removedOnCompletion = NO;
        nooseAnimation.fillMode = kCAFillModeForwards;
        nooseAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        [hangnoose2 addAnimation:nooseAnimation forKey:@"transform.rotation.z"];
    }
    //-->cactus bird animation
    {
        CGSize fixedSize = CGSizeMake(264, 253);
        CGImageRef cactusbirdimg = [[UIImage imageNamed:@"cactusbird"] CGImage];
        MCSpriteLayer* cactusbird = [MCSpriteLayer layerWithImage:cactusbirdimg sampleSize:fixedSize];
        cactusbird.position = CGPointMake(10440, 90);
        
        CAKeyframeAnimation *cactusbirdAnimation = [CAKeyframeAnimation animationWithKeyPath:@"sampleIndex"];
        cactusbirdAnimation.duration = 5.0f;
        //cactusbirdAnimation.autoreverses = YES;
        cactusbirdAnimation.repeatCount = HUGE_VALF;
        cactusbirdAnimation.calculationMode = kCAAnimationDiscrete;
        cactusbirdAnimation.removedOnCompletion = NO;
        cactusbirdAnimation.fillMode = kCAFillModeForwards;
        
        cactusbirdAnimation.values = [NSArray arrayWithObjects:
                                [NSNumber numberWithInt:1],
                                [NSNumber numberWithInt:2],
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:2],
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:4],
                                [NSNumber numberWithInt:1],
                                [NSNumber numberWithInt:1],nil]; //not called
        
        cactusbirdAnimation.keyTimes = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.0],
                                  [NSNumber numberWithFloat:0.1],
                                  [NSNumber numberWithFloat:0.12],
                                  [NSNumber numberWithFloat:0.14],
                                  [NSNumber numberWithFloat:0.16],
                                  [NSNumber numberWithFloat:0.2],
                                  [NSNumber numberWithFloat:0.35],
                                  [NSNumber numberWithFloat:0], nil]; //not called
        
        [cactusbird addAnimation:cactusbirdAnimation forKey:@"cactusbird"];
        [(CALayer*)parallaxLayers.lastObject addSublayer:cactusbird];
        }
    //-->campFire eyes animation
    {
        blackPanel = [CALayer layer];
        [blackPanel setBounds:CGRectMake(0, 0, 340, screenSize.height)];
        [blackPanel setPosition:CGPointMake(screenSize.width - blackPanel.bounds.size.width/2, screenSize.height/2)];
        blackPanel.backgroundColor = [UIColor blackColor].CGColor;
        blackPanel.zPosition = 3;
        [mapCAView.layer addSublayer:blackPanel];
        
        //the colors for the gradient.  highColor is at the right, lowColor as at the left
        UIColor * highColor = [UIColor colorWithWhite:0.0 alpha:1.0];
        UIColor * lowColor = [UIColor colorWithRed:.4 green:.1 blue:.1 alpha:0];
        
        CAGradientLayer * gradient = [CAGradientLayer layer];
        [gradient setFrame:CGRectMake(0, 0, blackPanel.bounds.size.width*2, blackPanel.bounds.size.height)];
        [gradient setColors:[NSArray arrayWithObjects:(id)[highColor CGColor], (id)[lowColor CGColor], nil]];
        [gradient setStartPoint:CGPointMake(1, .5)];
        [gradient setEndPoint:CGPointMake(0, .5)];
        
        CALayer * roundRect = [CALayer layer];
        [roundRect setFrame:gradient.frame];
        [roundRect setPosition:CGPointMake(blackPanel.bounds.size.width - roundRect.frame.size.width, roundRect.frame.size.height/2)];
        [roundRect setMasksToBounds:YES];
        [roundRect addSublayer:gradient];
        [blackPanel addSublayer:roundRect];
        
        CGSize fixedSize = CGSizeMake(619, 152);
        CGImageRef eyesImage = [[UIImage imageNamed:@"eyeBlink"] CGImage];
        MCSpriteLayer* eyesSprite = [MCSpriteLayer layerWithImage:eyesImage sampleSize:fixedSize];
        eyesSprite.position = CGPointMake(blackPanel.bounds.size.width/2.5, blackPanel.bounds.size.height/2);
    
        CAKeyframeAnimation *eyesAnimation = [CAKeyframeAnimation animationWithKeyPath:@"sampleIndex"];
        eyesAnimation.duration = 3.0f;
        eyesAnimation.repeatCount = HUGE_VALF;
        eyesAnimation.calculationMode = kCAAnimationDiscrete;
        eyesAnimation.removedOnCompletion = NO;
        eyesAnimation.fillMode = kCAFillModeForwards;
        
        eyesAnimation.values = [NSArray arrayWithObjects:
                            [NSNumber numberWithInt:1],
                            [NSNumber numberWithInt:2],
                            [NSNumber numberWithInt:3],
                            [NSNumber numberWithInt:5], 
                            [NSNumber numberWithInt:4], 
                            [NSNumber numberWithInt:1], 
                            [NSNumber numberWithInt:1],nil]; //not called
        
        eyesAnimation.keyTimes = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.0], 
                              [NSNumber numberWithFloat:0.1], 
                              [NSNumber numberWithFloat:0.12], 
                              [NSNumber numberWithFloat:0.18], 
                              [NSNumber numberWithFloat:0.3], 
                              [NSNumber numberWithFloat:.4],
                              [NSNumber numberWithFloat:0], nil]; //not called 
        
        [eyesSprite addAnimation:eyesAnimation forKey:@"eyeBlink"];
        [blackPanel addSublayer:eyesSprite];
    }
    //-->bird animation
    {
        CGSize fixedSize = CGSizeMake(116, 74);
        CGImageRef birdImage = [[UIImage imageNamed:@"bird"] CGImage];
        MCSpriteLayer* birdSprite = [MCSpriteLayer layerWithImage:birdImage sampleSize:fixedSize];
        birdSprite.position = CGPointMake(640*2, scrollView.contentSize.height/6);
        
        CABasicAnimation *birdAnimation = [CABasicAnimation animationWithKeyPath:@"sampleIndex"];
        birdAnimation.fromValue = [NSNumber numberWithInt:1];
        birdAnimation.toValue = [NSNumber numberWithInt:15];
        birdAnimation.duration = 2.0f;
        birdAnimation.repeatCount = HUGE_VALF;
        
        [birdSprite addAnimation:birdAnimation forKey:@"birdCircle"];
        [mapCAView.layer addSublayer:birdSprite];
        //[(CALayer*)[parallaxLayers objectAtIndex:1] addSublayer:birdSprite];
    }
    //-->riverWaves animation
    {
        CGSize fixedSize = CGSizeMake(924, 240);
        CGImageRef riverImage = [[UIImage imageNamed:@"riverWaves"] CGImage];
        MCSpriteLayer* riverSprite = [MCSpriteLayer layerWithImage:riverImage sampleSize:fixedSize];
        riverSprite.position = CGPointMake(640*4 + 423, scrollView.contentSize.height/2 +3);
        
        CABasicAnimation *riverAnimation = [CABasicAnimation animationWithKeyPath:@"sampleIndex"];
        riverAnimation.fromValue = [NSNumber numberWithInt:1];
        riverAnimation.toValue = [NSNumber numberWithInt:3];
        riverAnimation.duration = 1.4f;
        riverAnimation.repeatCount = HUGE_VALF;
        
        [riverSprite addAnimation:riverAnimation forKey:@"riverWaves"];
        [mapCAView.layer addSublayer:riverSprite];
        //[(CALayer*)[parallaxLayers objectAtIndex:1] addSublayer:riverSprite];
    }
    //-->jane avatar
    {
        CGImageRef avatarImage = [[UIImage imageNamed:@"janeFixed"] CGImage];
        [janeAvatar setContents:(__bridge id)avatarImage];
        [janeAvatar setZPosition:2];
        janeAvatar.name = @"janeAvatar";
        [mapCAView.layer addSublayer:janeAvatar];
        [self renderScreen:[[NSUserDefaults standardUserDefaults] boolForKey:@"walkingForward"]:FALSE];

    }
    
    [CATransaction commit];

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGPoint center = CGPointMake([[NSUserDefaults standardUserDefaults] floatForKey:@"scroll_view_position"], 0);
    NSLog(@"saved center %f", center.x);
    scrollView.contentOffset = center;
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"] && [[Tumbleweed weed] tumbleweedId]){
        NSLog(@"access token %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"access_token"]);
        foursquareConnectButton.enabled = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameSavetNotif:)
                                                 name:@"gameSave" object:nil];
    [self gameState];
    //[self resumeLayer:mapCAView.layer];
    //[self resumeLayer:map1CA];
    //[self resumeLayer:map1BCA];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self saveAvatarPosition];
    //[self pauseLayer:[mapCAView.layer presentationLayer]];
    //[self gameState];
    //[self pauseLayer:map1BCA];
    //[self pauseLayer:map1CA];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
