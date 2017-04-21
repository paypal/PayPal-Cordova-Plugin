//
//  PayPalMobileCordovaPlugin.m
//  Copyright (c) 2014 PayPal. All rights reserved.
//

#import "PayPalMobileCordovaPlugin.h"

@interface PayPalMobileCordovaPlugin ()

- (void)sendErrorToDelegate:(NSString *)errorMessage;

@property(nonatomic, strong, readwrite) CDVInvokedUrlCommand *command;
@property(nonatomic, strong, readwrite) PayPalConfiguration *configuration;

@end


#pragma mark -

@implementation PayPalMobileCordovaPlugin

- (void)version:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:[PayPalMobile libraryVersion]];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)init:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    NSDictionary* clientIdsReceived = [command.arguments objectAtIndex:0];
    NSDictionary* clientIds = @{PayPalEnvironmentProduction: clientIdsReceived[@"PayPalEnvironmentProduction"],
                                PayPalEnvironmentSandbox: clientIdsReceived[@"PayPalEnvironmentSandbox"]};
    
    [PayPalMobile initializeWithClientIdsForEnvironments:clientIds];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)prepareToRender:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    NSString *environment = [command.arguments objectAtIndex:0];
    
    NSString *environmentToUse = [self parseEnvironment:environment];
    if (environmentToUse) {
      // save configuration
      PayPalConfiguration *configuration = [self getPayPalConfigurationFromDictionary:[command.arguments objectAtIndex:1]];
      self.configuration = configuration;
      // do preconnect
      dispatch_async(dispatch_get_main_queue(), ^{
        [PayPalMobile preconnectWithEnvironment:environmentToUse];
      });
    } else {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The provided environment is not supported"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)applicationCorrelationIDForEnvironment:(CDVInvokedUrlCommand *)command {
  [self clientMetadataID:command];
}

- (void)clientMetadataID:(CDVInvokedUrlCommand *)command {
  [self.commandDelegate runInBackground:^{
    NSString *clientMetadataID = [PayPalMobile clientMetadataID];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:clientMetadataID];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)renderSinglePaymentUI:(CDVInvokedUrlCommand *)command {
  self.command = command;

  [self.commandDelegate runInBackground:^{
    
    // check number and type of arguments
    if ([command.arguments count] != 1) {
      [self sendErrorToDelegate:@"renderSinglePaymentUI payment object must be provided"];
      return;
    }
    
    NSDictionary *payment = [command.arguments objectAtIndex:0];
    if (![payment isKindOfClass:[NSDictionary class]]) {
      [self sendErrorToDelegate:@"payment must be a PayPalPayment object"];
      return;
    }
    
    // get the values
    NSString *amount = payment[@"amount"];
    NSString *currency = payment[@"currency"];
    NSString *shortDescription = payment[@"shortDescription"];
    NSString *intentStr = [payment[@"intent"] lowercaseString];
    NSString *invoiceNumber = payment[@"invoiceNumber"];
    NSString *custom = payment[@"custom"];
    NSString *softDescriptor = payment[@"softDescriptor"];
    NSString *payeeEmail = payment[@"payeeEmail"];
    NSString *bnCode = payment[@"bnCode"];
    NSArray *items = payment[@"items"];
    NSDictionary *shippingAddress = payment[@"shippingAddress"];
    
    PayPalPaymentIntent intent;
    if ([intentStr isEqualToString:@"order"]) {
      intent = PayPalPaymentIntentOrder;
    } else if ([intentStr isEqualToString:@"sale"]) {
      intent = PayPalPaymentIntentSale;
    } else {
      intent = PayPalPaymentIntentAuthorize;
    }
    
    // create payment
    PayPalPayment *ppPayment = [PayPalPayment paymentWithAmount:[NSDecimalNumber decimalNumberWithString:amount]
                                                   currencyCode:currency
                                               shortDescription:shortDescription
                                                         intent:intent];
    ppPayment.invoiceNumber = invoiceNumber;
    ppPayment.custom = custom;
    ppPayment.softDescriptor = softDescriptor;
    ppPayment.payeeEmail = payeeEmail;
    ppPayment.bnCode = bnCode;
    ppPayment.items = [self getPayPalItemsFromJSArray:items];
    ppPayment.shippingAddress = [self getPayPalShippingAddressFromDictionary:shippingAddress];
    
    ppPayment.paymentDetails = [self getPaymentDetailsFromDictionary:payment[@"details"]];
    if (!ppPayment.processable) {
      [self sendErrorToDelegate:@"payment not processable"];
      return;
    }
    
    
    PayPalPaymentViewController *controller = [[PayPalPaymentViewController alloc] initWithPayment:ppPayment
                                                                                     configuration:self.configuration
                                                                                          delegate:self];
    if (!controller) {
      [self sendErrorToDelegate:@"could not instantiate UI please check your arguments"];
      return;
    }
    
    self.command = command;
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.viewController presentViewController:controller animated:YES completion:nil];
    });
  }];
}

