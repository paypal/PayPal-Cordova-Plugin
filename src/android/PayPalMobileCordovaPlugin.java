//  Copyright (c) 2014 PayPal. All rights reserved.

package com.paypal.cordova.sdk;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import com.paypal.android.sdk.payments.*;

public class PayPalMobileCordovaPlugin extends CordovaPlugin {

    private CallbackContext callbackContext;
    private String environment = PayPalConfiguration.ENVIRONMENT_PRODUCTION;
    private String productionClientId = null;
    private String sandboxClientId = null;
    private PayPalConfiguration configuration = new PayPalConfiguration();
    private Activity activity = null;
    private boolean serverStarted = false;
    private int shippingAddressOption = 0;

    private static final int REQUEST_SINGLE_PAYMENT = 1;
    private static final int REQUEST_CODE_FUTURE_PAYMENT = 2;
    private static final int REQUEST_CODE_PROFILE_SHARING = 3;

    @Override
    public boolean execute(String action, JSONArray args,
                           CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        this.activity = this.cordova.getActivity();
        boolean retValue = true;
        if (action.equals("version")) {
            this.version();
        } else if (action.equals("init")) {
            this.init(args);
        } else if (action.equals("prepareToRender")) {
            this.prepareToRender(args);
        } else if (action.equals("applicationCorrelationIDForEnvironment")) {
            this.clientMetadataID(args);
        } else if (action.equals("clientMetadataID")) {
            this.clientMetadataID(args);
        } else if (action.equals("renderSinglePaymentUI")) {
            this.renderSinglePaymentUI(args);
        } else if (action.equals("renderFuturePaymentUI")) {
            this.renderFuturePaymentUI(args);
        } else if (action.equals("renderProfileSharingUI")) {
            this.renderProfileSharingUI(args);
        } else {
            retValue = false;
        }

        return retValue;
    }

    @Override
    public void onDestroy() {
        if (null != this.activity && serverStarted) {
            this.activity.stopService(new Intent(this.activity, PayPalService.class));
        }
        super.onDestroy();
    }

    // internal implementation
    private void version() {
        this.callbackContext.success(Version.PRODUCT_VERSION);
    }


    private void init(JSONArray args) throws JSONException {
        JSONObject jObject = args.getJSONObject(0);
        this.productionClientId = jObject.getString("PayPalEnvironmentProduction");
        this.sandboxClientId = jObject.getString("PayPalEnvironmentSandbox");
        this.callbackContext.success();
    }

    private void prepareToRender(JSONArray args) throws JSONException {
        // make sure we use the same environment ids
        String env = args.getString(0);
        if (env.equalsIgnoreCase("PayPalEnvironmentNoNetwork")) {
            this.environment = PayPalConfiguration.ENVIRONMENT_NO_NETWORK;
        } else if (env.equalsIgnoreCase("PayPalEnvironmentProduction")) {
            this.environment = PayPalConfiguration.ENVIRONMENT_PRODUCTION;
            this.configuration.clientId(this.productionClientId);
        } else if (env.equalsIgnoreCase("PayPalEnvironmentSandbox")) {
            this.environment = PayPalConfiguration.ENVIRONMENT_SANDBOX;
            this.configuration.clientId(this.sandboxClientId);
        } else {
            this.callbackContext
                    .error("The provided environment is not supported");
            return;
        }
        this.configuration.environment(environment);

        // get configuration and update
        if (args.length() > 1) {
            JSONObject config = args.getJSONObject(1);
            this.updatePayPalConfiguration(config);
        }

        // start service
        this.startService();

        this.callbackContext.success();

    }

    private void clientMetadataID(JSONArray args) throws JSONException {
        // Environment not used on android
        //String env = args.getString(0);
        String correlationId = PayPalConfiguration.getClientMetadataId(this.cordova.getActivity());
        this.callbackContext.success(correlationId);
    }

    private void startService() {
        if (serverStarted) {
            serverStarted = this.activity.stopService(new Intent(this.activity, PayPalService.class));
        }

        Intent intent = new Intent(this.activity, PayPalService.class);
        intent.putExtra(PayPalService.EXTRA_PAYPAL_CONFIGURATION, this.configuration);
        this.activity.startService(intent);
        serverStarted = true;

    }

