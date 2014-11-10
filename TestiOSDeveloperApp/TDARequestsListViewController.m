//
//  TDARequestsViewController.m
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/6/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import "TDARequestsListViewController.h"
#import "TDADataManager.h"
#import "TDARequestInfoCell.h"
#import "Request.h"
#import "TDAConstants.h"

@interface TDARequestsListViewController () <NSFetchedResultsControllerDelegate>

@property (assign, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TDARequestsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error = nil;
    NSAssert([[self fetchedResultsController] performFetch:&error],
             @"Unresolved error %@\n%@", [error localizedDescription], [error userInfo]);
}

- (void)dealloc
{
    [_fetchedResultsController release];
    [super dealloc];
}


#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"requestInfoCell";
    TDARequestInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[[TDARequestInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(TDARequestInfoCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Request *request = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.messageLabel.text   = request.message;
    cell.timeLabel.text      = request.time;
    cell.reqFormatLabel.text = [self getRequestFormatString:(TDARequestFormat) [request.requestFormat integerValue]];
    cell.reqStatusLabel.text = [self getRequestStatusString:(TDARequestStatus) [request.status integerValue]];
}

- (NSString *)getRequestFormatString:(TDARequestFormat)format
{
    NSString *formatString = nil;
    
    switch (format) {
        case JSONFormat:
            formatString = @"Format: JSON";
            break;
            
        case XMLFormat:
            formatString = @"Format: XML";
            break;
            
        case BinaryFormat:
            formatString = @"Format: Binary";
            break;
            
        default:
            NSAssert(false, @"Unexpected format");
            break;
    }
    
    return formatString;
}

- (NSString *)getRequestStatusString:(TDARequestStatus)status
{
    NSString *statusString = nil;
    
    switch (status) {
        case Waiting:
            statusString = @"Waiting to be sent";
            break;
            
        case Sent:
            statusString = @"Sent";
            break;
            
        default:
            NSAssert(false, @"Unexpected status");
            break;
    }
    
    return statusString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self.fetchedResultsController sections];
    id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
    
    return [sectionInfo numberOfObjects];
}


#pragma mark - FetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Request"
                                                  inManagedObjectContext:[[TDADataManager sharedInstance] managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
        fetchRequest.sortDescriptors = [NSArray arrayWithObject:sort];
        [sort release];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSFetchedResultsController *theFetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                      managedObjectContext:[[TDADataManager sharedInstance] managedObjectContext]
                                                                                                        sectionNameKeyPath:nil
                                                                                                                 cacheName:@"Root"] autorelease];
        [fetchRequest release];
        
        self.fetchedResultsController = theFetchedResultsController;
        _fetchedResultsController.delegate = self;
    }
    
    return _fetchedResultsController;
}


#pragma mark - FetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(TDARequestInfoCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
