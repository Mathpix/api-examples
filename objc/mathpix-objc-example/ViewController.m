//
//  ViewController.m
//  mathpix-objc-example
//
//  Created by admin on 5/22/17.
//  Copyright © 2017 Mathpix. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString * assetFileName = [self getAssetFile:@"limit"];
    [self processSingleImage1:assetFileName];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) getAssetFile:(NSString *)fileName {
    return [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
}

- (void)processSingleImage: (NSString *)imageName {
    NSData *data = [NSData dataWithContentsOfFile:imageName options:NSDataReadingMapped error:nil];
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    NSDictionary *param = @{@"url" : [NSString stringWithFormat:@"data:image/jpeg;base64,%@", base64String]};
    
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"https://api.mathpix.com/v3/latex" parameters:param error:nil];
    [request setValue:@"mathpix" forHTTPHeaderField:@"app_id"];
    [request setValue:@"139ee4b61be2e4abcfb1238d9eb99902" forHTTPHeaderField:@"app_key"];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else { //SUCCESS
                          NSLog(@"Response: %@", responseObject);
                      }
                  }];
    
    [uploadTask resume];
}


- (void)processSingleImage1: (NSString *)imageName {
    NSData *data = [NSData dataWithContentsOfFile:imageName options:NSDataReadingMapped error:nil];
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    NSDictionary *headers = @{ @"content-type": @"application/json",
                               @"app_id": @"mathpix",
                               @"app_key": @"139ee4b61be2e4abcfb1238d9eb99902"};
    NSDictionary *param = @{@"url" : [NSString stringWithFormat:@"data:image/jpeg;base64,%@", base64String]};
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:param options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.mathpix.com/v3/latex"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"Error: %@", error);
                                                    } else {
                                                        NSError *e = nil;
                                                        id json = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableLeaves error: &e];
                                                        
                                                        if (!json) {
                                                            NSLog(@"Error parsing JSON: %@", e);
                                                        } else {
                                                            NSLog(@"Response: %@", json);
                                                        }
                                                    }
                                                }];
    [dataTask resume];
}

@end
