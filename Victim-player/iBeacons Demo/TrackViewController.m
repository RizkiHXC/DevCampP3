//
//  TrackViewController.m
//  iBeacons Demo
//
//  Created by M Newill on 27/09/2013.
//  Copyright (c) 2013 Mobient. All rights reserved.
//

#import "TrackViewController.h"

@interface TrackViewController () {
    NSString *lastMajor;
    
    UILabel *deadLabel;
    
    UIImageView *slenderView;
    UIView *deadOverlay;
    
    int timerInt;
    NSTimer *slenderTimer;
    BOOL shouldTimerFire;
    
    AVAudioPlayer *audioPlayer;
    AVAudioPlayer *audioPlayer2;
    
    NSMutableData *responseData;
    
    NSTimer *checkSlender;
}

@end

@implementation TrackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];

    [self.view setBackgroundColor:[UIColor blackColor]];
    
    deadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 100)];
    [deadLabel setText:@"YOU DIED YOU NOOB"];
    [deadLabel setTextAlignment:NSTextAlignmentCenter];
    [deadLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
    [deadLabel setAlpha:0];
    
    
    //Slender Image
    slenderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slenderman.png"]];
    [slenderView setFrame:self.view.frame];
    [slenderView setAlpha:0];
    
    deadOverlay = [[UIView alloc] initWithFrame:self.view.frame];
    [deadOverlay setBackgroundColor:[UIColor redColor]];
    [deadOverlay setAlpha:0];
    
    //Timers
    timerInt = 0;
    
    //Audio
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"zombie" withExtension:@"wav"];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [audioPlayer setNumberOfLoops:0];
    
    //Audio background
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:@"background" withExtension:@"wav"];
    audioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:url2 error:nil];
    [audioPlayer2 setNumberOfLoops:0];
    [audioPlayer2 play];

    lastMajor = @"";
    
    [self.view addSubview:slenderView];
    [self.view addSubview:deadOverlay];
    [self.view addSubview:deadLabel];
    
    
    
    responseData = [NSMutableData data];
    
    
    checkSlender = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(check) userInfo:nil repeats:YES];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)initRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.creatinq.slenderbeacon"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon1 = [[CLBeacon alloc] init];
    
    beacon1 = [beacons objectAtIndex:0];
    
    if(beacon1.accuracy < 0.8) {
        NSString *postURL = [NSString stringWithFormat:@"http://www.hiddestatema.com/slenderman/post/?who=1&beacon=%@&distance=%f", beacon1.major, beacon1.accuracy ];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:postURL]];
        [[NSURLConnection alloc] initWithRequest:request delegate:nil];
    }
    
}

- (void) check {
    NSString *postURL = [NSString stringWithFormat:@"http://www.hiddestatema.com/slenderman/get/"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:postURL]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    responseData = [NSMutableData data];
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    /*// show all values
    for(id key in res) {
        
        id value = [res objectForKey:key];
        
        NSString *keyAsString = (NSString *)key;
        NSString *valueAsString = (NSString *)value;
        
        NSLog(@"key: %@", keyAsString);
        NSLog(@"value: %@", valueAsString);
    }
    
    // extract specific value...
    NSArray *results = [res objectForKey:@"results"];
    
    for (NSDictionary *result in results) {
        NSString *icon = [result objectForKey:@"icon"];
        NSLog(@"icon: %@", icon);
    }
     */
    
    NSString *warning = [NSString stringWithFormat:@"%@", [[[res objectForKey:@"data"] objectForKey:@"player1"] objectForKey:@"warning"]];
    if([warning isEqualToString:@"0"]) {
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor redColor];
        [self warning];
    }
    
    
    
    NSString *death = [NSString stringWithFormat:@"%@", [[[res objectForKey:@"data"] objectForKey:@"player1"] objectForKey:@"death"]];
    if([death isEqualToString:@"0"]) {
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor redColor];
        [self death];
    }
}

- (void) warning {
    [audioPlayer play];
    
    [UIView animateWithDuration:10
                     animations:^{
                         slenderView.alpha = .9;
                     }
                     completion:nil];
}

- (void) death {
    slenderView.alpha = 1;
    deadOverlay.alpha = .9;
    [deadLabel setAlpha:1];
    [audioPlayer stop];
    
    [checkSlender invalidate];
}

- (void) startSlender {
//    if (shouldTimerFire) {
//        timerInt++;
//        if (timerInt > 8) {
            [audioPlayer play];
            
            [UIView animateWithDuration:10
                             animations:^{
                                 slenderView.alpha = .9;
                             }
                             completion:nil];
//        }
//        
//        if (timerInt > 18) {
//            slenderView.alpha = 1;
//            deadOverlay.alpha = .9;
//            [deadLabel setAlpha:1];
//            [audioPlayer stop];
//        }
//        NSLog(@"%i", timerInt);
//    }
}

- (void) resetSlender {
    [audioPlayer stop];
    timerInt = 0;
    [slenderView setAlpha:0];
    [deadOverlay setAlpha:0];
    [deadLabel setAlpha:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