- (void)renderFuturePaymentUI:(CDVInvokedUrlCommand *)command {
  self.command = command;
  [self.commandDelegate runInBackground:^{
    PayPalFuturePaymentViewController *controller = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.configuration delegate:self];
    if (!controller) {
      [self sendErrorToDelegate:@"could not instantiate UI please check your arguments"];
      return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [self.viewController presentViewController:controller animated:YES completion:nil];
    });
  }];
}

- (void)renderProfileSharingUI:(CDVInvokedUrlCommand *)command {
  self.command = command;
  [self.commandDelegate runInBackground:^{
    if ([command.arguments count] != 1) {
      [self sendErrorToDelegate:@"renderProfileSharing scopes object must be provided"];
      return;
    }

    NSArray *jsArray = [command.arguments objectAtIndex:0];
    if (![jsArray isKindOfClass:[NSArray class]]) {
      [self sendErrorToDelegate:@"scopes must be a Array"];
      return;
    }

    NSSet *scopes = [self getPayPalScopesSetFromJSArray:jsArray];
    if (!scopes.count) {
      [self sendErrorToDelegate:@"at least 1 scope must be provided"];
      return;
    }

    PayPalProfileSharingViewController *controller = [[PayPalProfileSharingViewController alloc] initWithScopeValues:scopes configuration:self.configuration delegate:self];
    if (!controller) {
      [self sendErrorToDelegate:@"could not instantiate UI please check your arguments"];
      return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.viewController presentViewController:controller animated:YES completion:nil];
    });
  }];
}

#pragma mark - Cordova convenience helpers

- (void)sendErrorToDelegate:(NSString *)errorMessage {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                    messageAsString:errorMessage];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

- (NSString*)parseEnvironment:(NSString*)environment {
  NSString *environmentToUse = nil;
  environment = [environment lowercaseString];
  if ([environment isEqualToString:[@"PayPalEnvironmentNoNetwork" lowercaseString]]) {
    environmentToUse = PayPalEnvironmentNoNetwork;
  } else if ([environment isEqualToString:[@"PayPalEnvironmentProduction" lowercaseString]]) {
    environmentToUse = PayPalEnvironmentProduction;
  } else if ([environment isEqualToString:[@"PayPalEnvironmentSandbox" lowercaseString]]) {
    environmentToUse = PayPalEnvironmentSandbox;
  }
  return environmentToUse;
}

- (PayPalPaymentDetails*)getPaymentDetailsFromDictionary:(NSDictionary *)dictionary {
  if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]] || !dictionary.count) {
    return nil;
  }

  PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails new];
  for (NSString *key in dictionary) {
    if (dictionary[key] != [NSNull null] && [dictionary[key] isKindOfClass:[NSString class]]) {
      NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:dictionary[key]];
      [paymentDetails setValue:number forKey:key];
    }
  }
  return paymentDetails;
}

