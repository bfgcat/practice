#
#
#

# simple for loop
for ( $i=1;$i -lt 6; $i++)
{
    "line number: $i"
}

""

# creates a list of fixed length
$b = @("one", "two", "three")
$b

for ( $i=0; $i -lt $b.length; $i++)
{
    "element:" + $b[$i]
}

""
foreach ($element in $b)
{
    "element:" + $element
}

""
"create new empty array"
$a = [System.Collections.ArrayList]@()

"a: " + $a
$a.gettype()


""
$a.Add("red") 
$a.Add("yellow") 
$a.Add("orange") 
$a.Add("green") 
$a.Add("blue") 
$a.Add("purple")

$a
""

"remove element yellow"
$a.Remove("yellow")
$a

""

"a: " + $a

""
"HASHES"
""
$states = @{}
$states.getType()


$states.Add("Alaska", "Fairbanks")
$states.Add("California", "Sacramento")
$states.Add("Washington", "Olympia")
$states.Add("Oregon", "Salem")

$states

$states.Remove("Alaska")
"============================"
$states


$states.Add("Alaska", "Fairbanks")
$states

"change alasks to Juneau"
$states.Set_Item("Alaska", "Juneau")
$states


"============================"

$capital = $states.get_item("Oregon")
$capital
""

"testing for a key"
$states.ContainsKey("Oregon")

""
"sort hash table entries by name"
$states.GetEnumerator() | Sort-Object Name| select-object -property name
$states.GetEnumerator() | select-object -property name
""
# "sort hash table entries by value"
# $states.GetEnumerator() | Sort-Object Value 

"============================"
