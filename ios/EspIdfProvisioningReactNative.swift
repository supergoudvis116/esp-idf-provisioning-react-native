import Foundation
import ESPProvision

@objc(EspIdfProvisioningReactNative)
class EspIdfProvisioningReactNative: NSObject, ESPDeviceConnectionDelegate {
    private var provisionManager: ESPProvisionManager!
    private var listDevicesByUuid: [String: ESPDevice] = [:]
    private var espDevice: ESPDevice!
    private var deviceConnected = false
    private var proofOfPossession = ""
    private var username = ""

    @objc
    func create() -> Void {
        self.provisionManager = ESPProvisionManager.shared
        print("Create method")
    }
    
    @objc(scanBleDevices:resolve:reject:)
    func scanBleDevices(
        prefix: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        print("Scan started")
        ESPProvisionManager.shared.searchESPDevices(
            devicePrefix:prefix,
            transport:.ble,
            security:.secure
        ) { deviceList, error in
            if let error = error {
                reject("SCAN_ERROR", "Error when scan devices", error)
            } else {
                let response: NSMutableArray = []
                if let list = deviceList {
                    for device in list {
                        print("device: \(device.name)")
                        self.listDevicesByUuid[device.name] = device
                        response.add([
                            "deviceName": device.name,
                            "serviceUuid": device.name
                        ])
                    }
                }
                resolve(response)
            }
        }
    }
    
    @objc(connectToBLEDevice:resolve:reject:)
    func connectToBLEDevice(
        name: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        if let device = listDevicesByUuid[name] {
            device.disconnect()
            
            device.connect(delegate: self) { status in
                switch status {
                    case .connected:
                        print("Device Connected Event Received")
                        self.espDevice = device
                        self.deviceConnected = true
                        let response: NSDictionary = ["success": true]
                        resolve(response)
                        break
                    case let .failedToConnect(error):
                        self.espDevice = nil
                        self.deviceConnected = false
                        print("error: \(error.localizedDescription)")
                        reject("Connection error", "Connection error", error)
                        break
                    default:
                        self.espDevice = nil
                        self.deviceConnected = false
                        print("Device disconnected")
                        reject("Device disconnected", "Please check the connection", NSError())
                        break
                }
            }
        }
        else {
            reject("Device don't exists", "Please scan BLE devices first", NSError(domain: "", code: 200, userInfo: nil))
        }
    }
    
    @objc
    func disconnectBLEDevice(
        _ resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        if (self.deviceConnected) {
            self.espDevice.disconnect()
        }
        resolve(0)
    }
    
    func getProofOfPossesion(forDevice: ESPDevice, completionHandler: @escaping (String) -> Void) {
        completionHandler(self.proofOfPossession)
    }
  
    func getUsername(forDevice: ESPDevice, completionHandler: @escaping (String?) -> Void) {
        completionHandler(self.username)
    }
  
    @objc
    func getProofOfPossession(
        _ resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        resolve(self.proofOfPossession)
    }
    
    @objc
    func setProofOfPossession(
        _ proof: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        self.proofOfPossession = proof
        resolve(0)
    }
    
    @objc(scanNetworks:reject:)
    func scanNetworks(
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        if (!self.deviceConnected) {
            print("No device connected")
            reject("No device connected", "Please connect a device first", NSError(domain: "", code: 200, userInfo: nil))
            return
        }
        
        self.espDevice.scanWifiList(completionHandler: {wifiList, error in
            if let error = error {
                reject("Network Scan Error", "WiFi networks scan has failed", error)
            } else if let wifiList = wifiList {
                let response: NSMutableArray = []
                for item in wifiList {
                    response.add([
                        "ssid": item.ssid
                    ])
                }
                resolve(response)
            } else {
                resolve([])
            }
        })
    }
    
    @objc(provisionNetwork:password:resolve:reject:)
    func provisionNetwork(
        ssid: String,
        password: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        self.espDevice.provision(ssid: ssid,
                                 passPhrase: password,
                                 completionHandler: {status in
                                    switch status {
                                        case .configApplied:
                                            print("Wi-Fi credentials successfully applied to the device")
                                            break
                                        case .success:
                                            print("Device is provisioned successfully")
                                            let response: NSDictionary = ["success": true]
                                            resolve(response)
                                            break
                                        case let .failure(error):
                                            print("Provisioning is failed")
                                            reject("Error in provision listener",
                                                        "Provisioning is failed", error);
                                            break
                                    }
                                })
    }
    
    @objc(sendCustomData:customData:resolve:reject:)
    func sendCustomData(
        customEndPoint: String,
        customData: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        self.espDevice.sendData(path: customEndPoint, data: customData.data(using: .utf16)!, completionHandler: {data, error in
            if let error = error {
                print("Custom data provision has failed")
                reject("Custom data provision has failed", "Custom data provision has failed", error)
            }
            let response: NSDictionary = ["success": true, "data": String(describing: data)]
            resolve(response)
        })
    }
    
    @objc(sendCustomDataWithByteData:customData:resolve:reject:)
    func sendCustomDataWithByteData(
        customEndPoint: String,
        customData: Array<String>,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        var output = [UInt8]()
        for char in customData {
            output.append(UInt8(char, radix: 16) ?? 0)
        }
        self.espDevice.sendData(path: customEndPoint, data: Data(output), completionHandler: {data, error in
            if let error = error {
                print("Custom data provision has failed")
                reject("Custom data provision has failed", "Custom data provision has failed", error)
            }
            let response: NSDictionary = ["success": true, "data": String(describing: data)]
            resolve(response)
        })
    }
}
