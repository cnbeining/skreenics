//
//  SKPreferencesController.m
//  Skreenics
//
//  Created by naixn on 23/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import "SKPreferencesController.h"
#import "SKDefines.h"


@implementation SKPreferencesController

- (IBAction)showPreferences:(id)sender
{
    [window makeKeyAndOrderFront:self];
}

- (void)awakeFromNib
{
    [self selectMenuItemFromPrefs];
}

- (void)selectMenuItemFromPrefs
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSKPreferMovieFileFolderPrefKey] == YES)
    {
        [popup_downloadFolder selectItem:menuItem_sameAsVideoFolder];
    }
    else
    {
        [popup_downloadFolder selectItem:menuItem_outputFolder];
    }
}

- (IBAction)setSaveFolder:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:([popup_downloadFolder selectedItem] == menuItem_sameAsVideoFolder)
                                            forKey:kSKPreferMovieFileFolderPrefKey];
}

- (void)folderSheetClosed:(NSOpenPanel *)openPanel returnCode:(int)code contextInfo:(void *)info
{
    if (code == NSOKButton)
    {
        [popup_downloadFolder selectItem:menuItem_outputFolder];
        [[NSUserDefaults standardUserDefaults] setObject:[[[openPanel URLs] objectAtIndex:0] path] forKey:kSKOuputFolderPrefKey];
        [self setSaveFolder:self];
    }
    else
    {
        [self selectMenuItemFromPrefs];
    }
}

- (IBAction)openSelectOutputFolderSheet:(id)sender
{
    NSOpenPanel*    panel = [NSOpenPanel openPanel];

    [panel setTitle:@"Select Save Folder"];
    [panel setPrompt:@"Select"];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetForDirectory:nil
                             file:nil
                            types:nil
                   modalForWindow:window
                    modalDelegate:self
                   didEndSelector:@selector(folderSheetClosed:returnCode:contextInfo:)
                      contextInfo: nil];
}

@end
