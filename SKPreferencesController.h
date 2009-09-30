//
//  SKPreferencesController.h
//  Skreenics
//
//  Created by naixn on 23/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SKPreferencesController : NSObject
{
    IBOutlet NSWindow*      window;

    // Global Prefs
    IBOutlet NSMenuItem*    menuItem_outputFolder;
    IBOutlet NSMenuItem*    menuItem_sameAsVideoFolder;
    IBOutlet NSPopUpButton* popup_downloadFolder;
}

- (void)selectMenuItemFromPrefs;

- (IBAction)showPreferences:(id)sender;
- (IBAction)setSaveFolder:(id)sender;
- (IBAction)openSelectOutputFolderSheet:(id)sender;

@end
