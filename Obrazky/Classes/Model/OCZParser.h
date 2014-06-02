//
//  OCZParser.h
//  Obrazky
//
//  Created by Peter Rusinak on 30/05/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCZPaging;
@class OCZResponse;

@interface OCZParser : NSObject

+ (void)parseResponse:(id)responseData forKey:(NSString *)key withBlock:(void (^)(OCZResponse *response, OCZPaging *paging, id data))parserCompletionBlock;
+ (void)parseImagesFromHTMLString:(NSString *)html withBlock:(void (^)(id data, NSError *error))parserCompletionBlock;

@end
