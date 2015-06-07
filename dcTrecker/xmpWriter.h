//
//  xmpWriter.h
//  xmpWriterTest
//
//  Created by Douglas Carmichael on 1/18/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "xmp.h"
#import "Module.h"

@interface xmpWriter : NSObject

{
    xmp_context writer_context;
    
}

@property (readonly) NSString *xmpVersion;
@property (readonly) NSArray *supportedFormats;

-(void)loadModule:(Module *)ourModule error:(NSError *__autoreleasing *)error;
-(void)writeModuleWAV:(NSURL *)moduleWriteURL error:(NSError *__autoreleasing *)error;

@end
