//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audiotags/audiotags_plugin.h>
#include <simple_audio/simple_audio_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) audiotags_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AudiotagsPlugin");
  audiotags_plugin_register_with_registrar(audiotags_registrar);
  g_autoptr(FlPluginRegistrar) simple_audio_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SimpleAudioPlugin");
  simple_audio_plugin_register_with_registrar(simple_audio_registrar);
}