    private void renderSinglePaymentUI(JSONArray args) throws JSONException {
        if (args.length() != 1) {
            this.callbackContext
                    .error("renderPaymentUI payment object must be provided");
            return;
        }

        // get payment details
        JSONObject paymentObject = args.getJSONObject(0);
        String amount = paymentObject.getString("amount");
        String currency = paymentObject.getString("currency");
        String shortDescription = paymentObject.getString("shortDescription");
        String intentString = paymentObject.getString("intent");

        String paymentIntent = null;
        if ("sale".equalsIgnoreCase(intentString)) {
            paymentIntent = PayPalPayment.PAYMENT_INTENT_SALE;
        } else if ("order".equalsIgnoreCase(intentString)) {
            paymentIntent = PayPalPayment.PAYMENT_INTENT_ORDER;
        } else {
            paymentIntent = PayPalPayment.PAYMENT_INTENT_AUTHORIZE;
        }

        // invoice number is optional
        String invoiceNumber = null;
        if (paymentObject.has("invoiceNumber") && !paymentObject.isNull("invoiceNumber")) {
            invoiceNumber = paymentObject.getString("invoiceNumber");
        }

        // optional
        String custom = null;
        if (paymentObject.has("custom") && !paymentObject.isNull("custom")) {
            custom = paymentObject.getString("custom");
        }

        // optional
        String softDescriptor = null;
        if (paymentObject.has("softDescriptor") && !paymentObject.isNull("softDescriptor")) {
            softDescriptor = paymentObject.getString("softDescriptor");
        }

        // optional
        String payeeEmail = null;
        if (paymentObject.has("payeeEmail") && !paymentObject.isNull("payeeEmail")) {
            payeeEmail = paymentObject.getString("payeeEmail");
        }

        // optional
        String bnCode = null;
        if (paymentObject.has("bnCode") && !paymentObject.isNull("bnCode")) {
            bnCode = paymentObject.getString("bnCode");
        }        

        // optional
        JSONObject paymentDetails = paymentObject.has("details") ? paymentObject.getJSONObject("details") : null;

        // optional
        JSONArray items = paymentObject.has("items") ? paymentObject.getJSONArray("items") : null;

        // optional
        JSONObject shippingAddress = paymentObject.has("shippingAddress") ? paymentObject.getJSONObject("shippingAddress") : null;

        // create payment object
        PayPalPayment payment = new PayPalPayment(new BigDecimal(amount),
                currency, shortDescription, paymentIntent);

        // setup
        payment.invoiceNumber(invoiceNumber);
        payment.custom(custom);
        payment.softDescriptor(softDescriptor);
        payment.payeeEmail(payeeEmail);
        payment.bnCode(bnCode);
        payment.paymentDetails(this.parsePaymentDetails(paymentDetails));
        payment.items(this.parsePaymentItems(items));

        // setup shipping address configuration
        switch (this.shippingAddressOption) {
            case 1: // only provided shipping address
                payment.enablePayPalShippingAddressesRetrieval(false);
                payment.providedShippingAddress(this.getPayPalShippingAddress(shippingAddress));
                break;
            case 2: // only PayPal shipping address
                payment.enablePayPalShippingAddressesRetrieval(true);
                break;
            case 3: // both provided and PayPal shipping addresses
                payment.enablePayPalShippingAddressesRetrieval(true);
                payment.providedShippingAddress(this.getPayPalShippingAddress(shippingAddress));
                break;
            case 0: // no shipping address
            default:
                payment.enablePayPalShippingAddressesRetrieval(false);
        } 

        if (payment.isProcessable()) {
            Intent intent = new Intent(this.activity, PaymentActivity.class);
            intent.putExtra(PaymentActivity.EXTRA_PAYMENT, payment);
            this.cordova.startActivityForResult(this, intent, REQUEST_SINGLE_PAYMENT);
        } else {
            this.callbackContext
                    .error("payment not processable");
            return;
        }
        
    }


    private void renderFuturePaymentUI(JSONArray args) throws JSONException {

        Intent intent = new Intent(this.activity, PayPalFuturePaymentActivity.class);
        this.cordova.startActivityForResult(this, intent, REQUEST_CODE_FUTURE_PAYMENT);
    }

    private void renderProfileSharingUI(JSONArray args) throws JSONException {
        if (args.length() != 1) {
            this.callbackContext
                    .error("renderProfileSharingUI scopes must be provided");
            return;
        }

        Intent intent = new Intent(this.activity, PayPalProfileSharingActivity.class);
        // add codes
        intent.putExtra(PayPalProfileSharingActivity.EXTRA_REQUESTED_SCOPES, getOauthScopes(args.getJSONArray(0)));
        this.cordova.startActivityForResult(this, intent, REQUEST_CODE_PROFILE_SHARING);
    }

