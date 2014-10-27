//
// Copyright (c) 2014 PayPal. All rights reserved.
//

/**
 * The PayPalPaymentDetails class defines optional amount details.
 * @param {String} subtotal: Sub-total (amount) of items being paid for. 10 characters max with support for 2 decimal places.
 * @param {String} shipping: Amount charged for shipping. 10 characters max with support for 2 decimal places.
 * @param {String} tax: Amount charged for tax. 10 characters max with support for 2 decimal places.
 * @see https://developer.paypal.com/webapps/developer/docs/api/#details-object for more details.
 */
function PayPalPaymentDetails(subtotal, shipping, tax) {
  this.subtotal = subtotal;
  this.shipping = shipping;
  this.tax = tax;
}

/**
 * Convenience constructor. Returns a PayPalPayment with the specified amount, currency code, and short description.
 * @param {String} amount: The amount of the payment.
 * @param {String} currencyCode: The ISO 4217 currency for the payment.
 * @param {String} shortDescription: A short descripton of the payment.
 * @param {String} intent: Sale for an immediate payment or Auth
 *                 for payment authorization only, to be captured separately at a later time.
 * @param {PayPalPaymentDetails} details: PayPalPaymentDetails object (optional)
 */
function PayPalPayment(amount, currency, shortDescription, intent, details) {
  this.amount = amount;
  this.currency = currency;
  this.shortDescription = shortDescription;
  this.intent = intent;
  this.details = details;
}

/**
 * Sets the PayPalPayment invoiceNumber property.
 * @param {String} invoiceNumber: The invoiceNumber for the payment.
 */
PayPalPayment.prototype.invoiceNumber = function(invoiceNumber) {
  this.invoiceNumber = String(invoiceNumber);
};


/**
 * You use a PayPalConfiguration object to configure many aspects of how the SDK behaves.
 * see defaults for options available
 */
function PayPalConfiguration(options) {

  var defaults = {
      /// Will be overridden by email used in most recent PayPal login.
      defaultUserEmail : null,
      /// Will be overridden by phone country code used in most recent PayPal login
      defaultUserPhoneCountryCode : null,
      /// Will be overridden by phone number used in most recent PayPal login.
      /// @note If you set defaultUserPhoneNumber, be sure to also set defaultUserPhoneCountryCode.
      defaultUserPhoneNumber : null,
      /// Your company name, as it should be displayed to the user
      /// when requesting consent via a PayPalFuturePaymentViewController.
      merchantName : null,
      /// URL of your company's privacy policy, which will be offered to the user
      /// when requesting consent via a PayPalFuturePaymentViewController.
      merchantPrivacyPolicyURL: null,
      /// URL of your company's user agreement, which will be offered to the user
      /// when requesting consent via a PayPalFuturePaymentViewController.
      merchantUserAgreementURL: null,
      /// If set to NO, the SDK will only support paying with PayPal, not with credit cards.
      /// This applies only to single payments (via PayPalPaymentViewController).
      /// Future payments (via PayPalFuturePaymentViewController) always use PayPal.
      /// Defaults to YES
      acceptCreditCards: true,
      /// If set to YES, then if the user pays via their PayPal account,
      /// the SDK will remember the user's PayPal username or phone number;
      /// if the user pays via their credit card, then the SDK will remember
      /// the PayPal Vault token representing the user's credit card.
      ///
      /// If set to NO, then any previously-remembered username, phone number, or
      /// credit card token will be erased, and subsequent payment information will
      /// not be remembered.
      ///
      /// Defaults to YES.
      rememberUser: true,
      /// If not set, or if set to nil, defaults to the device's current language setting.
      ///
      /// Can be specified as a language code ("en", "fr", "zh-Hans", etc.) or as a locale ("en_AU", "fr_FR", "zh-Hant_HK", etc.).
      /// If the library does not contain localized strings for a specified locale, then will fall back to the language. E.g., "es_CO" -> "es".
      /// If the library does not contain localized strings for a specified language, then will fall back to American English.
      ///
      /// If you specify only a language code, and that code matches the device's currently preferred language,
      /// then the library will attempt to use the device's current region as well.
      /// E.g., specifying "en" on a device set to "English" and "United Kingdom" will result in "en_GB".
      ///
      /// These localizations are currently included:
      /// da,de,en,en_AU,en_GB,en_SV,es,es_MX,fr,he,it,ja,ko,nb,nl,pl,pt,pt_BR,ru,sv,tr,zh-Hans,zh-Hant_HK,zh-Hant_TW.
      languageOrLocale: null,
      /// Normally, the SDK blurs the screen when the app is backgrounded,
      /// to obscure credit card or PayPal account details in the iOS-saved screenshot.
      /// If your app already does its own blurring upon backgrounding, you might choose to disable this.
      /// Defaults to NO.
      disableBlurWhenBackgrounding : false,
      /// Sandbox credentials can be difficult to type on a mobile device. Setting this flag to YES will
      /// cause the sandboxUserPassword and sandboxUserPin to always be pre-populated into login fields.
      ///
      /// This setting will have no effect if the operation mode is production.
      forceDefaultsInSandbox : false,
      /// Password to use for sandbox if 'forceDefaultsInSandbox' is set.
      sandboxUserPassword: null,
      /// PIN to use for sandbox if 'forceDefaultsInSandbox' is set.
      sandboxUserPin: null

  };

  if(!options || typeof options !== "object") {
      return defaults;
  }

  for(var i in options) {
    if (defaults.hasOwnProperty(i)) {
        defaults[i] = options[i];
    }
  }

  return defaults;
}
