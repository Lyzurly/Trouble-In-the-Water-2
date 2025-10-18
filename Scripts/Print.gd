## [b]Recommended to be set as a Global Autoload.[/b][br]
## [br]Use [method debug_print] to automatically suppress print output in release builds, while ensuring they appear in debug builds.[br]
## [br]The first argument of [method debug_print] features an optional [b]modifier array[/b]. When passing the first argument of the [param arg1_or_modifier_array] parameter, make it an [Array] containing one of the preset [member FX] modifiers to control the way output messages look and behave.
extends Node

## Modifier effect for use with [method debug_print]. See [method debug_print] for example usage.
enum FX {
	BACKTRACES, ##Captures the calling function's backtraces.
	PUSH_WARNING, ##Pushes the output as a [color=fae345]Warning[/color].
	PUSH_ERROR, ##Pushes the output as an [color=ff786b]Error [/color]. [b] Note:[/b] Does not pause runtime.
	LINE_ONLY, ##Hides all arguments and prints a full blank line instead.
	HIGHLIGHT, ##[color=yellow]Makes print args bright yellow.[/color]
	WARNING, ##[color=#fae345]Has a unique line decoration, and makes print args yellow. [/color] [b] Note:[/b] Does not log a warning.  See [member FX.PUSH_WARNING] instead.
	ERROR, ##[color=#ff786b]Has a unique line decoration, and makes print args red. [/color] [b] Note:[/b] Does not log an error.  See [member FX.PUSH_ERROR] instead.
	INFO, ##[color=#a3a3f5]Has a unique line decoration, and makes the args purple. [/color] [b] Note:[/b] Intended for informational emphasis that is neither urgent (instead, use [member FX.WARNING] or [member FX.ERROR], or their "PUSH" variants, or [member FX.CRITICAL]) nor temporary (for that, use [member FX.HIGHLIGHT]).
	FUNCTION, ## Prefixes the output with the calling function name.
}

enum _PUSH_TYPES {
	WARNING,
	ERROR,
}

var _last_calling_script_name: String = ""

const _LINE_INDENT_1: String = "\t"
const _LINE_INDENT_2: String = "\t\t"

var _line_decoration: String = _LINE_DECORATION
const _LINE_DECORATION: String = "\t⤷ "
const _LINE_DECORATION_INFO: String = " \t🛈: "
const _LINE_DECORATION_FUNCTION: String = "\t\t⤷ "
const _LINE_DECORATION_WARNING: String = " \t⨻: "
const _LINE_DECORATION_ERROR: String = "  \t⮿: "

func _debug_debug_print(...args) -> void:
	var output: PackedStringArray = PackedStringArray()
	
	for arg: Variant in args:
		output.append(str(arg))
		
	var args_output: String = (
		"[color=skyblue]" +
		" ".join(output) +
		"/color]")
	
	print_rich(args_output)

#region func debug_print() + Tooltip
## [param arg1_or_modifier_array]: Pass whatever you want to print first here, or use an [Array]-wrapped [member Print.FX]. (See below for modifier array instructions.)[br]
## [br][param ...args]: Variadic argument accepting as many comma-separated print parameters as you wish.[br]
## [br][br][b]Modifier array[/b] [i](Optional)[/i] — You can pass an [Array] of [member Print.FX] values into [param arg1_or_modifier_array] to enhance debugging output. To do so, start with an array containing one or more [member Print.FX] modifiers to apply enhanced formatting. Otherwise, just pass your first argument normally.[br]
## [br][br][b]Example:[/b][br]
## [br][code]some_script.gd[/code][br]
## [code]                        [/code][br]
## [code]var some_input: int = 41[/code][br]
## [code]                        [/code][br]
## [code]Print.debug_print(some_input, "Invalid")[/code][br]
## —will print... [i][b] [color=#588157] SOME_SCRIPT : [/color][/b] ⤷ 41 Invalid[/i][br]
## [br][code]Print.debug_print([Print.FX.ERROR], some_input, "Invalid")[/code][br]
## —will print... [i][color=red] • SOME_SCRIPT⤷ 41 Invalid[/color][/i][br]
##[br]
func debug_print(
	arg1_or_modifier_array: Variant = [],
	...args) -> void: 
		
