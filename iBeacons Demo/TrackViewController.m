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
    slenderTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(startSlender) userInfo:nil repeats:YES];
    
    //Audio
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"zombie" withExtension:@"wav"];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [audioPlayer setNumberOfLoops:0];

    lastMajor = @"";
    
    [self.view addSubview:slenderView];
    [self.view addSubview:deadOverlay];
    [self.view addSubview:deadLabel];
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
    
    
    // Check of dichtstbijzijnde bacon anders is dan laatste bacon
    if([lastMajor isEqualToString:[NSString stringWithFormat:@"%@", beacon1.major]]) {
        // Staat nog bij oude bacon
        NSLog(@"Oude beacon");
    } else {
        // Nieuwe bacon dichtstbijzijnde
        NSLog(@"Nieuwe beacon");
        shouldTimerFire = YES;
        [self resetSlender];
        
        lastMajor = [NSString stringWithFormat:@"%@", beacon1.major];
    }

    if(beacon1.accuracy < 0.8) {
        if([[NSString stringWithFormat:@"%@", beacon1.major] isEqualToString:@"16345"]) {
//            [self.view setBackgroundColor:[UIColor purpleColor]];
        } else if([[NSString stringWithFormat:@"%@", beacon1.major] isEqualToString:@"31754"]) {
//            [self.view setBackgroundColor:[UIColor greenColor]];
        } else if([[NSString stringWithFormat:@"%@", beacon1.major] isEqualToString:@"24196"]) {
//            [self.view setBackgroundColor:[UIColor blueColor]];
        } else {
//            [self.view setBackgroundColor:[UIColor whiteColor]];
        }
    } else {
//        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    
    [self startSlender];
  
}

- (void) startSlender {
    if (shouldTimerFire) {
        timerInt++;
        if (timerInt > 8) {
            [audioPlayer play];
            
            [UIView animateWithDuration:10
                             animations:^{
                                 slenderView.alpha = .9;
                             }
                             completion:nil];
        }
        
        if (timerInt > 18) {
            slenderView.alpha = 1;
            deadOverlay.alpha = .9;
            [deadLabel setAlpha:1];
            [audioPlayer stop];
        }
        NSLog(@"%i", timerInt);
    }
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
