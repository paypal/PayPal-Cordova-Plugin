//
//  PayPalMobileCordovaPlugin.m
//

#import "PayPalMobileCordovaPlugin.h"

@interface PayPalMobileCordovaPlugin ()

- (void)sendErrorToDelegate:(NSString *)errorMessage;

@property(nonatomic, strong, readwrite) CDVInvokedUrlCommand *command;
@property(nonatomic, strong, readwrite) PayPalPaymentViewController *paymentController;
@property(nonatomic, strong, readwrite) PayPalFuturePaymentViewController *futurePaymentController;

@end


#pragma mark -

@implementation PayPalMobileCordovaPlugin

- (void)version:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                    messageAsString:[PayPalMobile libraryVersion]];
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)initializeWithClientIdsForEnvironments:(CDVInvokedUrlCommand *)command {
  NSDictionary* clientIdsReceived = [command.arguments objectAtIndex:0];
  NSDictionary* clientIds = @{PayPalEnvironmentProduction: clientIdsReceived[@"live"],
                              PayPalEnvironmentSandbox: clientIdsReceived[@"sandbox"]};
  
  [PayPalMobile initializeWithClientIdsForEnvironments:clientIds];
  
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)preconnectWithEnvironment:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  NSString *environment = [command.arguments objectAtIndex:0];

  NSString *environmentToUse = [self parseEnvironment:environment];
  if (environmentToUse) {
    [PayPalMobile preconnectWithEnvironment:environmentToUse];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The provided environment is not supported"];
  }
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)applicationCorrelationIDForEnvironment:(CDVInvokedUrlCommand *)command {
  NSString *environment = [command.arguments objectAtIndex:0];
  CDVPluginResult *pluginResult = nil;
  environment = [self parseEnvironment:environment];
  if (!environment) {
    NSString *applicaitonId = [PayPalMobile applicationCorrelationIDForEnvironment:environment];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:applicaitonId];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The provided environment is not supported"];
  }

  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)presentSinglePaymentUI:(CDVInvokedUrlCommand *)command {  
  // check number and type of arguments
  if ([command.arguments count] != 2) {
    [self sendErrorToDelegate:@"presentSinglePaymentUI requires precisely 2 arguments"];
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
  PayPalPaymentIntent intent = [intentStr isEqualToString:@"sale"] ? PayPalPaymentIntentSale : PayPalPaymentIntentAuthorize;
  
  // create payment
  PayPalPayment *pppayment = [PayPalPayment paymentWithAmount:[NSDecimalNumber decimalNumberWithString:amount]
                                                 currencyCode:currency
                                             shortDescription:shortDescription
                                                       intent:intent];
  
  pppayment.paymentDetails = [self getPaymentDetailsFromDictionary:payment[@"details"]];
  if (!pppayment.processable) {
    [self sendErrorToDelegate:@"payment not processable"];
    return;
  }
  
  PayPalConfiguration *configuraton = [self getPayPalConfigurationFromDictionary:[command.arguments objectAtIndex:1]];
  
  PayPalPaymentViewController *controller = [[PayPalPaymentViewController alloc] initWithPayment:pppayment
                                                                                   configuration:configuraton
                                                                                        delegate:self];
  if (!controller) {
    [self sendErrorToDelegate:@"could not instantiate UI please check your arguments"];
    return;
  }

  self.command = command;
  self.paymentController = controller;
  [self.viewController presentModalViewController:controller animated:YES];
}

- (void)presentFuturePaymentUI:(CDVInvokedUrlCommand *)command {
  PayPalConfiguration *configuraton = [self getPayPalConfigurationFromDictionary:[command.arguments objectAtIndex:0]];
  PayPalFuturePaymentViewController *controller = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:configuraton delegate:self];
  if (!controller) {
    [self sendErrorToDelegate:@"could not instantiate UI please check your arguments"];
    return;
  }
  
  self.command = command;
  self.futurePaymentController = controller;
  [self.viewController presentModalViewController:controller animated:YES];
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
  if ([environment isEqualToString:[@"mock" lowercaseString]]) {
    environmentToUse = PayPalEnvironmentNoNetwork;
  } else if ([environment isEqualToString:[@"live" lowercaseString]]) {
    environmentToUse = PayPalEnvironmentProduction;
  } else if ([environment isEqualToString:[@"sandbox" lowercaseString]]) {
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
    if (dictionary[key] != [NSNull null]) {
      [paymentDetails setValue:dictionary[key] forKey:key];
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
    if (dictionary[key] != [NSNull null] && [dictionary[key] isKindOfClass:[NSString class]]) {
      NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:dictionary[key]];
      [paymentDetails setValue:number forKey:key];
    }
  }
  
  return configuration;
}

#pragma mark - PayPalPaymentDelegate implementaiton

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController{
  [self.viewController dismissModalViewControllerAnimated:YES];
  [self sendErrorToDelegate:@"payment cancelled"];
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
  [self.viewController dismissModalViewControllerAnimated:YES];
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                messageAsDictionary:completedPayment.confirmation];
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}
  
  
#pragma mark - PayPalFuturePaymentDelegate implementaiton
  
- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {
  [self.viewController dismissModalViewControllerAnimated:YES];
  [self sendErrorToDelegate:@"future payment cancelled"];
}
  
- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization
  {
    [self.viewController dismissModalViewControllerAnimated:YES];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                  messageAsDictionary:futurePaymentAuthorization];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
  }

@end
