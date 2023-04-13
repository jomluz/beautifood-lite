# Beautifood Lite Client

A stripped lite version of the original beautifood app for PoC with a decentralised backend.

## Getting Started

### Prerequisite
Flutter Installed and the command `flutter doctor` completes without error. Use the master branch. You can change by `flutter channel master`.

### Build Steps
1. Clone the repo
2. run `flutter pub get` in `client` directory
3. `flutter run` or `flutter run -d <your-preferred-device>` to run with your preferred device. You would also want to fix to a permanent port with `flutter run -d chrome --web-port 5001`
   1. You can see list of devices you can use through `flutter devices`.



## Docker 
Use the dockerfile provided to build a web deployment container. Nginx is used as the http server.