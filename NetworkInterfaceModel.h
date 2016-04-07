//
//  NetworkInterfaceModel.h
//  LeFilm
//
//  Created by  Will on 15/12/3.
//  Copyright © 2015年 LEVP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import "ServiceAddressManager.h"



@interface NetworkInterfaceModel : NSObject

@property (nonatomic, strong)NSString *shortUrlString;
@property (nonatomic, assign)ServiceInterfaceVersion interfaceVersion;
@property (nonatomic, assign)RequestMethodType methodType;
@property (nonatomic, strong)NSDictionary *paramsDic;

@property (nonatomic, assign)BOOL shouldCache;

- (RequestEntity *)entityWithDictionary:(NSDictionary *)dic;

@end
