extends Object
class_name NumberToString

const ones = [
	"zero",
	"one",
	"two",
	"three",
	"four",
	"five",
	"six",
	"seven",
	"eight",
	"nine"
]

const teens = [
	'ten',
	'eleven',
	'twelve',
	'thirteen',
	'fourteen',
	'fifteen',
	'sixteen',
	'seventeen',
	'eighteen',
	'nineteen',
]

const tens = [
	"_",
	"_",
	"twenty",
	"thirty",
	"forty",
	"fifty",
	"sixty",
	"seventy",
	"eighty",
	"ninety"
]

const powers = {
	2: "hundred",
	3: "thousand",
	6: "million",
	12: "billion",
	18: "trillion",
	24: "quadrillion",
	30: "quintillion",
	36: "sextillion",
	42: "septillion",
	48: "octillion",
	54: "nonillion",
	60: "decillion",
	66: "undecillion",
	72: "duodecillion",
	78: "tredecillion",
	84: "quattourdecillion",
	90: "quindecillion",
	96: "sexdecillion",
	102: "septdecillion",
	108: "octodecillion",
	114: "novemdecillion",
	120: "vigintillion",
	600: "centillion"
}

static func sorted_powers() -> Array:
	var p = powers.keys()
	p.sort()
	p.invert()
	return p

static func verbose_small(v: int) -> String:
	# warning-ignore:narrowing_conversion
	var a:int = abs(v)
	if a < 10:
		return ones[a]
	if a < 20:
		return teens[a-10]
	if a < 100:
		# warning-ignore:integer_division
		var t := (a/10)
		var o := a - t*10
		if o == 0:
			return tens[t]
		else:
			return tens[t] + "-" + verbose_small(o)
	if a < 2000 and a % 1000 != 0:
		# warning-ignore:integer_division
		var h := (a/100)
		var t := a - h*100
		return verbose_small(h) + " hundred " + verbose_small(t)
	if a < 1000000:
		# warning-ignore:integer_division
		var th := a/1000
		var h := a - th*1000
		# warning-ignore:integer_division
		return verbose_small(a/1000) + " thousand " + verbose_small(h) 
	return "<?>"

static func verbose(v: float) -> String:
	if v == INF or v == -INF:
		return "infinity" if v > 0 else "negative infinity"
	if is_nan(v):
		return "some number of"
	var res := ""
	var num_string := "%.0f" % abs(v)
	for e in sorted_powers():
		if e < 6:
			if res != "":
				res += ", "
			res += verbose_small(int(num_string))
			break
		if num_string.length() > e:
			var length:int = num_string.length() - e
			var high := int(num_string.substr(0, length))
			num_string = num_string.substr(length)
			if res != "":
				res += ", "
			res += verbose_small(high) + " " + powers[e]
	if v < 0:
		res = "negative " + res
	return res
