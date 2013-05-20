//
//  PayPalMobilePGPlugin.m
//

#import "PayPalMobilePGPlugin.h"

@interface PayPalMobilePGPlugin ()
@property (nonatomic, strong) CDVInvokedUrlCommand *command;
@property (nonatomic, strong) PayPalPaymentViewController* paymentController;
-(void)sendErrorToDelegate:(NSString *)errorMessage;
@end

@implementation PayPalMobilePGPlugin

- (void)version:(CDVInvokedUrlCommand *)command
{
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                   messageAsString:[PayPalPaymentViewController libraryVersion]];
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)environment:(CDVInvokedUrlCommand *)command
{
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                    messageAsString:[[PayPalPaymentViewController environment] lowercaseString]];
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)setEnvironment:(CDVInvokedUrlCommand *)command
{
  CDVPluginResult *pluginResult = nil;
  NSString *myarg = [command.arguments objectAtIndex:0];
  
  if (myarg != nil && myarg.length) {
    [PayPalPaymentViewController setEnvironment:[myarg lowercaseString]];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Arg was null or empty"];
  }
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)prepareForPayment:(CDVInvokedUrlCommand *)command
{
  CDVPluginResult *pluginResult = nil;
  NSString *myarg = [command.arguments objectAtIndex:0];
  
  if (myarg != nil && myarg.length) {
    [PayPalPaymentViewController prepareForPaymentUsingClientId:myarg];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Arg was null or empty"];
  }
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)presentPaymentUI:(CDVInvokedUrlCommand *)command
{  
  // check number of arguments
  if ([command.arguments count] != 4) {
    [self sendErrorToDelegate:@"invalid number of arguments should be 4"];
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
  
  if (!(pppayment || pppayment.processable)) {
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

#pragma mark -
#pragma mark PayPalPaymentDelegate implementaiton

- (void)payPalPaymentDidCancel
{
  [self.viewController dismissModalViewControllerAnimated:YES];
  [self sendErrorToDelegate:@"paymentDidCancel"];
}
- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment
{
  [self.viewController dismissModalViewControllerAnimated:YES];
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                messageAsDictionary:completedPayment.confirmation];
  
  [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}


-(void)sendErrorToDelegate:(NSString *)errorMessage
{
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                    messageAsString:errorMessage];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

@end
