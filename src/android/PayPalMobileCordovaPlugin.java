package com.paypal.cordova.sdk;

import java.math.BigDecimal;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;

import com.paypal.android.sdk.payments.PayPalPayment;
import com.paypal.android.sdk.payments.PayPalService;
import com.paypal.android.sdk.payments.PaymentActivity;
import com.paypal.android.sdk.payments.PaymentConfirmation;
import com.paypal.android.sdk.payments.Version;

public class PayPalMobileCordovaPlugin extends CordovaPlugin {

	private CallbackContext callbackContext;
	private String environemnt = PaymentActivity.ENVIRONMENT_LIVE;

	@Override
	public boolean execute(String action, JSONArray args,
			CallbackContext callbackContext) throws JSONException {
		this.callbackContext = callbackContext;
		boolean retValue = true;
		if (action.equals("version")) {
			this.version();
		} else if (action.equals("setEnvironment")) {
			this.setEnvironment(args);
		} else if (action.equals("environment")) {
			this.environment();
		} else if (action.equals("prepareForPayment")) {
			this.prepareForPayment(args);
		} else if (action.equals("presentPaymentUI")) {
			this.presentPaymentUI(args);
		} else {
			retValue = false;
		}
		
		return retValue;
	}

	@Override
	public void onDestroy() {
		this.cordova.getActivity().stopService(
				new Intent(this.cordova.getActivity(), PayPalService.class));
		super.onDestroy();
	}

	// internal implementation 
	private void version() {
		this.callbackContext.success(Version.PRODUCT_VERSION);
	}
	
	private void setEnvironment(JSONArray args) throws JSONException {
		// make sure we use the same environment ids
		String env = args.getString(0);
		if (env.equals("PayPalEnvironmentNoNetwork")) {
			this.environemnt = PaymentActivity.ENVIRONMENT_NO_NETWORK;
		} else if (env.equals("PayPalEnvironmentProduction")) {
			this.environemnt = PaymentActivity.ENVIRONMENT_LIVE;
		} else if (env.equals("PayPalEnvironmentSandbox")) {
			this.environemnt = PaymentActivity.ENVIRONMENT_SANDBOX;
		} else {
			this.callbackContext
					.error("The provided environment is not supported");
			return;
		}

		this.callbackContext.success();

	}

	private void environment() {
		this.callbackContext.success(this.environemnt);
	}

	private void prepareForPayment(JSONArray args) throws JSONException {
		String clientId = args.getString(0);
		Activity activity = this.cordova.getActivity();
		Intent serviceIntent = new Intent(activity, PayPalService.class);
		serviceIntent.putExtra(PaymentActivity.EXTRA_PAYPAL_ENVIRONMENT,
				this.environemnt);
		serviceIntent.putExtra(PaymentActivity.EXTRA_CLIENT_ID, clientId);
		activity.startService(serviceIntent);
		
		this.callbackContext.success();
	}

	private void presentPaymentUI(JSONArray args) throws JSONException {
		if (args.length() != 4) {
			this.callbackContext
					.error("presentPaymentUI requires precisely four arguments");
			return;
		}

		String clientId = args.getString(0);
		String email = args.getString(1);
		String payerId = args.getString(2);
		JSONObject paymentObject = args.getJSONObject(3);

		String amount = paymentObject.getString("amount");
		String currency = paymentObject.getString("currency");
		String shortDescription = paymentObject.getString("shortDescription");

		PayPalPayment payment = new PayPalPayment(new BigDecimal(amount),
				currency, shortDescription);

		Intent intent = new Intent(this.cordova.getActivity(),
				PaymentActivity.class);
		intent.putExtra(PaymentActivity.EXTRA_PAYPAL_ENVIRONMENT, environemnt);
		intent.putExtra(PaymentActivity.EXTRA_CLIENT_ID, clientId);
		intent.putExtra(PaymentActivity.EXTRA_RECEIVER_EMAIL, email);

		intent.putExtra(PaymentActivity.EXTRA_PAYER_ID, payerId);
		intent.putExtra(PaymentActivity.EXTRA_PAYMENT, payment);
		this.cordova.startActivityForResult(this, intent, 0);
	}
	
	// onActivityResult
	public void onActivityResult(int requestCode, int resultCode, Intent intent) {
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
		} else if (resultCode == PaymentActivity.RESULT_PAYMENT_INVALID) {
			this.callbackContext.error("payment invalid");
		} else {
			this.callbackContext.error(resultCode);
		}
	}
}