#endregion
		
	if not OS.is_debug_build(): 
		return # TODO: rethink this when logging gets implemented? check out builtin logging too
		
	var modifiers: Array = []
	var output: PackedStringArray = PackedStringArray()

	if _does_arg1_have_modifiers(arg1_or_modifier_array):
		modifiers = arg1_or_modifier_array
	else:
		output.append(str(arg1_or_modifier_array))

	for arg: Variant in args:
		output.append(str(arg))

	var backtraces: bool = FX.BACKTRACES in modifiers
	var warning_push: bool = FX.PUSH_WARNING in modifiers
	var error_push: bool = FX.PUSH_ERROR in modifiers
	var line_only: bool = FX.LINE_ONLY in modifiers
	var highlight: bool = FX.HIGHLIGHT in modifiers
	var warning: bool = FX.WARNING in modifiers
	var error: bool = FX.ERROR in modifiers
	var info: bool = FX.INFO in modifiers
	var function: bool = FX.FUNCTION in modifiers

	var print_prefix: String = "\t"
	var print_suffix: String = ""
	
	var output_color: String = ""
	if highlight:
		output_color = "[color=yellow]"
	elif warning:
		output_color = "[color=#fae345]"
	elif error:
		output_color = "[color=#ff786b]"
	elif info:
		output_color = "[color=#a3a3f5]"
	
	if not output_color == "":
		print_prefix = print_prefix.insert(0, output_color)
		print_suffix += "[/color]"
	
	var args_output: String = " ".join(output)
	var args_already_reformatted: bool = false
	
	args_output = _reformat_args(args_output,function)
	args_already_reformatted = true
	
	if backtraces:
		args_output += " " + str(Engine.capture_script_backtraces())

	if line_only or args_output.is_empty():
		print()
		
	else:
		if warning or warning_push:
			_line_decoration = _LINE_DECORATION_WARNING
		elif error or error_push:
			_line_decoration = _LINE_DECORATION_ERROR
		elif info:
			_line_decoration = _LINE_DECORATION_INFO
		else:
			_line_decoration = _LINE_DECORATION
		
		var function_name: String = ""
		
		if function:
			function_name = _get_function_fx()
			if not args_already_reformatted:
				args_output = _reformat_args(args_output,function)
		
		var output_string: String = (
			_line_decoration +
			function_name +
			args_output +
			print_suffix
			)
		
		var calling_script_name: String = _get_caller()

		if warning_push or error_push:
			
			var final_output_string = _add_prefix_and_name(
				output_string,
				print_prefix,
				calling_script_name)
			
			if warning_push:
				_push_debug(_PUSH_TYPES.WARNING, final_output_string)
			elif error_push:
				_push_debug(_PUSH_TYPES.ERROR, final_output_string)
				
		else:
			# This "groups" consecutive prints from the same caller
				# under a singular title
			if not _last_calling_script_name == calling_script_name:
				print_prefix = _convert_prefix_to_title(print_prefix)
				calling_script_name = _convert_name_to_title(calling_script_name)
			else:
				calling_script_name = ""

			var final_output_string = _add_prefix_and_name(
				output_string,
				print_prefix,
				calling_script_name)
				
			print_rich(final_output_string)
			
			_last_calling_script_name = _get_caller()

			
func _get_function_fx() -> String:
	var backtrace_line: String = _get_backtrace_line(4)
	var function_name: String = backtrace_line.get_slice(" ", 1).strip_edges()
	var function_line_to_add: String

	function_line_to_add = (
		"[color=#57b3ff]" + 
		function_name + 
		"[/color]" + 
		"()" + 
		"\n" + 
		_LINE_INDENT_2 +
		_LINE_DECORATION
		)
		
	return function_line_to_add

func _reformat_args(args: String,is_function:bool) -> String:
	var reformatted_args: String = args
	var reformatted_line_decoration: String = _line_decoration
	
	if is_function:
		reformatted_line_decoration = _LINE_DECORATION_FUNCTION
	
	if not args.find("\n\t") == -1:
		reformatted_args = args.replace("\n\t", "\n" + _LINE_INDENT_2 + reformatted_line_decoration)
		
	elif not args.find("\n") == -1:
		reformatted_args = args.replace("\n", "\n" + _LINE_INDENT_1 + reformatted_line_decoration)
	
	return reformatted_args
			
func _add_prefix_and_name(add_to_what: String, prefix_to_add: String, name_to_add: String) -> String:
	var updated_output: String = add_to_what
	updated_output = updated_output.insert(
		0, 
		prefix_to_add +
		name_to_add
		)
	return updated_output

