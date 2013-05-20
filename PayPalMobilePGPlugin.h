//
//  PayPalMobilePGPlugin.h
//  PayPal-iOS-SDK-PhoneGap
//
//  Created by Roman Punskyy on 23/04/2013.
//
//

#import <Cordova/CDV.h>
#import "PayPalMobile.h"

@interface PayPalMobilePGPlugin : CDVPlugin<PayPalPaymentDelegate>

- (void)version:(CDVInvokedUrlCommand *)command;
- (void)prepareForPayment:(CDVInvokedUrlCommand *)command;

- (void)environment:(CDVInvokedUrlCommand *)command;
- (void)setEnvironment:(CDVInvokedUrlCommand *)command;

- (void)payment:(CDVInvokedUrlCommand *)command;

@end
