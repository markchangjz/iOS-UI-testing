#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController () <UIAlertViewDelegate, UISearchDisplayDelegate> {
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
}

@property (strong, nonatomic) NSArray *objects, *filteredArray;
@property (assign, nonatomic) BOOL ascending;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Master";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor magentaColor];
    [refreshControl addTarget:self action:@selector(changeSorting) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self setBarButtonItems];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [searchBar sizeToFit];
    self.tableView.tableHeaderView = searchBar;
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
}

- (void)setBarButtonItems
{
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
    [addBtn setAccessibilityIdentifier:@"Add"];
    
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(enterEditMode)];
    [editBtn setAccessibilityIdentifier:@"Edit"];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(leaveEditMode)];
    [doneBtn setAccessibilityIdentifier:@"Done"];
    
    self.navigationItem.leftBarButtonItem = addBtn;
    self.navigationItem.rightBarButtonItem = self.tableView.isEditing ? doneBtn : editBtn;
}

- (void)enterEditMode
{
    [self.tableView setEditing:YES animated:YES];
    [self setBarButtonItems];
}

- (void)leaveEditMode
{
    [self.tableView setEditing:NO animated:YES];
    [self setBarButtonItems];
}

- (void)addItem
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Item"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Add", nil];
    
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    [alertView show];
}

- (void)changeSorting
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:self.ascending];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    self.objects = [self.objects sortedArrayUsingDescriptors:sortDescriptors];
    
    self.ascending = !self.ascending;
    
    [self performSelector:@selector(updateTable) withObject:nil afterDelay:2];
}

- (void)updateTable
{
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void)storeCell
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.objects forKey:@"STORE_KEY"];
    [defaults synchronize];
}

#pragma mark - lazy instantiation

- (NSArray *)objects
{
    if (!_objects) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:@"STORE_KEY"]) {
            _objects = [defaults objectForKey:@"STORE_KEY"];
        }
        else {
            _objects = @[@"Argentina", @"Australia", @"Brazil", @"Ecuador", @"England", @"Germany", @"Italy", @"Japan", @"New Zealand", @"United States"];
        }
    }
    
    return _objects;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = 0;
    
    if (tableView == self.tableView) {
        rows = self.objects.count;
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchBar.text];
        self.filteredArray = [self.objects filteredArrayUsingPredicate:predicate];
        rows = self.filteredArray.count;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    cell.textLabel.highlightedTextColor = [UIColor redColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (tableView == self.tableView) {
        cell.textLabel.text = [self.objects objectAtIndex:indexPath.row];
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.filteredArray objectAtIndex:[indexPath row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (tableView == self.tableView) {
            NSMutableArray *mObjects = [self.objects mutableCopy];
            [mObjects removeObjectAtIndex:indexPath.row];
            self.objects = [mObjects copy];
        }
        else if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSMutableArray *mObjects = [self.objects mutableCopy];
            NSMutableArray *mFilteredArray = [self.filteredArray mutableCopy];
            
            [mObjects removeObject:[mFilteredArray objectAtIndex:indexPath.row]];
            [mFilteredArray removeObjectAtIndex:indexPath.row];
            
            self.objects = [mObjects copy];
            self.filteredArray = [mFilteredArray copy];
            
            [self.tableView reloadData];
        }
        
        [self storeCell];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        [self performSelector:@selector(tableViewReloadData:) withObject:tableView afterDelay:1.0];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString *item = [self.objects objectAtIndex:sourceIndexPath.row];
    
    NSMutableArray *mObjects = [self.objects mutableCopy];
    
    [mObjects removeObjectAtIndex:sourceIndexPath.row];
    [mObjects insertObject:item atIndex:destinationIndexPath.row];
    
    self.objects = [mObjects copy];
    
    [self storeCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    
    if (tableView == self.tableView) {
        detailViewController.detailItem = [self.objects objectAtIndex:indexPath.row];
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView) {
        detailViewController.detailItem = [self.filteredArray objectAtIndex:indexPath.row];
    }
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = (indexPath.row % 2) ? [UIColor whiteColor] : [UIColor colorWithRed:0.9 green:0.95 blue:1.0 alpha:1.0];
}

- (void)tableViewReloadData:(UITableView *)sender
{
    [sender reloadData];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            NSLog(@"Add %@", [[alertView textFieldAtIndex:0] text]);
            
            NSMutableArray *mObjects = [self.objects mutableCopy];
            [mObjects addObject:[[alertView textFieldAtIndex:0] text]];
            self.objects = [mObjects copy];
            
            self.objects = [self.objects sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:nil ascending:!self.ascending]]];
            
            NSLog(@"index at %lx", [self.objects indexOfObject:[[alertView textFieldAtIndex:0] text]]);
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.objects indexOfObject:[[alertView textFieldAtIndex:0] text]] inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self storeCell];
            
            [self performSelector:@selector(tableViewReloadData:) withObject:self.tableView afterDelay:1.0];
            
            break;
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    
    if(inputText.length > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
