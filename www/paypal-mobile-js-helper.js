//
// Copyright (c) 2014 PayPal. All rights reserved.
//


/**
 * The PayPalItem class defines an optional itemization for a payment.
 * @see https://developer.paypal.com/docs/api/#item-object for more details.
 * @param {String} name: Name of the item. 127 characters max
 * @param {Number} quantity: Number of units. 10 characters max.
 * @param {String} price: Unit price for this item 10 characters max.
 * May be negative for "coupon" etc
 * @param {String} currency: ISO standard currency code.
 * @param {String} sku: The stock keeping unit for this item. 50 characters max (optional)
 */
function PayPalItem(name, quantity, price, currency, sku) {
  this.name = String(name);
  this.quantity = Number(quantity);
  this.price = String(price);
  this.currency = String(currency);
  this.sku = sku;
}

/**
 * The PayPalPaymentDetails class defines optional amount details.
 * @param {String} subtotal: Sub-total (amount) of items being paid for. 10 characters max with support for 2 decimal places.
 * @param {String} shipping: Amount charged for shipping. 10 characters max with support for 2 decimal places.
 * @param {String} tax: Amount charged for tax. 10 characters max with support for 2 decimal places.
 * @see https://developer.paypal.com/webapps/developer/docs/api/#details-object for more details.
 */
function PayPalPaymentDetails(subtotal, shipping, tax) {
  this.subtotal = String(subtotal);
  this.shipping = shipping;
  this.tax = tax;
}

/**
 * Convenience constructor. Returns a PayPalPayment with the specified amount, currency code, and short description.
 * @param {String} amount: The amount of the payment.
 * @param {String} currencyCode: The ISO 4217 currency for the payment.
 * @param {String} shortDescription: A short descripton of the payment.
 * @param {String} intent: "Sale" for an immediate payment.
 * "Auth" for payment authorization only, to be captured separately at a later time.
 * "Order" for taking an order, with authorization and capture to be done separately at a later time.
 * @param {PayPalPaymentDetails} details: PayPalPaymentDetails object (optional)
 */
function PayPalPayment(amount, currency, shortDescription, intent, details) {
  this.amount = String(amount);
  this.currency = String(currency);
  this.shortDescription = String(shortDescription);
  this.intent = String(intent);
  this.details = details;
  this.bnCode = "PhoneGap_SP";
}

/**
 * Optional invoice number, for your tracking purposes. (up to 256 characters)
 * @param {String} invoiceNumber: The invoice number for the payment.
 */
PayPalPayment.prototype.invoiceNumber = function(invoiceNumber) {
  this.invoiceNumber = invoiceNumber;
};

/**
 * Optional text, for your tracking purposes. (up to 256 characters)
 * @param {String} custom: The custom text for the payment.
 */
PayPalPayment.prototype.custom = function(custom) {
  this.custom = custom;
};

/**
 * Optional text which will appear on the customer's credit card statement. (up to 22 characters)
 * @param {String} softDescriptor: credit card text for payment
 */
PayPalPayment.prototype.softDescriptor = function(softDescriptor) {
  this.softDescriptor = softDescriptor;
};

/**
 * Optional Build Notation code ("BN code"), obtained from partnerprogram@paypal.com,
 * for your tracking purposes.
 * @param {String} bnCode: bnCode for payment
 */
PayPalPayment.prototype.bnCode = function(bnCode) {
  this.bnCode = bnCode;
};

/**
 * Optional array of PayPalItem objects. @see PayPalItem
 * @note If you provide one or more items, be sure that the various prices correctly
 * sum to the payment `amount` or to `paymentDetails.subtotal`.
 * @param {String} bnCode: bnCode for payment
 */
PayPalPayment.prototype.items = function(items) {
  this.items = items;
};

/**
 * Optional payee email, if your app is paying a third-party merchant.
 * @param {String} payeeEmail: The payee's email. It must be a valid PayPal email address.
 */
PayPalPayment.prototype.payeeEmail = function(payeeEmail) {
  this.payeeEmail = payeeEmail;
};

/**
 * Optional customer shipping address, if your app wishes to provide this to the SDK.
 * @note make sure to set `payPalShippingAddressOption` in PayPalConfiguration to 1 or 3.
 * @param {Object} shippingAddress: PayPalShippingAddress object
 */
PayPalPayment.prototype.shippingAddress = function(shippingAddress) {
  this.shippingAddress = shippingAddress;
};

/**
 * You use a PayPalConfiguration object to configure many aspects of how the SDK behaves.
 * see defaults for options available
 */
