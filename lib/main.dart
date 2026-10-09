import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'app.dart';
import 'data/app_store.dart';
import 'data/local_storage.dart';
import 'data/supabase_config.dart';
import 'data/supabase_store.dart';
import 'state/app_state.dart';

Future<void> main() async {
  // device_preview 3.x installs its own WidgetsBinding, so it must be
  // enabled before anything else touches the binding (Hive and Supabase included).
  // It is active in debug/profile builds (`flutter run -d web-server` /
  // `-d chrome`) and switches itself off in release builds.
  DevicePreview.enable();

  final AppStore storage;
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
    storage = SupabaseStore(Supabase.instance.client);
  } else {
    // No keys passed with --dart-define: run fully offline on Hive.
    final local = LocalStorage();
    await local.init();
    storage = local;
  }
  final state = AppState(storage);
  await state.load();

  // Start in a phone frame so the browser build looks like the mockup.
  // A device chosen later in the DevTools "device_preview" tab is kept
  // across hot restarts because we only apply this when nothing is set.
  final preview = DevicePreview.maybeController;
  if (preview != null && preview.simulation == null) {
    await preview.applyPreset(DevicePresets.iPhone16);
  }

  runApp(PeraFolioApp(state: state));
}
