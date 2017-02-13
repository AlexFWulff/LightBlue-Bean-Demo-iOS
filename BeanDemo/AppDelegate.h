//
//  AppDelegate.h
//  BeanDemo
//
//  Created by Alex Wulff on 1/27/17.
//  Copyright © 2017 Conifer Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PTDBeanManager.h>
#import <PTDBeanRadioConfig.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PTDBeanManagerDelegate, PTDBeanDelegate>

@property (strong, nonatomic) UIWindow *window;

//Bean properties
@property (strong, nonatomic) PTDBean *bean;
@property (nonatomic, strong) NSMutableDictionary *beans;
@property (nonatomic, strong) PTDBeanManager *beanManager;
@property (strong, nonatomic) NSMutableArray *sensorLogs;

//Acceleration
@property (nonatomic) double x;
@property (nonatomic) double y;
@property (nonatomic) double z;

@end

