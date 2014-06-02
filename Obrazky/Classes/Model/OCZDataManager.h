//
//  OCZDataManager.h
//  Obrazky
//
//  Created by Peter Rusinak on 30/05/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCZPaging;

@interface OCZDataManager : NSObject

+ (instancetype)sharedManager;

- (void)downloadImagesWithQuery:(NSString *)query forPage:(NSNumber *)page withCompletionBlock:(void (^)(id data, OCZPaging *paging, id error))completionBlock;

@end
