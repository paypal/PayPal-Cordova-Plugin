//
//  PayPalMobilePGPlugin.js
//

/**
 * This class exposes the PayPal iOS SDK functionality to javascript.
 *
 * @constructor
 */
function PayPalMobile() {}


/**
 * Retrieve the version of the PayPal iOS SDK library. Useful when contacting support.
 *
 * @parameter completionCallback: a callback function accepting a string
 */
PayPalMobile.prototype.version = function(completionCallback) {
  var failureCallback = function() {
    console.log("Could not retrieve PayPal library version");
  };

  cordova.exec(completionCallback, failureCallback, "PayPalMobile", "version", []);
};


/**
 * Set the environment that the PayPal iOS SDK uses.
 *
 * @parameter initializeWithClientIdsForEnvironments: object
 * Example: var clientIdsForEnvironments = {
 *  live : @"my-client-id-for-Production",
 *  sandbox : @"my-client-id-for-Sandbox"
 *  }
 */
PayPalMobile.prototype.initializeWithClientIdsForEnvironments = function(clientIdsForEnvironments, completionCallback) {
  var failureCallback = function(error) {
    console.log(error);
  };

  cordova.exec(completionCallback, failureCallback, "PayPalMobile", "initializeWithClientIdsForEnvironments", [clientIdsForEnvironments]);
};

/**
 * You SHOULD preconnect to PayPal to prepare the device for processing payments.
 * This improves the user experience, by making the presentation of the
 * UI faster. The preconnect is valid for a limited time, so
 * the recommended time to preconnect is on page load.
 *
 * @parameter environment: available options are "PayPalEnvironmentNoNetwork", "PayPalEnvironmentProduction" and "PayPalEnvironmentSandbox"
 */
PayPalMobile.prototype.preconnectWithEnvironment = function(environment, completionCallback) {
  var failureCallback = function(error) {
    console.log(error);
  };

  cordova.exec(completionCallback, failureCallback, "PayPalMobile", "preconnectWithEnvironment", [environment]);
};


/**
 * Start PayPal UI to collect payment from the user.
 * See https://developer.paypal.com/webapps/developer/docs/integration/mobile/ios-integration-guide/
 * for more documentation of the parameters.
 *
 * @parameter payment: PayPalPayment object
 * @parameter paymentDetails: PayPalPaymentDetails object (optional can be null)
 * @parameter configuration: PayPalConfiguration object (optional can be null)
 * @parameter completionCallback: a callback function accepting a js object, called when the user has completed payment
 * @parameter cancelCallback: a callback function accepting a reason string, called when the user cancels the payment
 */
PayPalMobile.prototype.presentSinglePaymentUI = function(payment, configuration, completionCallback, cancelCallback) {
  cordova.exec(completionCallback, cancelCallback, "PayPalMobile", "presentSinglePaymentUI", [payment, configuration]);
};


/**
 * Once a user has consented to future payments, when the user subsequently initiates a PayPal payment
 * from their device to be completed by your server, PayPal uses a Correlation ID to verify that the
 * payment is originating from a valid, user-consented device+application.
 * This helps reduce fraud and decrease declines.
 * This method MUST be called prior to initiating a pre-consented payment (a "future payment") from a mobile device.
 * Pass the result to your server, to include in the payment request sent to PayPal.
 * Do not otherwise cache or store this value.
 *
 * @parameter environment: available options are "PayPalEnvironmentNoNetwork", "PayPalEnvironmentProduction" and "PayPalEnvironmentSandbox"
 * @parameter callback: applicationCorrelationID Your server will send this to PayPal in a 'Paypal-Application-Correlation-Id' header.
 */
PayPalMobile.prototype.applicationCorrelationIDForEnvironment = function(environment, completionCallback) {
  var failureCallback = function(message) {
    console.log("Could not perform applicationCorrelationIDForEnvironment " + message);
  };

  cordova.exec(completionCallback, failureCallback, "PayPalMobile", "applicationCorrelationIDForEnvironment", [environment]);
};

/**
 * Please Read Docs on Future Payments at https://github.com/paypal/PayPal-iOS-SDK#future-payments
 * 
 * @parameter configuration: cannot be null, merchantName, merchantPrivacyPolicyURL and merchantUserAgreementURL must be
 * set using PayPalConfiguraiton object
 */
PayPalMobile.prototype.presentFuturePaymentUI = function(configuration, completionCallback, cancelCallback) {
  cordova.exec(completionCallback, cancelCallback, "PayPalMobile", "presentFuturePaymentUI", [configuration]);
};

/**
 * Plugin setup boilerplate.
 */
module.exports = new PayPalMobile();
