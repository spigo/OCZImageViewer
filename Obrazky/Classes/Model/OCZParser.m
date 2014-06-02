//
//  OCZParser.m
//  Obrazky
//
//  Created by Peter Rusinak on 30/05/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import "OCZParser.h"
#import "OCZResponse.h"
#import "OCZImage.h"
#import "OCZPaging.h"
#import "HTMLParser.h"

@implementation OCZParser

+ (void)parseResponse:(id)responseData forKey:(NSString *)key withBlock:(void (^)(OCZResponse *response, OCZPaging *paging, id data))parserCompletionBlock
{
    OCZPaging *paging = nil;
    OCZResponse *response = nil;
    id data;

    NSError *error;

    NSDictionary *jsonObject = nil;

    if (responseData != nil) {

        if ([responseData isKindOfClass:[NSDictionary class]]) {
            jsonObject = responseData;
        } else {

            NSString *strEncoded = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            strEncoded = [strEncoded stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
            responseData = [strEncoded dataUsingEncoding:NSUTF8StringEncoding];

            jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        }
    }

    if (!error && [NSJSONSerialization isValidJSONObject:jsonObject])
    {
        if ((NSNull*)[jsonObject valueForKey:@"result"] != [NSNull null]) {

            NSDictionary *result = [jsonObject valueForKey:@"result"];

            paging = [OCZPaging new];
            response = [OCZResponse new];

            // Paging
            if ((NSNull*)[result valueForKey:@"pageSize"] != [NSNull null]) {
                paging.pageSize = [result valueForKey:@"pageSize"];
            }
            if ((NSNull*)[result valueForKey:@"resultSize"] != [NSNull null]) {
                paging.resultSize = [result valueForKey:@"resultSize"];
            }
            if ((NSNull*)[result valueForKey:@"from"] != [NSNull null]) {
                paging.from = [result valueForKey:@"from"];
            }
            if ((NSNull*)[result valueForKey:@"to"] != [NSNull null]) {
                paging.to = [result valueForKey:@"to"];
            }

            // Content

            if ((NSNull*)[result valueForKey:@"status"] != [NSNull null]) {
                response.status = [[result valueForKey:@"status"] integerValue];
            }
            if ((NSNull*)[result valueForKey:@"statusMessage"] != [NSNull null]) {
                response.statusMessage = [result valueForKey:@"statusMessage"];
            }

            if (key) {

                if ((NSNull*)[result valueForKey:key] != [NSNull null]) {
                    data = [result valueForKey:key];
                }
            }
        }
    } else {
#if DEBUG
        NSLog(@"Error: Invalid JSON");
#endif
    }

    parserCompletionBlock(response, paging, data);
}

+ (void)parseImagesFromHTMLString:(NSString *)html withBlock:(void (^)(id, NSError *))parserCompletionBlock
{
    NSError *error = nil;
    NSMutableArray *data = [NSMutableArray new];

    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];

    if (!error) {

        HTMLNode *bodyNode = [parser body];

        NSArray *imageNodes = [bodyNode findChildTags:@"img"];

        for (HTMLNode *imageNode in imageNodes) {

            OCZImage *image = [OCZImage new];
            image.url = [imageNode getAttributeNamed:@"src"];
            image.title = [imageNode getAttributeNamed:@"alt"];

            [data addObject:image];
        }
    }

    parserCompletionBlock(data, error);
}

@end
