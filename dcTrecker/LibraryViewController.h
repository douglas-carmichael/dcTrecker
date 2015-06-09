//
//  LibraryViewController.h
//  dcTrecker
//
//  Created by Douglas Carmichael on 4/13/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Module.h"
#import "LibraryManager.h"

@interface LibraryViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

{
    LibraryManager *ourLibrary;
    IBOutlet NSTableView *libraryTable;
    NSInteger currentRow;
}

-(void)reloadTable;
-(void)doubleClick:(id)object;
-(IBAction)addToLibrary:(id)sender;
-(IBAction)removeFromLibrary:(id)sender;
-(IBAction)newLibrary:(id)sender;
-(IBAction)saveLibraryButton:(id)sender;
-(IBAction)loadLibraryButton:(id)sender;
-(IBAction)writeModuleButton:(id)sender;

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
-(NSString *)newLibraryToolTip;
-(NSString *)openLibraryToolTip;
-(NSString *)saveLibraryToolTip;
-(NSString *)addModuleToolTip;
-(NSString *)removeModuleToolTip;
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@end
