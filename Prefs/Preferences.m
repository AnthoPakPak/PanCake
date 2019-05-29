#import "Preferences.h"

@implementation PCPrefsListController

- (instancetype)init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        self.hb_appearanceSettings = appearanceSettings;

        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.anthopak.pancake.list"]) {
            NSLog(@"PanCake: Official tweak source (y)");
        } else {
            NSLog(@"PanCake: Hello cracker!");
        }
    }

    return self;
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Prefs" target:self] retain];
    }
    return _specifiers;
}

-(void) viewDidLoad {
    [super viewDidLoad];

    // self.table.contentInset = UIEdgeInsetsMake(-34, 0, 0, 0);
}

- (double)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return tableView.frame.size.width * (300.0f/800.0f); //image ratio
    } else {
        return [self tableView:tableView titleForHeaderInSection:section] ? 45 : 0;
    }
}

- (void)respring:(id)sender {
    NSTask *t = [[[NSTask alloc] init] autorelease];
    [t setLaunchPath:@"/usr/bin/killall"];
    [t setArguments:[NSArray arrayWithObjects:@"SpringBoard", nil]];
    [t launch];
}
@end