//
//  xmpPlayer.m
//  xmpPlayerTest
//
//  Created by Douglas Carmichael on 1/18/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "xmpPlayer.h"
#import "xmpPlayerErrors.h"

@implementation xmpPlayer

-(id)init
{
    self = [super init];
    if (self)
    {
        char **xmp_format_list;
        int status, formatArrayIndex = 0;
        xmp_format_list = xmp_get_format_list();
        class_context = xmp_create_context();
        _xmpVersion = [NSString stringWithUTF8String:xmp_version];
        NSMutableArray *tempSupportedFormats = [[NSMutableArray alloc] init];
        
        while (xmp_format_list[formatArrayIndex] != NULL)
        {
            [tempSupportedFormats addObject:[NSString
                                             stringWithUTF8String:xmp_format_list[formatArrayIndex]]];
            formatArrayIndex++;
        }
        _supportedFormats = [tempSupportedFormats copy];
        
        // Set up our audio
        status = NewAUGraph(&myGraph);
        if (status != noErr)
        {
            NSAssert(NO, @"Unable to set up audio processing graph.");
            return 0;
        }
        
        // Set up our default output component
        AudioComponentDescription defaultOutputDescription = {};
        defaultOutputDescription.componentType = kAudioUnitType_Output;
        
        // If we're on iOS, use the proper output device subtype
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
#elif TARGET_OS_MAC
        defaultOutputDescription.componentSubType = kAudioUnitSubType_DefaultOutput;
#endif
        defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        defaultOutputDescription.componentFlags = 0;
        defaultOutputDescription.componentFlagsMask = 0;
        
        // Add that component as an output node to the graph
        AUNode outputNode;
        status = AUGraphAddNode(myGraph, &defaultOutputDescription, &outputNode);
        
        // Set up our mixer component (for volume control)
        AudioComponentDescription mixerDescription = {};
        mixerDescription.componentType = kAudioUnitType_Mixer;
        mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
        mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        mixerDescription.componentFlags = 0;
        mixerDescription.componentFlagsMask = 0;
        
        // Add that component as a mixer node to the graph
        AUNode mixerNode;
        status = AUGraphAddNode(myGraph, &mixerDescription, &mixerNode);
        
        // Set up our converter component
        AudioComponentDescription converterDescription = {};
        converterDescription.componentType = kAudioUnitType_FormatConverter;
        converterDescription.componentSubType = kAudioUnitSubType_AUConverter;
        converterDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        converterDescription.componentFlags = 0;
        converterDescription.componentFlagsMask = 0;
        
        AUNode converterNode;
        status = AUGraphAddNode(myGraph, &converterDescription, &converterNode);
        
        // Connect the converter to the mixer node
        status = AUGraphConnectNodeInput(myGraph, converterNode, 0, mixerNode, 0);
        
        // Connect the mixer to the output node
        status = AUGraphConnectNodeInput(myGraph, mixerNode, 0, outputNode, 0);
        
        
        // Open the graph (NOTE: Must be done before other setup tasks!)
        status = AUGraphOpen(myGraph);
        
        // Grab the converter and mixer as audio units
        AudioUnit converterUnit;
        status = AUGraphNodeInfo(myGraph, converterNode, NULL, &converterUnit);
        status = AUGraphNodeInfo(myGraph, mixerNode, NULL, &mixerUnit);
        
        // Set the mixer input bus count
        UInt32 numBuses = 1;
        status = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input,
                                      0, &numBuses, sizeof(numBuses));
        
        // Enable audio I/O on the multichannel mixer
        status = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 0, 1, 0);
        status = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, 1, 0);
        status = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Global, 0, 1, 0);
        
        // Set our input format description (for the audio coming in from libxmp)
        streamFormat.mSampleRate = 44100;
        streamFormat.mFormatID = kAudioFormatLinearPCM;
        streamFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        streamFormat.mChannelsPerFrame = 2;
        streamFormat.mFramesPerPacket = 1;
        streamFormat.mBitsPerChannel = 16;
        streamFormat.mBytesPerFrame = 4;
        streamFormat.mBytesPerPacket = 4;
        
        status = AudioUnitSetProperty(converterUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Input,
                                      0,
                                      &streamFormat,
                                      sizeof(streamFormat));
        
        // Calculate our buffer size based on sample rate/bytes per frame
        int ourBufferSize = (streamFormat.mSampleRate * streamFormat.mBytesPerFrame) / 4;
        // Set up our circular buffer
        if(!TPCircularBufferInit(&ourClassPlayer.ourBuffer, ourBufferSize))
        {
            NSAssert(NO, @"Unable to set up audio buffer.");
            return 0;
        }
        
        // Get our output unit information
        AudioUnit outputUnit;
        status = AUGraphNodeInfo(myGraph, outputNode, 0, &outputUnit);
        
        // Add the render-notification callback to the graph
        AURenderCallbackStruct ourRenderCallback;
        ourRenderCallback.inputProc = &renderModuleCallback;
        ourRenderCallback.inputProcRefCon = &ourClassPlayer;
        status = AUGraphSetNodeInputCallback(myGraph, converterNode, 0, &ourRenderCallback);
        
        // Initialize and start the AUGraph
        status = AUGraphInitialize(myGraph);
        status = AUGraphStart(myGraph);
    }
    return self;
    
}

