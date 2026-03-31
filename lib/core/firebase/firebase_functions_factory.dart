import 'package:cloud_functions/cloud_functions.dart';

/// Set `--dart-define=CLOUD_FUNCTIONS_REGION=europe-west1` (or your deploy region)
/// if callables are not in the default `us-central1`.
const String kCloudFunctionsRegion = String.fromEnvironment('CLOUD_FUNCTIONS_REGION');

FirebaseFunctions createFirebaseFunctions() {
  if (kCloudFunctionsRegion.isEmpty) {
    return FirebaseFunctions.instance;
  }
  return FirebaseFunctions.instanceFor(region: kCloudFunctionsRegion);
}