func _push_debug(push_type: _PUSH_TYPES, output_string: String) -> void:
	
	match push_type:
		
		_PUSH_TYPES.ERROR:
			push_error(output_string)
		_PUSH_TYPES.WARNING:
			push_warning(output_string)
	
	# ensures the next non-warn/error output re-adds its calling script name
		# since they check to see if their preceding output has the same name/not
			# warn/errors don't share the same log
				# so therefore shouldn't influence next outputs
	_last_calling_script_name = ""
			
static func _does_arg1_have_modifiers(modifier_arg: Variant) -> bool:
	return modifier_arg is Array and modifier_arg.any(
		func(i):
			return i is int and i in FX.values())

func _get_caller() -> String:
	var caller_line: String = _get_backtrace_line(4)
	# result looks like "[2] _ready (res://Scripts/ettercap.gd:31)

	var isolated_path: String = _isolate_string_between_chars(
		caller_line, "(" ,")"
		)
		# result looks like "res://Scripts/ettercap.gd:31"
		
	if isolated_path:
		# removes line number
		var colons: int = isolated_path.rfind(":")
		if not colons == -1:
			isolated_path = isolated_path.substr(0, colons)
			# result looks like "res://Scripts/ettercap.gd"

		# now get_file can properly explore the extracted path
		return isolated_path.get_file().get_basename().to_upper()

	# Fallback if nothing valid found
	return "???????"
	
func _get_backtrace_line(line:int) -> String:
	var backtrace: String = str(Engine.capture_script_backtraces())
	
	# split will turn every trace_line into an array
	var trace_lines: PackedStringArray = backtrace.split("\n", false)
	
	# Debuggit
	#print(trace_lines)

	if not trace_lines.is_empty():
		#var caller_line: String = trace_lines[trace_lines.size() - 1].strip_edges()
		var caller_line: String = trace_lines[line].strip_edges()
		return caller_line
	return "???????"
	
func _isolate_string_between_chars(full_string: String, beginning_char: String, ending_char: String) -> String:
	var beginning_index: int = full_string.find(beginning_char)
	var ending_index: int = full_string.find(ending_char, beginning_index)

	# confirms parens were found
	if not beginning_index == -1 and not ending_index == -1:
		# then removes them
		var extracted_path: String = full_string.substr(
			beginning_index + 1,
			ending_index - beginning_index- 1)
		return extracted_path
	return ""
	
func _convert_prefix_to_title(prefix_to_change: String) -> String:
	var tab_index: int = prefix_to_change.find("\t")

	# confirm tab_index exists:
	if not tab_index == -1: # yes it exists
		# separate the string into two parts:
			# 1) text left of the tab
			# 2) and text to the right of it
		var string_to_left_of_tab: String = prefix_to_change.substr(0, tab_index)
		var string_to_right_of_tab: String = prefix_to_change.substr(tab_index + 1)
		
		# recombine the separated parts as the new print_prefix
		prefix_to_change = string_to_left_of_tab + string_to_right_of_tab
	
	var changed_prefix: String = prefix_to_change.insert(0, "\n")
	
	return changed_prefix

func _convert_name_to_title(name_to_change: String) -> String:
	var title_prefix: String = "[b][color=" + _assign_color_to_string(name_to_change) + "]"
	var title_suffix: String = ":" + "[/color][/b]\n\t"
	
	var changed_name: String = " ".join([title_prefix,name_to_change,title_suffix])
	
	return changed_name
	
func _assign_color_to_string(string_to_interpret: String) -> String:
	var string_derived_color_hash: int = 0
	var hashCode_spread_factor: int = 524287
	var integer_overflow_guard: int = 31
	
	for character: int in string_to_interpret.length():
		string_derived_color_hash = (
			string_derived_color_hash
			* hashCode_spread_factor
			+ string_to_interpret.unicode_at(character)) % (1 << integer_overflow_guard)
			# 1 << is shifting some bits to the left or something,
				# to help avoid ugly unusable integers I guess...
					# unicode_at(character) provides a specific, official value based on the string's characters
						# and the spread factor:
							# considerably reduces the likelihood that different orders of characters yields a non-unique value

	var hue: float = float(string_derived_color_hash % 360) / 360.0
	var saturation: float = 0.45
	var lightness: float = 0.85

	return "#" + Color.from_hsv(hue, saturation, lightness).to_html(false)