-(void)dealloc
{
    // Stop our AUGraph
    AUGraphStop(myGraph);
    
    // Terminate libxmp playback
    if (xmp_get_player(class_context, XMP_STATE_PLAYING) != 0)
    {
        xmp_end_player(class_context);
    }
    if (xmp_get_player(class_context, XMP_STATE_LOADED) != 0)
    {
        xmp_release_module(class_context);
    }
    xmp_free_context(class_context);
    
    // Clean up our buffer
    TPCircularBufferCleanup(&ourClassPlayer.ourBuffer);
    
    // Dispose of our AUGraph
    DisposeAUGraph(myGraph);
}

-(void)loadModule:(Module *)ourModule error:(NSError *__autoreleasing *)error
{
    
    // Test if this file is a valid module.
    int testValue;
    testValue = xmp_test_module((char *)[[ourModule filePath].path UTF8String], NULL);
    if (testValue != 0)
    {
        NSString *errorDescription = NSLocalizedString(@"Cannot load module.", @"");
        NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: errorDescription};
        NSString *xmpErrorDomain = @"net.dcarmichael.xmpPlayer";
        *error = [NSError errorWithDomain:xmpErrorDomain code:xmpLoadingError userInfo:errorInfo];
        return;
    }
    
    // If we're playing, stop playback.
    if (xmp_get_player(class_context, XMP_STATE_PLAYING) != 0)
    {
        xmp_end_player(class_context);
        ourPlayback = NO;
    }
    
    // Load the module
    if (xmp_load_module(class_context, (char *)[[ourModule filePath].path UTF8String]) != 0)
    {
        if (error != NULL)
        {
            NSString *errorDescription = NSLocalizedString(@"Cannot load module.", @"");
            NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: errorDescription};
            NSString *xmpErrorDomain = @"net.dcarmichael.xmpPlayer";
            *error = [NSError errorWithDomain:xmpErrorDomain code:xmpLoadingError userInfo:errorInfo];
            return;
        }
        return;
    }
    
    // Scan for module information and make it available
    struct xmp_module_info pModuleInfo;
    xmp_get_module_info(class_context, &pModuleInfo);
    
    if ([ourModule.moduleName isNotEqualTo:@"<unnamed>"])
    {
        ourModule.moduleName = [NSString stringWithUTF8String:pModuleInfo.mod->name];
    }
    
    ourModule.numPatterns = pModuleInfo.mod->pat;
    ourModule.numTracks = pModuleInfo.mod->trk;
    ourModule.numChannels = pModuleInfo.mod->chn;
    ourModule.numInstruments = pModuleInfo.mod->ins;
    ourModule.numSamples = pModuleInfo.mod->smp;
    ourModule.initSpeed = pModuleInfo.mod->spd;
    ourModule.initBPM = pModuleInfo.mod->bpm;
    ourModule.modLength = pModuleInfo.mod->len;
    ourModule.modRestartPos = pModuleInfo.mod->rst;
    ourModule.modGlobalVolume = pModuleInfo.mod->gvl;
    ourModule.modTotalTime = pModuleInfo.seq_data[0].duration;
    
    return;
    
}