    private PayPalOAuthScopes getOauthScopes(JSONArray scopeList)  throws JSONException {
    /* create the set of required scopes
     * Note: see https://developer.paypal.com/docs/integration/direct/identity/attributes/ for mapping between the
     * attributes you select for this app in the PayPal developer portal and the scopes required here.
     */
        Set<String> scopes = new HashSet<String>();
        for (int i = 0; i < scopeList.length(); i++) {
            String scope = scopeList.getString(i);
            if (scope.equalsIgnoreCase("profile")) {
                scopes.add(PayPalOAuthScopes.PAYPAL_SCOPE_PROFILE);
            } else if (scope.equalsIgnoreCase("email")) {
                scopes.add(PayPalOAuthScopes.PAYPAL_SCOPE_EMAIL);
            } else if (scope.equalsIgnoreCase("phone")) {
                scopes.add(PayPalOAuthScopes.PAYPAL_SCOPE_PHONE);
            } else if (scope.equalsIgnoreCase("address")) {
                scopes.add(PayPalOAuthScopes.PAYPAL_SCOPE_ADDRESS);
            } else if (scope.equalsIgnoreCase("paypalattributes")) {
                scopes.add(PayPalOAuthScopes.PAYPAL_SCOPE_PAYPAL_ATTRIBUTES);
            } else if (scope.equalsIgnoreCase("futurepayments")) {
                scopes.add(PayPalOAuthScopes.PAYPAL_SCOPE_FUTURE_PAYMENTS);
            } else {
                scopes.add(scope);
            }
        }
        return new PayPalOAuthScopes(scopes);

    }

    private void updatePayPalConfiguration(JSONObject object) throws JSONException {
        if (object == null || 0 == object.length()) {
            return;
        }

        if (object.has("defaultUserEmail") && !object.isNull("defaultUserEmail")) {
            this.configuration.defaultUserEmail(object.getString("defaultUserEmail"));
        }
        if (object.has("defaultUserPhoneCountryCode") && !object.isNull("defaultUserPhoneCountryCode")) {
            this.configuration.defaultUserPhoneCountryCode(object.getString("defaultUserPhoneCountryCode"));
        }
        if (object.has("defaultUserPhoneNumber") && !object.isNull("defaultUserPhoneNumber")) {
            this.configuration.defaultUserPhone(object.getString("defaultUserPhoneNumber"));
        }
        if (object.has("merchantName") && !object.isNull("merchantName")) {
            this.configuration.merchantName(object.getString("merchantName"));
        }
        if (object.has("merchantPrivacyPolicyURL") && !object.isNull("merchantPrivacyPolicyURL")) {
            this.configuration.merchantPrivacyPolicyUri(Uri.parse(object.getString("merchantPrivacyPolicyURL")));
        }
        if (object.has("merchantUserAgreementURL") && !object.isNull("merchantUserAgreementURL")) {
            this.configuration.merchantUserAgreementUri(Uri.parse(object.getString("merchantUserAgreementURL")));
        }
        if (object.has("acceptCreditCards")) {
            this.configuration.acceptCreditCards(object.getBoolean("acceptCreditCards"));
        }
        if (object.has("rememberUser")) {
            this.configuration.rememberUser(object.getBoolean("rememberUser"));
        }
        if (object.has("forceDefaultsInSandbox")) {
            this.configuration.forceDefaultsOnSandbox(object.getBoolean("forceDefaultsInSandbox"));
        }
        if (object.has("languageOrLocale") && !object.isNull("languageOrLocale")) {
            this.configuration.languageOrLocale(object.getString("languageOrLocale"));
        }
        if (object.has("sandboxUserPassword") && !object.isNull("sandboxUserPassword")) {
            this.configuration.sandboxUserPassword(object.getString("sandboxUserPassword"));
        }
        if (object.has("sandboxUserPin") && !object.isNull("sandboxUserPin")) {
            this.configuration.sandboxUserPin(object.getString("sandboxUserPin"));
        }
        if (object.has("payPalShippingAddressOption")) {
            this.shippingAddressOption = object.getInt("payPalShippingAddressOption");
        }
    }

