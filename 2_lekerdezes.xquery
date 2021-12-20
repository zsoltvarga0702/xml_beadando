declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";


let $json := fn:json-doc("./list.json")?*
for $adat in $json
    where $adat?versions?*?info?contact?email eq "contact@1forge.com"

return
    fn:concat(
    days-from-duration(
    current-dateTime() - xs:dateTime($adat?added)), " napja")