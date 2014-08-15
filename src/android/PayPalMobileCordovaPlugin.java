//  Copyright (c) 2014 PayPal. All rights reserved.

package com.paypal.cordova.sdk;

import java.math.BigDecimal;

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
	
	private static final int REQUEST_SINGLE_PAYMENT = 1;
    private static final int REQUEST_CODE_FUTURE_PAYMENT = 2;

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
			this.applicationCorrelationIDForEnvironment(args);
		} else if (action.equals("renderSinglePaymentUI")) {
			this.renderSinglePaymentUI(args);
		} else if (action.equals("renderFuturePaymentUI")) {
			this.renderFuturePaymentUI(args);
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

	private void applicationCorrelationIDForEnvironment(JSONArray args) throws JSONException {
		// Environment not used on android
		//String env = args.getString(0);
		String correlationId = PayPalConfiguration.getApplicationCorrelationId(this.cordova.getActivity());
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
		String paymentIntent = ("sale".equalsIgnoreCase(paymentObject.getString("intent"))) ? PayPalPayment.PAYMENT_INTENT_SALE : PayPalPayment.PAYMENT_INTENT_AUTHORIZE;
		JSONObject paymentDetails = paymentObject.has("details") ? paymentObject.getJSONObject("details") : null;

		// create payment object
		PayPalPayment payment = new PayPalPayment(new BigDecimal(amount),
				currency, shortDescription, paymentIntent);
		payment.paymentDetails(this.parsePaymentDetails(paymentDetails));
		
		
		Intent intent = new Intent(this.activity, PaymentActivity.class);
		intent.putExtra(PaymentActivity.EXTRA_PAYMENT, payment);
		this.cordova.startActivityForResult(this, intent, REQUEST_SINGLE_PAYMENT);
	}
	
	
	private void renderFuturePaymentUI(JSONArray args) throws JSONException {
		
		Intent intent = new Intent(this.activity, PayPalFuturePaymentActivity.class);
		this.cordova.startActivityForResult(this, intent, REQUEST_CODE_FUTURE_PAYMENT);
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
	}
	
	private PayPalPaymentDetails parsePaymentDetails(JSONObject object) throws JSONException {
		if (object == null || 0 == object.length()) {
			return null;
		}
		
		BigDecimal subtotal = object.has("subtotal") ? new BigDecimal(object.getString("subtotal")) : null;
		BigDecimal shipping = object.has("shipping") ? new BigDecimal(object.getString("shipping")) : null;
		BigDecimal tax = object.has("tax") ? new BigDecimal(object.getString("tax")) : null;
		
		PayPalPaymentDetails paymentDetails =  new PayPalPaymentDetails(shipping, subtotal, tax);
		return paymentDetails;	
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
		}
	}
}
