//
//  Oculus_Rift_DK2PlugIn.m
//  Oculus Rift DK2
//
//  Created by Julius Tarng on 4/29/15.
//  Copyright (c) 2015 Julius Tarng. All rights reserved.
//

// It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering
#import <OpenGL/CGLMacro.h>

#import "Oculus_Rift_DK2PlugIn.h"

#define	kQCPlugIn_Name				@"Oculus Rift DK2"
#define	kQCPlugIn_Description		@"Basic head orientation (in degrees) information from an attached DK2.\n\nPair with two 3D Transform patches inside each other, with Rotation Z on the outer, and Rotation X/Y on the inner."

@implementation Oculus_Rift_DK2PlugIn

// Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
//@dynamic inputFoo, outputBar;

@dynamic outputDeviceConnected;
@dynamic outputHeadOrientationX;
@dynamic outputHeadOrientationY;
@dynamic outputHeadOrientationZ;
@dynamic inputResetOrientation;

+ (NSDictionary *)attributes
{
	// Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
    return @{QCPlugInAttributeNameKey:kQCPlugIn_Name, QCPlugInAttributeDescriptionKey:kQCPlugIn_Description};
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
	// Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
  
  if([key isEqualToString:@"outputDeviceConnected"])
    return @{QCPortAttributeNameKey: @"Connected"};
  
  if([key isEqualToString:@"outputHeadOrientationX"])
    return @{QCPortAttributeNameKey: @"Rotation X"};
  
  if([key isEqualToString:@"outputHeadOrientationY"])
    return @{QCPortAttributeNameKey: @"Rotation Y"};
  
  if([key isEqualToString:@"outputHeadOrientationZ"])
    return @{QCPortAttributeNameKey: @"Rotation Z"};
  
  if([key isEqualToString:@"inputResetOrientation"])
    return @{QCPortAttributeNameKey: @"Reset"};
  
	return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
	// Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode
{
	// Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	return kQCPlugInTimeModeIdle;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
    // Allocate any permanent resource required by the plug-in.
    ovr_Initialize();
    hmd = ovrHmd_Create(0);
    resetOrientationX = 0;
    resetOrientationY = 0;
    resetOrientationZ = 0;
    
    if(!ovrHmd_ConfigureTracking(hmd, ovrTrackingCap_Orientation |
                             ovrTrackingCap_MagYawCorrection |
                             ovrTrackingCap_Position, 0))
    {
      NSLog(@"Error configuring tracking");
    }
	}
	
	return self;
}

-(void)dealloc
{
  if(hmd) { ovrHmd_Destroy(hmd); }
  ovr_Shutdown();
}

@end

@implementation Oculus_Rift_DK2PlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	// Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	
	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
   */
  
  if(ovrHmd_Detect() > 0){
    self.outputDeviceConnected = YES;
    
    trackingState = ovrHmd_GetTrackingState(hmd, ovr_GetTimeInSeconds());
    
    if (trackingState.StatusFlags & (ovrStatus_OrientationTracked | ovrStatus_PositionTracked)) {
      if (self.inputResetOrientation &&
          self.outputHeadOrientationX &&
          self.outputHeadOrientationY &&
          self.outputHeadOrientationZ) {
        resetOrientationX = self.outputHeadOrientationX;
        resetOrientationY = self.outputHeadOrientationY;
        resetOrientationZ = self.outputHeadOrientationZ;
      }

      Posef pose = trackingState.HeadPose.ThePose;
      float x;
      float y;
      float z;
      pose.Rotation.GetEulerAngles<Axis_Y, Axis_X, Axis_Z>(&y, &x, &z);
      
      self.outputHeadOrientationX = resetOrientationX - RadToDegree(x);
      self.outputHeadOrientationY = resetOrientationY - RadToDegree(y);
      self.outputHeadOrientationZ = resetOrientationZ - RadToDegree(z);
    }
  } else {
    self.outputDeviceConnected = NO;
  }
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
	// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
}

@end
