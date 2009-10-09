//
//  SKPreferencesController.m
//  Skreenics
//
//  Created by naixn on 23/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import "SKPreferencesController.h"
#import "SKDefines.h"

static SKFileTypes gl_skAvailableFileTypes[] = {
    {@"PNG",  @"png", NSPNGFileType},
    {@"JPEG", @"jpg", NSJPEGFileType},
    {nil, nil, 0}
};

@implementation SKPreferencesController

- (id)init
{
    if (self = [super init])
    {
        int i;

        fileTypes = [[NSMutableArray alloc] init];
        for (i = 0; gl_skAvailableFileTypes[i].displayName; i++)
        {
            [fileTypes addObject:(gl_skAvailableFileTypes[i].displayName)];
        }
    }
    return self;
}

- (void)dealloc
{
    [fileTypes release];
    [super dealloc];
}

#pragma mark Class methods

+ (NSBitmapImageFileType)imageFileType
{
    NSString*               imageFormatFromPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSKImageFormatPrefKey];
    int                     i;
    
    for (i = 0; gl_skAvailableFileTypes[i].displayName; i++)
    {
        if ([gl_skAvailableFileTypes[i].displayName isEqualToString:imageFormatFromPrefs])
        {
            return gl_skAvailableFileTypes[i].file_type;
        }
    }
    return NSPNGFileType;
}

+ (NSString *)imageFileExtension
{
    NSString*               imageFormatFromPrefs = [[NSUserDefaults standardUserDefaults] objectForKey:kSKImageFormatPrefKey];
    int                     i;
    
    for (i = 0; gl_skAvailableFileTypes[i].displayName; i++)
    {
        if ([gl_skAvailableFileTypes[i].displayName isEqualToString:imageFormatFromPrefs])
        {
            return gl_skAvailableFileTypes[i].extension;
        }
    }
    return @"png";
}

#pragma mark UI

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
