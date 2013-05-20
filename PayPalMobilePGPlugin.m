//
//  PayPalMobilePGPlugin.m
//

#import "PayPalMobilePGPlugin.h"


@interface PayPalMobilePGPlugin ()

- (void)sendErrorToDelegate:(NSString *)errorMessage;

@property(nonatomic, strong, readwrite) CDVInvokedUrlCommand *command;
@property(nonatomic, strong, readwrite) PayPalPaymentViewController *paymentController;

@end


#pragma mark -

@implementation PayPalMobilePGPlugin

- (void)version:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                    messageAsString:[PayPalPaymentViewController libraryVersion]];
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)environment:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                    messageAsString:[[PayPalPaymentViewController environment] lowercaseString]];
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setEnvironment:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult = nil;
  NSString *environment = [command.arguments objectAtIndex:0];
  
  if (environment.length > 0) {
    [PayPalPaymentViewController setEnvironment:[environment lowercaseString]];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The provided environment was null or empty"];
  }
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)prepareForPayment:(CDVInvokedUrlCommand *)command {
  CDVPluginResult *pluginResult = nil;
  NSString *clientId = [command.arguments objectAtIndex:0];
  
  if (clientId.length > 0) {
    [PayPalPaymentViewController prepareForPaymentUsingClientId:clientId];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"The provided clientId was null or empty"];
  }
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)presentPaymentUI:(CDVInvokedUrlCommand *)command {  
  // check number of arguments
  if ([command.arguments count] != 4) {
    [self sendErrorToDelegate:@"presentPaymentUI requires precisely four arguments"];
    return;
  }
  
  // todo: make more robust to check the type?
  NSString *clientId = [command.arguments objectAtIndex:0];
  NSString *email = [command.arguments objectAtIndex:1];
  NSString *payerId = [command.arguments objectAtIndex:2];
  NSDictionary *payment = [command.arguments objectAtIndex:3];
  
  if (!payment) {
    [self sendErrorToDelegate:@"payment object is nil"];
    return;
  }
  
  NSString *amount = payment[@"amount"];
  NSString *currency = payment[@"currency"];
  NSString *shortDescription = payment[@"shortDescription"];
  
  PayPalPayment *pppayment = [PayPalPayment paymentWithAmount:[NSDecimalNumber decimalNumberWithString:amount]
                                                 currencyCode:currency
                                             shortDescription:shortDescription];
  
  if (!pppayment.processable) {
    [self sendErrorToDelegate:@"payment not processable"];
    return;
  }
  
  PayPalPaymentViewController *controller = [[PayPalPaymentViewController alloc] initWithClientId:clientId
                                                                                    receiverEmail:email
                                                                                          payerId:payerId
                                                                                          payment:pppayment
                                                                                         delegate:self];
  if (!controller) {
    [self sendErrorToDelegate:@"one of the arguments has invalid type"];
    return;
  } else {
    self.command = command;
    self.paymentController = controller;
    [self.viewController presentModalViewController:controller animated:YES];
  }
}


#pragma mark - Cordova convenience helpers

- (void)sendErrorToDelegate:(NSString *)errorMessage {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                    messageAsString:errorMessage];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}


#pragma mark - PayPalPaymentDelegate implementaiton

- (void)payPalPaymentDidCancel {
  [self.viewController dismissModalViewControllerAnimated:YES];
  [self sendErrorToDelegate:@"payment cancelled"];
}

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment {
  [self.viewController dismissModalViewControllerAnimated:YES];
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                messageAsDictionary:completedPayment.confirmation];
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

@end