-(void)unloadModule
{
    if (xmp_get_player(class_context, XMP_STATE_LOADED) != 0)
    {
        xmp_release_module(class_context);
    }
    return;
}

-(void)nextPlayPosition
{
    int status;
    status = xmp_next_position(class_context);
}

-(void)prevPlayPosition
{
    int status;
    status = xmp_prev_position(class_context);
}

-(void)playModule:(NSError **)error
{
    
    int status;
    ourClassPlayer.stopped_flag = false;
    
    // Do we have a module loaded or playing?
    status = xmp_get_player(class_context, XMP_PLAYER_STATE);
    if (status == XMP_STATE_UNLOADED)
    {
        if (error != NULL)
        {
            NSString *errorDescription = NSLocalizedString(@"No module loaded.", @"");
            NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: errorDescription};
            NSString *xmpErrorDomain = @"net.dcarmichael.xmpPlayer";
            *error = [NSError errorWithDomain:xmpErrorDomain code:xmpFileError userInfo:errorInfo];
            return;
        }
    }
    
    // If we're playing, stop playback just to be sure.
    if (status == XMP_STATE_PLAYING)
    {
        xmp_stop_module(class_context);
    }
    
    // Start playback with the sample rate specified in the ASBD
    status = xmp_start_player(class_context, streamFormat.mSampleRate, 0);
    if (status != 0)
    {
        if (error != NULL)
        {
            NSString *errorDescription = NSLocalizedString(@"Cannot start playback.", @"");
            NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: errorDescription};
            NSString *xmpErrorDomain = @"net.dcarmichael.xmpPlayer";
            *error = [NSError errorWithDomain:xmpErrorDomain code:xmpSystemError userInfo:errorInfo];
            return;
        }
    }
    
    // If we've succeeded, set our error value to nil
    if (error != NULL)
    {
        *error = nil;
    }
    
    do
    {
        do
        {
            struct xmp_frame_info ourFrameInfo;
            
            xmp_get_frame_info(class_context, &ourFrameInfo);
            
            if (ourFrameInfo.loop_count > 0)
                break;
            // Check for stopping and break if selected.
            if (ourClassPlayer.stopped_flag)
                break;
            
            // Update our position information
            _playerPosition = ourFrameInfo.pos;
            _playerPattern = ourFrameInfo.pattern;
            _playerRow = ourFrameInfo.row;
            _playerBPM = ourFrameInfo.bpm;
            _playerTime = ourFrameInfo.time;
            
            
            // Post our notification
            NSString *notificationName = @"dcXmpPlayer";
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
            
            // Declare some variables for us to use within the buffer loop
            void *bufferDest;
            int bufferAvailable;
            
            // Tell everyone else we're not at the end
            ourPlayback = YES;
            
            // Let's start putting the data out into the buffer
            do {
                bufferDest = TPCircularBufferHead(&ourClassPlayer.ourBuffer, &bufferAvailable);
                if(bufferAvailable < ourFrameInfo.buffer_size)
                {
                    usleep(100000);
                }
                // Check for stopping and break if selected.
                if (ourClassPlayer.stopped_flag)
                    break;
            } while(bufferAvailable < ourFrameInfo.buffer_size);
            
            // Check for stopping (pause with an AUGraphStop() call.)
            if (ourClassPlayer.stopped_flag)
                break;
            memcpy(bufferDest, ourFrameInfo.buffer, ourFrameInfo.buffer_size);
            TPCircularBufferProduce(&ourClassPlayer.ourBuffer, ourFrameInfo.buffer_size);
        } while (xmp_play_frame(class_context) == 0);
    } while(!ourClassPlayer.reached_end);
    
    // Tell everyone else we've reached the end
    ourPlayback = NO;
}

