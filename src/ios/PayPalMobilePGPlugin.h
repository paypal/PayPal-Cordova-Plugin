//
//  PayPalMobilePGPlugin.h
//

#import <Cordova/CDV.h>
#import "PayPalMobile.h"

@interface PayPalMobilePGPlugin : CDVPlugin<PayPalPaymentDelegate>

- (void)version:(CDVInvokedUrlCommand *)command;

- (void)initializeWithClientIdsForEnvironments:(CDVInvokedUrlCommand *)command;
- (void)preconnectWithEnvironment:(CDVInvokedUrlCommand *)command;

- (void)presentSinglePaymentUI:(CDVInvokedUrlCommand *)command;

- (void)applicationCorrelationIDForEnvironment:(CDVInvokedUrlCommand *)command;
- (void)presentFuturePaymentUI:(CDVInvokedUrlCommand *)command;

@end
