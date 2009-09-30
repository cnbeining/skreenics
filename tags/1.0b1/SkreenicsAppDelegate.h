//
//  SkreenicsAppDelegate.h
//  Skreenics
//
//  Created by naixn on 21/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SKPreferencesController.h"
#import "SKDragView.h"
#import "SKDragDelegateProtocol.h"


@interface SkreenicsAppDelegate : NSObject <SKDragDelegateProtocol>
{
    IBOutlet    SKPreferencesController*    preferencesController;
    IBOutlet    SKDragView*                 videoView;
    IBOutlet    NSTableView*                videoTableView;
    IBOutlet    NSToolbarItem*              suspendToolbarItem;
    IBOutlet    NSButton*                   suspendButton;

    NSWindow*               window;
    NSOperationQueue*       operationQueue;
    NSMutableArray*         videoCollection;
    NSUserDefaults*         userDefaults;

    NSArray*                acceptableMovieTypes;
}

@property (assign) IBOutlet NSWindow* window;

- (IBAction)toggleSuspendedStatus:(id)sender;
- (IBAction)removeSelectedItem:(id)sender;
- (IBAction)clearVideoList:(id)sender;
- (IBAction)displayOpenPanel:(id)sender;

@end
