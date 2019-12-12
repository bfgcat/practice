# UseXmlExample from 
# http://www.tomsitpro.com/articles/powershell-read-xml-files,2-895.html

[xml]$XmlDocument = Get-Content -Path \test\Cars.xml

[string]$make

FOREACH ($car in $XmlDocument.cars.car)
{
    $make = $car.make
    "Make: $make"
    $seats = $car.seats
    "seats: $seats"
}