    private PayPalPaymentDetails parsePaymentDetails(JSONObject object) throws JSONException {
        if (object == null || 0 == object.length()) {
            return null;
        }

        BigDecimal subtotal = !object.isNull("subtotal") ? new BigDecimal(object.getString("subtotal")) : null;
        BigDecimal shipping = !object.isNull("shipping") ? new BigDecimal(object.getString("shipping")) : null;
        BigDecimal tax = !object.isNull("tax") ? new BigDecimal(object.getString("tax")) : null;

        PayPalPaymentDetails paymentDetails =  new PayPalPaymentDetails(shipping, subtotal, tax);
        return paymentDetails;
    }

    private PayPalItem[] parsePaymentItems(JSONArray array) throws JSONException {
        if (array == null || 0 == array.length()) {
            return null;
        }

        PayPalItem[] items = new PayPalItem[array.length()];
        for (int i = 0; i < array.length(); i++) {
            JSONObject json = array.getJSONObject(i);

            String name = json.getString("name");
            int quantity = json.getInt("quantity");
            BigDecimal price = new BigDecimal(json.getString("price"));
            String currency = json.getString("currency");
            String sku = !json.isNull("sku") ? json.getString("sku") : null;
            PayPalItem item = new PayPalItem(name, quantity, price, currency, sku);
            
            items[i] = item;
        }

        return items;
    }

    private ShippingAddress getPayPalShippingAddress(JSONObject object) throws JSONException {
        String name = object.getString("recipientName");
        String line1 = object.getString("line1");
        String line2 = object.getString("line2");
        String city = object.getString("city");
        String state = !object.isNull("state") ? object.getString("state") : null;
        String postalCode = !object.isNull("postalCode") ? object.getString("postalCode") : null;
        String countryCode = object.getString("countryCode");
        ShippingAddress shippingAddress =
                new ShippingAddress().recipientName(name).line1(line1).line2(line2)
                        .city(city).state(state).postalCode(postalCode).countryCode(countryCode);
        return shippingAddress;
    }

    // onActivityResult
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (REQUEST_SINGLE_PAYMENT == requestCode) {
            if (resultCode == Activity.RESULT_OK) {
                PaymentConfirmation confirmation = null;
                if (intent.hasExtra(PaymentActivity.EXTRA_RESULT_CONFIRMATION)) {
                    confirmation = intent
                            .getParcelableExtra(PaymentActivity.EXTRA_RESULT_CONFIRMATION);
                    this.callbackContext.success(confirmation.toJSONObject());
                } else {
                    this.callbackContext
                            .error("payment was ok but no confirmation");
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                this.callbackContext.error("payment cancelled");
            } else if (resultCode == PaymentActivity.RESULT_EXTRAS_INVALID) {
                this.callbackContext.error("An invalid Payment was submitted. Please see the docs.");
            } else {
                this.callbackContext.error(resultCode);
            }
        } else if (requestCode == REQUEST_CODE_FUTURE_PAYMENT) {
            if (resultCode == Activity.RESULT_OK) {
                PayPalAuthorization auth = null;
                if (intent.hasExtra(PayPalFuturePaymentActivity.EXTRA_RESULT_AUTHORIZATION)) {
                    auth = intent.getParcelableExtra(PayPalFuturePaymentActivity.EXTRA_RESULT_AUTHORIZATION);
                    this.callbackContext.success(auth.toJSONObject());
                } else {
                    this.callbackContext
                            .error("Authorization was ok but no code");
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                this.callbackContext.error("Future Payment user canceled.");
            } else if (resultCode == PayPalFuturePaymentActivity.RESULT_EXTRAS_INVALID) {
                this.callbackContext.error("Possibly configuration submitted is invalid");
            }
        } else if (requestCode == REQUEST_CODE_PROFILE_SHARING) {
            if (resultCode == Activity.RESULT_OK) {
                PayPalAuthorization auth = null;
                if (intent.hasExtra(PayPalProfileSharingActivity.EXTRA_RESULT_AUTHORIZATION)) {
                    auth = intent.getParcelableExtra(PayPalProfileSharingActivity.EXTRA_RESULT_AUTHORIZATION);
                    this.callbackContext.success(auth.toJSONObject());
                } else {
                    this.callbackContext
                            .error("Authorization was ok but no code");
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                this.callbackContext.error("Profile Sharing user canceled.");
            } else if (resultCode == PayPalProfileSharingActivity.RESULT_EXTRAS_INVALID) {
                this.callbackContext.error("Possibly configuration submitted is invalid");
            }
        }
    }
}
