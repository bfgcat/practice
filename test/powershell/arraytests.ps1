#
#
#


$myguid = [guid]::NewGuid()
#$myguid.getType()
"New GUID: $myguid"

$x = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

$x

""
$x[0]
$x[4]
$x[-2]

""
$x[1,3,5]

""
$x[3..5]

""
11..25

"y"
$y = 1..10
$y

""
"z"

$z = @()
$z

$z = $z + 1
$z = $z + 2
$z = $z + 5

$z
$z.getType()
""
"B"
$b = "Red", "White", "Blue"
$b

""
"C"
$c = "Green","Yellow","Orange"
$c

""
"D"
$d = $a + $c
$d
$d.gettype()