-(void)pauseResume
{
    // Check if our AUGraph is running
    int err;
    Boolean isRunning;
    
    err = AUGraphIsRunning(myGraph, &isRunning);
    if (isRunning)
    {
        _isPaused = YES;
        AUGraphStop(myGraph);
    }
    else
    {
        _isPaused = NO;
        AUGraphStart(myGraph);
    }
}

-(BOOL)isPlaying
{
    int err;
    Boolean isRunning;
    if (ourPlayback)
    {
        err = AUGraphIsRunning(myGraph, &isRunning);
        if (_isPaused == YES)
        {
            return YES;
        }
        return isRunning;
    }
    return NO;
}

-(BOOL)isGraphRunning
{
    int err;
    Boolean isRunning;
    err = AUGraphIsRunning(myGraph, &isRunning);
    return isRunning;
}

-(void)stopPlayer
{
    int err;
    Boolean isRunning;
    xmp_stop_module(class_context);
    ourClassPlayer.stopped_flag = true;
    
    // If we've been paused, kickstart the AUGraph to make sure we have it available.
    if (_isPaused == YES)
    {
        err = AUGraphIsRunning(myGraph, &isRunning);
        if (!isRunning)
        {
            AUGraphStart(myGraph);
        }
    }
    
    while ([self isPlaying])
    {
        // Wait here and do nothing until the AUGraph stops
    }
    
}

-(void)setChannelVolume:(NSInteger)ourChannel volume:(NSInteger)ourVolume
{
    int status;
    status = xmp_channel_vol(class_context, (int)ourChannel, (int)ourVolume);
}

-(void)setMasterVolume:(float)volume
{
    AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume,
                          kAudioUnitScope_Output, 0, volume, 0);
}


-(void)seekPlayerToTime:(NSInteger)seekValue
{
    int status;
    status = xmp_seek_time(class_context, (int)seekValue);
}

-(NSString*)getTimeString:(int)timeValue
{
    NSInteger minutes, seconds;
    
    if (timeValue == 0)
    {
        minutes = 0;
        seconds = 0;
        NSString *timeReturn = @"00:00";
        return timeReturn;
    }
    else
    {
        minutes = ((timeValue + 500) / 60000);
        seconds = ((timeValue + 500) / 1000) % 60;
        
        // If we're on a 64-bit system, NSInteger is a long.
        // From: http://stackoverflow.com/questions/4445173/when-to-use-nsinteger-vs-int
        
#if __LP64__ || TARGET_OS_EMBEDDED || TARGET_OS_IPHONE || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
        NSString *timeReturn = [[NSString alloc] initWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
#else
        NSString *timeReturn = [[NSString alloc] initWithFormat:@"%02d:%02d", minutes, seconds];
#endif
        return timeReturn;
    }
}


-(BOOL)isLoaded
{
    int status;
    status = xmp_get_player(class_context, XMP_PLAYER_STATE);
    switch (status)
    {
        case XMP_STATE_LOADED:
            return YES;
            break;
        case XMP_STATE_PLAYING:
            return YES;
            break;
        case XMP_STATE_UNLOADED:
            return NO;
            break;
            
        default:
            return NO;
            break;
    }
}

@end

OSStatus renderModuleCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags,
                              const AudioTimeStamp *inTimeStamp,
                              UInt32 inBusNumber,
                              UInt32 inBufferFrames,
                              AudioBufferList *ioData)
{
    
    struct class_playback *our_playback = inRefCon;
    int bytesAvailable = 0;
    
    /* Grab the data from the circular buffer into the temporary buffer */
    SInt16 *tempBuffer = TPCircularBufferTail(&our_playback->ourBuffer, &bytesAvailable);
    
    if (bytesAvailable == 0)
    {
        // Fill the buffer with zeroes to prevent pops/noise
        memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize);
        our_playback->reached_end = true;
    }
    
    int toCopy = MIN(bytesAvailable, ioData->mBuffers[0].mDataByteSize);
    
    /* memcpy() the data to the audio output */
    memcpy(ioData->mBuffers[0].mData, tempBuffer, toCopy);
    
    /* Clear that section of the buffer */
    TPCircularBufferConsume(&our_playback->ourBuffer, toCopy);
    
    return noErr;
}
