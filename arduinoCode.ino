#include <ArduinoBLE.h>

// Include the required Arduino libraries:
#include <OneWire.h>
#include <DallasTemperature.h>

// Define to which pin of the Arduino the 1-Wire bus is connected:
#define ONE_WIRE_BUS 11

// Create a new instance of the oneWire class to communicate with any OneWire device:
OneWire oneWire(ONE_WIRE_BUS);

// Pass the oneWire reference to DallasTemperature library:
DallasTemperature sensors(&oneWire);



// #include <Arduino_HTS221.h>
const int UPDATE_FREQUENCY = 2000;
long previousMillis = 0;

  
BLEService tempService("181A"); // create service
// create characteristic and allow remote device to read and write
BLEIntCharacteristic tempCharacteristic("2A6E",  BLERead | BLENotify);
// create characteristic and allow remote device to get notifications and read the value


void setup() {
  Serial.begin(9600);

  // Start up the library:
  sensors.begin();

  // begin initialization
//  if (!HTS.begin()) {
//    Serial.println("Failed to initialize humidity temperature sensor!");
    //while (1);
  //}

  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }

  // set the local name peripheral advertises
  BLE.setLocalName("Nano33BLESENSE");
  // set the UUID for the service this peripheral advertises:
  BLE.setAdvertisedService(tempService);

  // add the characteristics to the service
  tempService.addCharacteristic(tempCharacteristic);

  // add the service
  BLE.addService(tempService);

  tempCharacteristic.writeValue(0);
  // start advertising
  BLE.advertise();

  Serial.println("Bluetooth device active, waiting for connections...");
}

void loop() {

  BLEDevice central = BLE.central();  // Wait for a BLE central to connect

  // If central is connected to peripheral
  if (central) {
    Serial.println("Central connected");

    while (central.connected()) {
      long currentMillis = millis();
      // Check temperature & humidity with UPDATE_FREQUENCY
      if (currentMillis - previousMillis >= UPDATE_FREQUENCY) {
        previousMillis = currentMillis;

        // Send the command for all devices on the bus to perform a temperature conversion:
        sensors.requestTemperatures();
        // Fetch the temperature in degrees Celsius for device index:
        float tempC = sensors.getTempCByIndex(0); // the index 0 refers to the first device


  // Print the temperature in Celsius in the Serial Monitor:
  Serial.print("Temperature: ");
  Serial.print(tempC);
  Serial.print(" \xC2\xB0"); // shows degree symbol
  Serial.print("C  |  ");


//        int temperature = (int) HTS.readTemperature();
        tempCharacteristic.writeValue(tempC);
      }
    }
    Serial.println("Central disconnected");
  }

}
