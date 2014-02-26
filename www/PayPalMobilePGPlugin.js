//
//  PayPalMobilePGPlugin.js
//

function PayPalPayment(amount, currency, shortDescription) {
  this.amount = amount;
  this.currency = currency;
  this.shortDescription = shortDescription;
}

/**
 * This class exposes the PayPal iOS SDK functionality to javascript.
 *
 * @constructor
 */
function PayPalMobile() {}


/**
 * Retrieve the version of the PayPal iOS SDK library. Useful when contacting support.
 *
 * @parameter callback: a callback function accepting a string
 */
PayPalMobile.prototype.version = function(callback) {
  var failureCallback = function() {
    console.log("Could not retrieve PayPal library version");
  };

  cordova.exec(callback, failureCallback, "PayPalMobile", "version", []);
};


/**
 * Set the environment that the PayPal iOS SDK uses.
 *
 * @parameter environment: string
 * Choices are "PayPalEnvironmentNoNetwork", "PayPalEnvironmentSandbox", or "PayPalEnvironmentProduction"
 */
PayPalMobile.prototype.setEnvironment = function(environment) {
  var failureCallback = function(error) {
    console.log(error);
  };

  cordova.exec(null, failureCallback, "PayPalMobile", "setEnvironment", [environment]);
};

/**
 * Retrieve the current PayPal iOS SDK environment: mock, sandbox, or live.
 *
 * @parameter callback: a callback function accepting a string
 */
PayPalMobile.prototype.environment = function(callback) {
  var failureCallback = function() {
    console.log("Could not retrieve PayPal environment");
  };

  cordova.exec(callback, failureCallback, "PayPalMobile", "environment", []);
};

/**
 * You SHOULD preconnect to PayPal to prepare the device for processing payments.
 * This improves the user experience, by making the presentation of the
 * UI faster. The preconnect is valid for a limited time, so
 * the recommended time to preconnect is on page load.
 *
 * @parameter clientID: your client id from developer.paypal.com
 * @parameter callback: a parameter-less success callback function (normally not used)
 */
PayPalMobile.prototype.prepareForPayment = function(clientId) {
  var failureCallback = function(message) {
    console.log("Could not perform prepareForPurchase " + message);
  };

  cordova.exec(null, failureCallback, "PayPalMobile", "prepareForPayment", [clientId]);
};


/**
 * Start PayPal UI to collect payment from the user.
 * See https://developer.paypal.com/webapps/developer/docs/integration/mobile/ios-integration-guide/
 * for more documentation of the parameters.
 *
 * @parameter clientId: clientId from developer.paypal.com
 * @parameter email: receiver's email address
 * @parameter payerId: a string that uniquely identifies a user within the scope of your system, such as an email address or user ID
 * @parameter payment: PayPalPayment object
 * @parameter completionCallback: a callback function accepting a js object, called when the user has completed payment
 * @parameter cancelCallback: a callback function accepting a reason string, called when the user cancels the payment
 */
PayPalMobile.prototype.presentPaymentUI = function(clientId, email, payerId, payment, completionCallback, cancelCallback) {
  cordova.exec(completionCallback, cancelCallback, "PayPalMobile", "presentPaymentUI", [clientId, email, payerId, payment]);
};

/**
 * Plugin setup boilerplate.
 */
cordova.addConstructor(function() {
  if (!window.plugins) {
    window.plugins = {};
  }

  if (!window.plugins.PayPalMobile) {
    window.plugins.PayPalMobile = new PayPalMobile();
  }
});
