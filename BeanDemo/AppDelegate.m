//
//  AppDelegate.m
//  BeanDemo
//
//  Created by Alex Wulff on 1/27/17.
//  Copyright © 2017 Conifer Apps. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - BeanManagerDelegate Callbacks

//This is the first thing called. It starts the BeanManager scanning for any nearby beans.
- (void)beanManagerDidUpdateState:(PTDBeanManager *)manager{
    if(self.beanManager.state == BeanManagerState_PoweredOn){
        [self.beanManager startScanningForBeans_error:nil];
    }
    
    else if (self.beanManager.state == BeanManagerState_PoweredOff) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Turn on bluetooth to continue" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
}

//Now if a bean is discovered, it will try to connect.
- (void)BeanManager:(PTDBeanManager*)beanManager didDiscoverBean:(PTDBean*)bean error:(NSError*)error{
    NSUUID * key = bean.identifier;
    if (![self.beans objectForKey:key]) {
        
        NSLog(@"BeanManager:didDiscoverBean:error %@", bean);
        [self.beans setObject:bean forKey:key];
    }
    
    //Added Code
    NSError *error2;
    [self.beanManager connectToBean:bean error:&error2];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error2 localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
}

//This is called if you call Serial.print from a Bean
- (void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data {
    //get string, see if it is Start RMP Please, then send notification to update status label
    
    NSString *gotString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"New Serial Data: %@",gotString);
    
    //Do Something with the data here....
}

//This is called when the device connects to a bean. I'm using this function to set the power levels of the Bean antenna, but it's not necessary to do that.
- (void)BeanManager:(PTDBeanManager*)beanManager didConnectToBean:(PTDBean*)bean error:(NSError*)error{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    
    //Gets rid of the ten second delay before the Bean starts sending data
    [bean releaseSerialGate];
    
    bean.delegate = self;
    
    self.bean = bean;
    
    [self.beanManager stopScanningForBeans_error:&error];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:bean,@"bean", nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSNotification *dataNotification = [[NSNotification alloc] initWithName:@"BeanConnected" object:nil userInfo:userInfo];
    [center postNotification:dataNotification];
    
    //Configure these properties how you would like. This code sets it for most power efficient and lowest range
    PTDBeanRadioConfig *config = [[PTDBeanRadioConfig alloc] init];
    config.advertisingInterval = 1200;
    config.power = PTDTxPower_neg6dB;
    config.connectionInterval = 20;
    config.name = bean.name;
    [bean setRadioConfig:config];
    [bean readRadioConfig];
}

-(void)bean:(PTDBean*)bean didUpdateRadioConfig:(PTDBeanRadioConfig*)config {
    NSString *msg = [NSString stringWithFormat:@"received advertising interval:%f connection interval:%f name:%@ power:%d", config.advertisingInterval, config.connectionInterval, config.name, (int)config.power];
    NSLog(@"%@",msg);
}

- (void)BeanManager:(PTDBeanManager*)beanManager didDisconnectBean:(PTDBean*)bean error:(NSError*)error{
    [self.beans removeObjectForKey:bean.identifier];
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:bean,@"bean", nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSNotification *dataNotification = [[NSNotification alloc] initWithName:@"BeanDisconnected" object:nil userInfo:userInfo];
    [center postNotification:dataNotification];
    
    self.bean = nil;
    
    NSLog(@"Bean disconnect!!!");
}

//This is called when the bean responds to a [bean readAccelerationAxes] call
-(void)bean:(PTDBean *)bean didUpdateAccelerationAxes:(PTDAcceleration)acceleration {
    self.x = acceleration.x;
    self.y = acceleration.y;
    self.z = acceleration.z;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSNotification *dataNotification = [[NSNotification alloc] initWithName:@"GotAcceleration" object:nil userInfo:nil];
    [center postNotification:dataNotification];
}



@end
