PayPal Cordova Plugin Release Notes
===================================
TODO
-----
* iOS: Update to card.io 5.4.0 to help avoid API name collisions [#456](https://github.com/paypal/PayPal-iOS-SDK/issues/456).

TODO
-----
* iOS: Update to card.io 5.4.0 to help avoid API name collisions [#456](https://github.com/paypal/PayPal-iOS-SDK/issues/456).

-----
* iOS: Update to card.io 5.4.0 to help avoid API name collisions [#456](https://github.com/paypal/PayPal-iOS-SDK/issues/456).

* iOS: Fix issue with Bitcode when archiving [#443](https://github.com/paypal/PayPal-iOS-SDK/issues/443).
* iOS: If you use card.io to scan credit cards, you should add the key
  [`NSCameraUsageDescription`](https://developer.apple.com/library/prerelease/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW24)
  to your app's `Info.plist` and set the value to be a string describing why your app needs to use the camera
  (e.g. "To scan credit cards."). This string will be displayed when the app initially requests permission to access
  the camera.

-----
* iOS: Update to card.io 5.4.0 to help avoid API name collisions [#456](https://github.com/paypal/PayPal-iOS-SDK/issues/456).


* iOS: Update localized messages.
* iOS: Fix issue with truncated text in certain table cells. See [issue #367](https://github.com/paypal/PayPal-iOS-SDK/issues/367).
* iOS: Change layout for 1Password icon to be in the email/phone field. See [issue #405](https://github.com/paypal/PayPal-iOS-SDK/issues/405)
* iOS: Allow configuration option to disable shake animations for accessibility. See [issue #380](https://github.com/paypal/PayPal-iOS-SDK/issues/380). See `PayPalConfiguration disableShakeAnimations` option.
* iOS: Fix issue with missing 1Password data. See [issue #427](https://github.com/paypal/PayPal-iOS-SDK/issues/427).
* iOS: Fix issue with network request timeouts
* iOS: Update card.io to iOS 5.3.2
* iOS: Fix missing nullability headers See issue #404

3.2.2
-----
* iOS: Update to card.io 5.4.0 to help avoid API name collisions [#456](https://github.com/paypal/PayPal-iOS-SDK/issues/456).

* Android: Minor bug fixes.
* Android: Updated gradle version to 2.14.
* Android: Include `org.json.*` exceptions in default proguard file [#299](https://github.com/paypal/PayPal-Android-SDK/issues/299).

3.2.1
-----
* iOS: Update to card.io 5.4.0 to help avoid API name collisions [#456](https://github.com/paypal/PayPal-iOS-SDK/issues/456).

* Android: Update card.io to 5.4.0.
* Android: Update okhttp dependency to 3.3.1.

3.2.0
------
* Enabled card.io plugin capabilities.

3.1.26
------
* Android: Update card.io to 5.3.4.

3.1.25
------
* Android: Update card.io to 5.3.2.
* Android: Add proguard config to aar file.
* Android: Minor bug fixes.

3.1.24
------
* iOS: Update SDK to [2.14.0](https://github.com/paypal/PayPal-iOS-SDK/releases/tag/2.14.0).
* iOS: Support for right to left language layouts in iOS 9.
* iOS: Fix for dynamic text in prices.
* Android:  Updated `minSdkVersion` to 16.  This is the minimum Android version to communicate over TLSv1.2, which is required to support [a Payment Card Industry (PCI) Council mandate](http://blog.pcisecuritystandards.org/migrating-from-ssl-and-early-tls). All organizations that handle credit card information are required to comply with this standard. As part of this obligation, [PayPal is updating its services](https://github.com/paypal/tls-update) to require TLSv1.2 for all HTTPS connections. To override the minSdkVersion, please see [the readme](https://github.com/paypal/PayPal-Android-SDK/blob/master/README.md#override-minsdkversion).
* Android: Update okhttp dependency to 3.2.0.
* Android: Fixes issue related to non-ascii characters in user agent [#271](https://github.com/paypal/PayPal-Android-SDK/issues/271).

3.1.23
------
* Android: Update okhttp dependency to 3.1.2.
* Android: Really fixes issue related to okhttp 3.1.2 [#258](https://github.com/paypal/PayPal-Android-SDK/issues/258).
* Andriod: added bnCode value to payment call.

3.1.22
------
* iOS : Update SDK to [2.13.1](https://github.com/paypal/PayPal-iOS-SDK/releases/tag/2.13.1).
* iOS : Update card.io dependency to [5.3.1](https://github.com/card-io/card.io-iOS-SDK/releases/tag/5.3.1).
* Android: Fix issue preventing the SDK from app-switching to newer versions of the PayPal App.

3.1.21
------
* iOS : Update SDK to [2.13.0](https://github.com/paypal/PayPal-iOS-SDK/releases/tag/2.13.0).
* Android : Fix sandbox pinning issue [#228](https://github.com/paypal/PayPal-Android-SDK/issues/228).
* Android : Clean up manifest permissions [#233](https://github.com/paypal/PayPal-Android-SDK/issues/233).
* Android : Update okhttp dependency to 3.0.1.
* Android : Update card.io to 5.3.0.

3.1.20
------
* Update Android SDK to [2.12.4](https://github.com/paypal/PayPal-Android-SDK/releases/tag/2.12.4).

3.1.19
------
* Update iOS SDK to [2.12.7](https://github.com/paypal/PayPal-iOS-SDK/releases/tag/2.12.7).