- (PayPalConfiguration *)getPayPalConfigurationFromDictionary:(NSDictionary *)dictionary {
  if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]] || !dictionary.count) {
    return nil;
  }
  PayPalConfiguration *configuration = [PayPalConfiguration new];
  for (NSString *key in dictionary) {
    if (dictionary[key] != [NSNull null]) {
      [configuration setValue:dictionary[key] forKey:key];
    }
  }

  return configuration;
}

- (NSSet *)getPayPalScopesSetFromJSArray:(NSArray *)array {
  // go through array and so simple matching, if we don't match allow mSDK to decide if the scope allowed
  NSDictionary* knownScopes = @{
    @"openid": kPayPalOAuth2ScopeOpenId,
    @"profile": kPayPalOAuth2ScopeProfile,
    @"address": kPayPalOAuth2ScopeAddress,
    @"email": kPayPalOAuth2ScopeEmail,
    @"phone": kPayPalOAuth2ScopePhone,
    @"futurepayments": kPayPalOAuth2ScopeFuturePayments,
    @"paypalattributes": kPayPalOAuth2ScopePayPalAttributes,
  };

  NSMutableSet *scopeSet = [NSMutableSet set];
  for (NSString *jsscope in array) {
    if ([jsscope isKindOfClass:[NSString class]] && jsscope.length) {
      NSString *scope = knownScopes[jsscope.lowercaseString];
      if (!scope) {
        scope = jsscope;
      }
      [scopeSet addObject:scope];
    }
  }
  return scopeSet;
}

- (NSArray *)getPayPalItemsFromJSArray:(NSArray *)array {
  if (!array || ![array isKindOfClass:[NSArray class]] || !array.count) {
    return nil;
  }

  NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:10];
  for (NSDictionary *jsItem in array) {
    NSString *name = jsItem[@"name"];
    NSNumber *quantity = jsItem[@"quantity"];
    NSString *price = jsItem[@"price"];
    NSString *currency = jsItem[@"currency"];
    NSString *sku = (jsItem[@"sku"] == [NSString class]) ? jsItem[@"sku"] : nil;
    PayPalItem *item = [PayPalItem itemWithName:name
                                   withQuantity:[quantity unsignedIntegerValue]
                                   withPrice:[NSDecimalNumber decimalNumberWithString:price]
                                   withCurrency:currency
                                   withSku:sku
                                   ];
    if (item) {
      [mutableArray addObject:item];
    }
  }

  return (mutableArray.count ? mutableArray : nil);
}

- (PayPalShippingAddress *)getPayPalShippingAddressFromDictionary:(NSDictionary *)dictionary {
  if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]] || !dictionary.count) {
    return nil;
  }
  PayPalShippingAddress *address = [PayPalShippingAddress new];
  for (NSString *key in dictionary) {
    if (dictionary[key] != [NSNull null]) {
      [address setValue:dictionary[key] forKey:key];
    }
  }

  return address;
}

#pragma mark - PayPalPaymentDelegate implementation

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
  [paymentViewController dismissViewControllerAnimated:YES completion:^{
    [self sendErrorToDelegate:@"payment cancelled"];
  }];
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
  [paymentViewController dismissViewControllerAnimated:YES completion:^{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                  messageAsDictionary:completedPayment.confirmation];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
  }];

}


#pragma mark - PayPalFuturePaymentDelegate implementation

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {
  [futurePaymentViewController dismissViewControllerAnimated:YES completion:^{
    [self sendErrorToDelegate:@"future payment cancelled"];
  }];
}

- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {
  [futurePaymentViewController dismissViewControllerAnimated:YES completion:^{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                  messageAsDictionary:futurePaymentAuthorization];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
  }];
}

#pragma mark - PayPalProfileSharingDelegate implementation

- (void)userDidCancelPayPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController {
  [profileSharingViewController dismissViewControllerAnimated:YES completion:^{
    [self sendErrorToDelegate:@"profile sharing cancelled"];
  }];
}

- (void)payPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController userDidLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization {
  [profileSharingViewController dismissViewControllerAnimated:YES completion:^{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                  messageAsDictionary:profileSharingAuthorization];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
  }];
}

@end
