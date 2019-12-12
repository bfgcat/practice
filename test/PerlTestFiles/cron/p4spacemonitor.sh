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
perforce02
======================================================
Filesystem            Size  Used Avail Use% Mounted on
`ssh root@perforce02 df -h | grep -E -i -w '/perforce$|/perforce/ac/src|/perforce/core/src|/perforce/cos/src|/perforce/sdk/src|/perforce/legal/src|/perforce/finance/src'`

perforce05
======================================================
Filesystem            Size  Used Avail Use% Mounted on
`ssh root@perforce05 df -h | grep -E -i -w '/perforce$|/perforce/hendrix'`
</body>
</html>
"
) | /usr/sbin/sendmail -t -f perforce@turbine.com
