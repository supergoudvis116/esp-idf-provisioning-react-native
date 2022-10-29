# esp-idf-provisioning-react-native
ESP IDF Provisioning for React Native
## Installation

```sh
npm install @digitalfortress-dev/esp-idf-provisioning-react-native
```

## Permissions

The permissions needed for Android:
```
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-feature android:name="android.hardware.bluetooth_le" android:required="true"/>
```

## Usage

```js
import EspIdfProvisioningReactNative from '@digitalfortress-dev/esp-idf-provisioning-react-native';

...

EspIdfProvisioningReactNative.create();
```

## Example app

[Example app here](https://github.com/digitalfortress-dev/esp-idf-provisioning-react-native/tree/master/example)

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
