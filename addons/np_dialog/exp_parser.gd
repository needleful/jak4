tool
extends Object
class_name NPDialogExpParser

const special_functions := {
	"+stat" : "Global.add_stat",
	"stat?" : "Global.stat",
	"$" : "set_var",
	"++": "inc_var"
}

var r_special_replace := RegEx.new()

func _init():
	r_special_replace.compile("\\$([a-zA-Z_0-9]+)")

func extract(line: String) -> Dictionary:
	if !('[' in line or '{' in line):
		return {
			"line":line,
			"conditions":[]
		}
	var exp_strings := []
	var interp_strings := []
	
	var interp_expression := false
	var l := line
	var line_no_expressions := ""
	while l != "":
		match l[0]:
			'[':
				var end := l.find(']')
				if end < 0:
					return {"_parse_error": "missing ending `}` for "+l}
				var ex := sq_convert(l.substr(1, end-1))
				if interp_expression:
					line_no_expressions += "#{%s}" % ex
				else:
					exp_strings.append(ex)
				l = l.substr(end+1)
				interp_expression = false
			'{':
				var end := l.find('}')
				if end < 0:
					return {"_parse_error": "missing ending `}` for "+l}
				var ex := replace_vars(l.substr(1, end-1))
				if interp_expression:
					line_no_expressions += "#{%s}" % ex
				else:
					exp_strings.append(ex)
				l = l.substr(end+1)
				interp_expression = false
			'#':
				interp_expression = true
				l = l.substr(1)
			_:
				if interp_expression:
					print('-->', l[0])
				interp_expression = false
				line_no_expressions += l[0]
				l = l.substr(1)
	var res := {
		"line": line_no_expressions,
		"conditions": exp_strings
	}
	return res

func sq_convert(text: String) -> String:
	var func_str := ""
	var args_str := ""
	var idx:int = text.find(":")
	if idx >= 0:
		func_str = text.substr(0, idx)
		args_str = text.substr(idx+1)
	else:
		func_str = text

	var slot := ""
	for f in func_str.split(" ", false):
		if f in special_functions:
			f = special_functions[f]
		elif f.begins_with("$"):
			f = replace_vars(f)
		if slot != "" and slot != "!":
			slot += "."
		slot += f.strip_edges()

	var message := "("
	var args := 0
	if args_str != "":
		for a in args_str.split("|"):
			if args:
				message += ", "
				
			if a.begins_with("+"):
				a = a.substr(1)
				message += "["
				var items := 0
				for s2 in a.split(" ", false):
					s2 = sq_argument(s2)
					if s2 == "":
						continue
					if items:
						message += ","
					message += s2
					items += 1
				message += "]"
			else:
				message += sq_argument(a)
			args += 1
	message += ")"
	return slot + message

func sq_argument(arg: String) -> String:
	var s := arg.strip_edges()
	if s.begins_with("#"):
		return s.substr(1)
	var replaced = replace_vars(s)
	if replaced != s:
		return replaced
	else:
		return '"' + s.replace('"', '\\"') + '"'

func replace_vars(s: String) -> String:
	var replaced := s
	for m in r_special_replace.search_all(s):
		var m1:String = m.get_string()
		var m2:String = "variables[\"%s\"]" % m.get_string(1)
		replaced = replaced.replace(m1, m2)
	return replaced
