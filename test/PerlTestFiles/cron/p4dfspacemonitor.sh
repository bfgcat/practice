(
echo "Subject: Perforce Filesystem Utilization";
echo "From: perforce@turbine.com";
echo "To: releaseengineering@turbine.com";
echo "MIME-Version: 1.0";
echo "Content-Type: text/html";
echo "Content-Disposition: inline";
echo "
<html>
<body>
<pre>
perforce-turbine LOTRO
==============================================================================================
Filesystem                       Size  Used Avail Use% Mounted on
`df -h | grep -i perforce | grep -i lotro | sed 's/             / /g'`

perforce-turbine DDO
==============================================================================================
Filesystem                       Size  Used Avail Use% Mounted on
`df -h | grep -i perforce | grep -i ddo | sed 's/             / /g'`

perforce-turbine HENDRIX
==============================================================================================
Filesystem                       Size  Used Avail Use% Mounted on
`df -h | grep -i perforce | grep -i \/turbine | sed 's/             / /g'`
</body>
</html>
"
) | /usr/sbin/sendmail -t -f perforce@turbine.com