function PayPalConfiguration(options) {

  var defaults = {
    /// Will be overridden by email used in most recent PayPal login.
    defaultUserEmail: null,
    /// Will be overridden by phone country code used in most recent PayPal login
    defaultUserPhoneCountryCode: null,
    /// Will be overridden by phone number used in most recent PayPal login.
    /// @note If you set defaultUserPhoneNumber, be sure to also set defaultUserPhoneCountryCode.
    defaultUserPhoneNumber: null,
    /// Your company name, as it should be displayed to the user
    /// when requesting consent via a PayPalFuturePaymentViewController.
    merchantName: null,
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
    /// For single payments, options for the shipping address.
    /// - 0 - PayPalShippingAddressOptionNone: no shipping address applies.
    /// - 1 - PayPalShippingAddressOptionProvided: shipping address will be provided by your app,
    ///   in the shippingAddress property of PayPalPayment.
    /// - 2 - PayPalShippingAddressOptionPayPal: user will choose from shipping addresses on file
    ///   for their PayPal account.
    /// - 3 - PayPalShippingAddressOptionBoth: user will choose from the shipping address provided by your app,
    ///   in the shippingAddress property of PayPalPayment, plus the shipping addresses on file for the user's PayPal account.
    /// Defaults to 0 (PayPalShippingAddressOptionNone).
    payPalShippingAddressOption: 0,
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
    /// Can be specified as a language code ("en", "fr", "zh-Hans", etc.) or as a locale ("en_AU", "fr_FR", "zh-Hant", etc.).
    /// If the library does not contain localized strings for a specified locale, then will fall back to the language. E.g., "es_CO" -> "es".
    /// If the library does not contain localized strings for a specified language, then will fall back to American English.
    ///
    /// If you specify only a language code, and that code matches the device's currently preferred language,
    /// then the library will attempt to use the device's current region as well.
    /// E.g., specifying "en" on a device set to "English" and "United Kingdom" will result in "en_GB".
    ///
    /// These localizations are currently included:
    /// da,de,en,en_AU,en_GB,es,es_MX,fr,he,it,ja,ko,nb,nl,pl,pt,pt_BR,ru,sv,tr,zh-Hans,zh-Hant,zh-Hant_TW.
    languageOrLocale: null,
    /// Normally, the SDK blurs the screen when the app is backgrounded,
    /// to obscure credit card or PayPal account details in the iOS-saved screenshot.
    /// If your app already does its own blurring upon backgrounding, you might choose to disable this.
    /// Defaults to NO.
    disableBlurWhenBackgrounding: false,
    /// If you will present the SDK's view controller within a popover, then set this property to YES.
    /// Defaults to NO. (iOS only)
    presentingInPopover: false,
    /// Sandbox credentials can be difficult to type on a mobile device. Setting this flag to YES will
    /// cause the sandboxUserPassword and sandboxUserPin to always be pre-populated into login fields.
    ///
    /// This setting will have no effect if the operation mode is production.
    forceDefaultsInSandbox: false,
    /// Password to use for sandbox if 'forceDefaultsInSandbox' is set.
    sandboxUserPassword: null,
    /// PIN to use for sandbox if 'forceDefaultsInSandbox' is set.
    sandboxUserPin: null

  };

  if (!options || typeof options !== "object") {
    return defaults;
  }

  for (var i in options) {
    if (defaults.hasOwnProperty(i)) {
      defaults[i] = options[i];
    }
  }

  return defaults;
}

/**
* See the documentation of the individual properties for more detail.
* @param {String} recipientName: Name of the recipient at this address. 50 characters max.
* @param {String} line1: Line 1 of the address (e.g., Number, street, etc). 100 characters max.
* @param {String} Line 2 of the address (e.g., Suite, apt #, etc). 100 characters max. Optional.
* @param {String} city: City name. 50 characters max.
* @param {String} state: 2-letter code for US states, and the equivalent for other countries. 100 characters max. Required in certain countries.
* @param {String} postalCode: ZIP code or equivalent is usually required for countries that have them. 20 characters max. Required in certain countries.
* @param {String} countryCode: 2-letter country code. 2 characters max.
*/

function PayPalShippingAddress(recipientName, line1, line2, city, state, postalCode, countryCode) {
  this.recipientName = recipientName;
  this.line1 = line1;
  this.line2 = line2;
  this.city = city;
  this.state = state;
  this.postalCode = postalCode;
  this.countryCode = countryCode;
}
