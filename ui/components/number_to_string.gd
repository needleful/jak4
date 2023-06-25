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

static func say_time(time:float, verbose:=true, say_pm:=false) -> String:
	var pm = false
	var hours := int(floor(time))
	var minutes := int(60.0*(time - hours))
	if hours > 12:
		hours -= 12
		pm = true
	if hours == 0:
		hours = 12
		pm = !pm
	var numeral := ""
	if !verbose:
		numeral = "%2d:%02d" % [hours, minutes]
	else:
		if minutes != 0:
			if minutes == 30:
				numeral = "half past "
			elif minutes == 15:
				numeral = "quarter past "
			elif minutes == 45:
				numeral = "quarter 'til "
				hours = hour_increment(hours)
			elif minutes < 30:
				numeral = verbose_small(minutes) + " past "
			else:
				numeral = verbose_small(60 - minutes) + " 'til "
				hours = hour_increment(hours)
		if hours == 12:
			if pm:
				numeral += "noon"
			else:
				numeral += "midnight"
		else:
			numeral += verbose_small(hours)
	var daytime := ""
	if say_pm:
		daytime = "p.m." if pm else "a.m."
	return numeral + " " + daytime

static func hour_increment(hours):
	hours += 1
	hours = hours % 12
	if hours == 0:
		hours = 12
	return hours
