//
//  DroneBridge.m
//  parrot
//
//  Created by Patrick cremin on 1/13/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "DroneBridge.h"
#import "Drone.h"
#import "RCTLog.h"

@implementation DroneBridge
{
  Drone* drone;
}

- (id) init
{
  self = [super init];

  drone = [Drone new];

  return self;
}


RCT_EXPORT_METHOD(sendJumpHigh)
{
  [drone sendJumpHigh];
  RCTLogInfo(@"sendJumpHigh");
}


RCT_EXPORT_METHOD(sendJumpLong)
{
  [drone sendJumpLong];
  RCTLogInfo(@"sendJumpLong");
}

RCT_EXPORT_METHOD(spin)
{
  [drone spin];
  RCTLogInfo(@"spin");
}

RCT_EXPORT_METHOD(takePicture)
{
  [drone takePicture];
  RCTLogInfo(@"takePicture");
}

RCT_EXPORT_METHOD(startMediaListThread)
{
  [drone startMediaListThread];
  RCTLogInfo(@"startMediaListThread");
}


RCT_EXPORT_MODULE();

@end
