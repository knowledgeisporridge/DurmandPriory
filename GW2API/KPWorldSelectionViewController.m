//
//  KPWorldSelectionViewController.m
//  GW2API
//

#import "KPWorldSelectionViewController.h"
#import "KPWorldStatusViewController.h"


@interface KPWorldSelectionViewController ()

@end

@implementation KPWorldSelectionViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Let's get our world list.
    [DurmandPriory fetch:[GW2World class] completionBlock:^(id domain) {
        NSLog(@"Worlds: %d", [[GW2World worlds] count]);
        
        [self.tableView reloadData];
    }];

    nextButton_ = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(next:)];
    
    nextButton_.enabled = NO;
    self.navigationItem.rightBarButtonItem = nextButton_;
    self.navigationItem.title = @"Worlds";
}


- (void)next:(id)sender {
    // We're off to the next view controller... which world are we on?
    GW2World * selectedWorld = [[GW2World worlds] objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    
    // Let's tell the API which world we've selected. If we don't the API will still work well, however when fetching
    // things like events you'll get all events across all worlds. So if you're making an app that deals with
    // world level data simply add the world ID to the API and it'll take care of ensuring all returned data is
    // limited to just that world... and if you're making an app that doesn't care about specific worlds, don't
    // pass this ID.
    [DurmandPriory addRequestParameter:kGW2APIRequestParameterWorldID
                                 value:selectedWorld.world_id];
    
    KPWorldStatusViewController * statusViewController = [[KPWorldStatusViewController alloc] initWithNibName:@"KPWorldStatusViewController" bundle:nil];
    
    [self.navigationController pushViewController:statusViewController animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[GW2World worlds] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    GW2World * world = [[GW2World worlds] objectAtIndex:indexPath.row];
    cell.textLabel.text = world.name;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    nextButton_.enabled = YES;
}

@end
