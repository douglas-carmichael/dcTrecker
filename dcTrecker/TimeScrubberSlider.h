//
//  TimeScrubberSlider.h
//  protoPlayer
//
//  Created by Douglas Carmichael on 2/5/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TimeScrubberSlider : NSSlider
{
    IBOutlet id delegate;
}

@property (readwrite, retain) id delegate;

@end
