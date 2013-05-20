//
//  PayPalMobilePGPlugin.js
//

function PayPalPayment(amount, currency, shortDescription) {
  this.amount = amount;
  this.currency = currency;
  this.shortDescription = shortDescription;
}

/**
 * This class exposes PayPalMobile's library functionality to JavaScript.
 *
 * @constructor
 */

function PayPalMobile() {}


/**
 * Retrieve the version of the PayPalMobile library. Useful when contacting support.
 *
 * @parameter callback: a callback function accepting a string.
 */
PayPalMobile.prototype.version = function(callback) {
  var failureCallback = function() {
    console.log("Could not retrieve library version");
  };

  cordova.exec(callback, failureCallback, "PayPalMobile", "version", []);
};


/**
 * Set envrionment for PayPalMobile library.
 *
 * @parameter environment: set environment settings, either mock, sandbox or live.
 */
PayPalMobile.prototype.setEnvironment = function(environment) {
  var failureCallback = function() {
    console.log("Could not retrieve environemnt");
  };

  cordova.exec(null, failureCallback, "PayPalMobile", "setEnvironment", [environment]);
};

/**
 * Retrieve environment settings: mock, sandbox, live
 *
 * @parameter callback: a callback function accepting a string.
 */
PayPalMobile.prototype.environment = function(callback) {
  var failureCallback = function() {
    console.log("Could not retrieve environemnt");
  };

  cordova.exec(callback, failureCallback, "PayPalMobile", "environment", []);
};

/**
 * You SHOULD preconnect to PayPal to prepare the device for processing payments.
 * This improves the user experience, by making the presentation of the
 * UI faster. The preconnect is valid for a limited time, so
 * the recommended time to preconnect is when you present the UI in
 * which users may choose to initiate payment.
 *
 * @parameter clientID your client id from developer.paypal.com
 * @parameter callback: a callback function success
 */
PayPalMobile.prototype.prepareForPayment = function(clientId) {
  var failureCallback = function(message) {
    console.log("Could not perform prepareForPurchase " + message);
  };

  cordova.exec(null, failureCallback, "PayPalMobile", "prepareForPayment", [clientId]);
};


/**
 * start payment UI for processing
 *
 * @parameter clientId: clientId from developer.paypal.com
 * @parameter email: receiver's email address
 * @parameter payerId: your own reference can be nil
 * @parameter payment: PayPalPayment object
 * @parameter resultCallback: a callback function accepting js object.
 * @parameter cancelCallback: user canceled payment UI
 */
PayPalMobile.prototype.payment = function(clientId, email, payerId, payment, resultCallback, cancelCallback) {
  cordova.exec(resultCallback, cancelCallback, "PayPalMobile", "payment", [clientId, email, payerId, payment]);
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
