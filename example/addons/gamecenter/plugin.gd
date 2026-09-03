@tool
extends EditorPlugin

var ios_export_plugin: IosExportPlugin


func _enter_tree() -> void:
	ios_export_plugin = IosExportPlugin.new()
	add_export_plugin(ios_export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(ios_export_plugin)
	ios_export_plugin = null


class IosExportPlugin extends EditorExportPlugin:
	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformIOS


	func _get_name() -> String:
		return "GameCenterExport"


	func _export_begin(
		_features: PackedStringArray,
		_is_debug: bool,
		_path: String,
		_flags: int,
	) -> void:
		if _supports_platform(get_export_platform()):
			add_apple_embedded_platform_framework("GameKit.framework")
