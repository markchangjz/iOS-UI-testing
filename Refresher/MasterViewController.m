#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController () <UISearchResultsUpdating, UISearchBarDelegate>
{
    UISearchBar *searchBar;
    UISearchController *searchController;
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
    
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.obscuresBackgroundDuringPresentation = NO;
    searchBar.delegate = self;
    
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = searchController.searchBar;
}

- (void)setBarButtonItems
{
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
    [addBtn setAccessibilityIdentifier:@"Add"];
    
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(enterEditMode)];
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Item"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Item Name";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        [self addNewItemWithName:textField.text];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:addAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addNewItemWithName:(NSString *)itemName
{
    if (itemName.length > 0) {
        NSMutableArray *mObjects = [self.objects mutableCopy];
        [mObjects addObject:itemName];
        self.objects = [mObjects copy];
        
        self.objects = [self.objects sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:nil ascending:!self.ascending]]];
        
        NSLog(@"index at %lu", (unsigned long)[self.objects indexOfObject:itemName]);
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.objects indexOfObject:itemName] inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self storeCell];
        
        [self performSelector:@selector(tableViewReloadData:) withObject:self.tableView afterDelay:1.0];
    }
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
    if (searchController.isActive && searchController.searchBar.text.length > 0) {
        return self.filteredArray.count;
    }
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    cell.textLabel.highlightedTextColor = [UIColor redColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (searchController.isActive && searchController.searchBar.text.length > 0) {
        cell.textLabel.text = [self.filteredArray objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [self.objects objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *mObjects = [self.objects mutableCopy];
        
        if (searchController.isActive && searchController.searchBar.text.length > 0) {
            NSString *itemToRemove = self.filteredArray[indexPath.row];
            [mObjects removeObject:itemToRemove];
            
            NSMutableArray *mFilteredArray = [self.filteredArray mutableCopy];
            [mFilteredArray removeObjectAtIndex:indexPath.row];
            self.filteredArray = [mFilteredArray copy];
        } else {
            [mObjects removeObjectAtIndex:indexPath.row];
        }
        
        self.objects = [mObjects copy];
        [self storeCell];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
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
    
    if (searchController.isActive && searchController.searchBar.text.length > 0) {
        detailViewController.detailItem = [self.filteredArray objectAtIndex:indexPath.row];
    } else {
        detailViewController.detailItem = [self.objects objectAtIndex:indexPath.row];
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

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        self.filteredArray = [self.objects filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredArray = [self.objects copy];
    }
    [self.tableView reloadData];
}

@end
