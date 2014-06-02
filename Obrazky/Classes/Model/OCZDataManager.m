//
//  OCZDataManager.m
//  Obrazky
//
//  Created by Peter Rusinak on 30/05/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import "OCZDataManager.h"
#import "OCZParser.h"
#import "OCZPaging.h"
#import "OCZResponse.h"
#import "AFNetworking.h"

static NSString * const kBaseUrl = @"http://obrazky.cz/searchAjax?s=&size=any&color=any&filter=true";

@interface OCZDataManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation OCZDataManager

#pragma mark - Setup

+ (instancetype)sharedManager
{
    NSAssert([NSThread isMainThread], @"Must be called on main thread");

    static id sharedInstance;

    if (!sharedInstance) sharedInstance = [[self alloc] init];

    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        
    }

    return self;
}

#pragma mark - Properties

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"DownloadQueue";
        _operationQueue.maxConcurrentOperationCount = 1;
    }

    return _operationQueue;
}

#pragma mark -

- (void)downloadImagesWithQuery:(NSString *)query forPage:(NSNumber *)page withCompletionBlock:(void (^)(id, OCZPaging *, id))completionBlock
{
    NSString *url = kBaseUrl;

    if (query) {
        url = [url stringByAppendingFormat:@"&q=%@", query];
    }

    if (page) {
        url = [url stringByAppendingFormat:@"&from=%@&step=%@", page, @(20)];
    }

#if DEBUG
    NSLog(@"--- Downloading data with url: %@", url);
#endif
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
#if DEBUG
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"AFHTTPRequestOperation %@", responseString);
#endif
         if (operation.response.statusCode == 200) {

             [OCZParser parseResponse:responseObject forKey:@"boxes" withBlock:^(OCZResponse *response, OCZPaging *paging, id data)
             {
                 if (response.status != 200 || data == nil) { completionBlock(nil, paging, response); return;}

                 [OCZParser parseImagesFromHTMLString:data withBlock:^(id data, NSError *error)
                 {
                     completionBlock (data, paging, error);
                 }];
             }];
         }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#if DEBUG
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
#endif
        completionBlock(nil, nil, error);
    }];

    [self.operationQueue addOperation:operation];
}

@end
