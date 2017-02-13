//
//  ViewController.m
//  BeanDemo
//
//  Created by Alex Wulff on 1/27/17.
//  Copyright © 2017 Conifer Apps. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#define AppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //These notifications will be called from events in the AppDelegate
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(gotAccelerationData:) name:@"GotAcceleration" object:nil];
    [center addObserver:self selector:@selector(beanConnected:) name:@"BeanConnected" object:nil];
    [center addObserver:self selector:@selector(beanDisconnected:) name:@"BeanDisconnected" object:nil];
}

-(void)gotAccelerationData: (NSNotification *)notification {
    //Now you can do something with AppDelegate.x AppDelegate.y AppDelegate.z
}

-(void)beanConnected: (NSNotification *)notification {
    //You can update the UI now that a Bean has conneced. Maybe set a label to be the Bean's name? You can access this from AppDelegate.bean.name
    
}

-(void)beanDisconnected: (NSNotification *)notification {
    
}


@end
