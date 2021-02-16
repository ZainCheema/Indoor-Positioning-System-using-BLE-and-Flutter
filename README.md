# Flutter Indoor Positioning System using Bluetooth Low Energy, Weighted Trilateration and Kalman Filtering

Full paper can be accessed here: https://drive.google.com/file/d/14fMYsq71ounnCWpsKoMkN19icRZEln76/view?usp=sharing

This is a mobile application for Android and iOS that makes use of phones as both a Bluetooth beacons and receivers.

The goal of this application is to provide an accurate distance approximation of a phone with an unknown location in relation to phones configured with a known location expressed in cartesian coordinate (x, y) meters.

The application uses a Log Distance Path Model to calculate distance from one phone to another using RSSI, which is smoothed using a configured Kalman Filter in one dimension.

Position is calculated using both Weighted Trilateration and Min Max methods, with the Min Max method being deemed the more accurate of the two.
