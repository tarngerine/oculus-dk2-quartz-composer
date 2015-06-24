//
//  Oculus_Rift_DK2PlugIn.h
//  Oculus Rift DK2
//
//  Created by Julius Tarng on 4/29/15.
//  Copyright (c) 2015 Julius Tarng. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "OVR.h"

using namespace OVR;

@interface Oculus_Rift_DK2PlugIn : QCPlugIn
{
  ovrHmd hmd;
  ovrTrackingState trackingState;
  double resetOrientationX;
  double resetOrientationY;
  double resetOrientationZ;
}


@property (atomic, readwrite, copy) NSString* displayDeviceName;
//@property (atomic, readwrite, assign) double distortionK0;

// Declare here the properties to be used as input and output ports for the plug-in e.g.
//@property double inputFoo;
//@property (copy) NSString* outputBar;

@property BOOL outputDeviceConnected;
@property double outputHeadOrientationX;
@property double outputHeadOrientationY;
@property double outputHeadOrientationZ;
@property BOOL inputResetOrientation;

@end
