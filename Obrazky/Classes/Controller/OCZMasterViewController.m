//
//  OCZMasterViewController.m
//  Obrazky
//
//  Created by Peter Rusinak on 30/05/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import "OCZMasterViewController.h"
#import "OCZDataManager.h"
#import "OCZImage.h"
#import "OCZImageViewer.h"
#import "OCZPaging.h"
#import "OCZResponse.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface OCZMasterViewController () <UISearchBarDelegate, UIAlertViewDelegate, OCZImageViewerDataSource, OCZImageViewerDelegate> {
    NSMutableArray *_objects;
}

@property (nonatomic, strong) OCZDataManager *dataManager;
@property (nonatomic, strong) OCZPaging *pagingImages;
@property (nonatomic, strong) OCZImageViewer *imageViewer;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (assign) BOOL loadingNextPage;

@end

@implementation OCZMasterViewController

#pragma mark - Properties

- (OCZDataManager *)dataManager
{
    if (!_dataManager) _dataManager = [OCZDataManager sharedManager];
    return _dataManager;
}

#pragma mark - View lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)loadView
{
    [super loadView];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(15.0f, 0.0f, 290.0f, 32.0f)];
    self.searchBar.placeholder = NSLocalizedString(@"Hledej obrázek", nil);
    self.searchBar.delegate = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -

- (void)loadDataForPage:(NSNumber *)page andQuery:(NSString *)query
{
    if (!query || [query isEqualToString:@""]) {
        return;
    }

    [self.dataManager downloadImagesWithQuery:query forPage:page withCompletionBlock:^(id data, OCZPaging *paging, NSError *error)
    {
        if  (error) {

            NSString *message = @"Chyba při načítání dat. Skuste znovu.";

            if ([error isKindOfClass:[OCZResponse class]]) {
                message = ((OCZResponse *)error).statusMessage;
            }

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        } else if (data && paging) {

            self.pagingImages = paging;

            if ([self.pagingImages.from intValue] == 1) {
                _objects = [NSMutableArray new];
            }

            [_objects addObjectsFromArray:data];

            // Reload table & imageViewer
            [self.tableView reloadData];

            if (self.imageViewer) {
                [self.imageViewer imageViewerReloadData];
            }
        }

        self.loadingNextPage = NO;
    }];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {

    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OCZImageCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    UILabel *labelTitle = (UILabel*)[cell viewWithTag:11];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];

    if (indexPath.row < _objects.count) {

        OCZImage *image = _objects[indexPath.row];

        if (image) {
            labelTitle.text = image.title;
            [imageView setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:nil options:SDWebImageRefreshCached];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];

    self.imageViewer = [OCZImageViewer new];
    self.imageViewer.initialIndex = indexPath.row;
    self.imageViewer.delegate = self;
    self.imageViewer.datasource = self;
    [self.imageViewer showImage:imageView.image fromRect:[self rectForTableViewCellAtIndexPathRow:indexPath.row] animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == (_objects.count - 3)) {

        if (!self.loadingNextPage) {

            int nextPage = [self.pagingImages.from intValue] + 1;

            [self loadDataForPage:@(nextPage) andQuery:self.searchBar.text];

            self.loadingNextPage = YES;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0f;
}

- (void)tableViewScrollToBottomAnimated:(BOOL)animated
{
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (CGRect)rectForTableViewCellAtIndexPathRow:(NSInteger)row
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];

    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];

    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];

    CGRect imageRect = CGRectMake(rectInSuperview.origin.x + 20, rectInSuperview.origin.y + 15, imageView.frame.size.width, imageView.frame.size.height);

    return imageRect;
}

#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";

    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;

    [self loadDataForPage:@(1) andQuery:searchBar.text];
}

#pragma mark - OCZImageViewer Delegate

- (void)didClosedImageViewer:(OCZImageViewer *)imageViewer
{

}

- (void)imageViewer:(OCZImageViewer *)imageViewer shareImage:(UIImage *)image atIndex:(NSInteger)index
{
    if ([UIActivityViewController class])
    {
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];

        [activityView setValue:@"" forKey:@"subject"];

        // Removed un-needed activities
        activityView.excludedActivityTypes = [[NSArray alloc] initWithObjects:UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, nil];

        [self presentViewController:activityView animated:YES completion:nil];
        [activityView setCompletionHandler:^(NSString *act, BOOL done) {}];
    }
}

- (void)imageViewer:(OCZImageViewer *)imageViewer didScrollToIndex:(NSInteger)index
{
     [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)imageViewWillDisplayLastItem
{
    [self tableViewScrollToBottomAnimated:YES];
}

#pragma mark - OCZImageViewer DataSource

- (NSInteger)numberOfImagesInImageViewer:(OCZImageViewer *)imageViewer
{
    return _objects.count;
}

- (NSURL *)imageViewer:(OCZImageViewer *)imageViewer urlForImageAtIndex:(NSInteger)index
{
    OCZImage *image = _objects[index];

    return [NSURL URLWithString:image.url];
}

- (CGRect)imageViewer:(OCZImageViewer *)imageViewer rectForImageAtIndex:(NSInteger)index
{
    return [self rectForTableViewCellAtIndexPathRow:index];
}

@end
