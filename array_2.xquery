declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

(: Állítsunk elő egy olyan map-et melyben a 2019, 2020 és 2021-ben kiadott apik számát láthatjuk :)

declare option output:method "json";
declare option output:indent "yes";

let $json := fn:json-doc("./list.json")?*
let $key := map{2019: "", 2020: "", 2021: ""}
let $keys := map:keys($key) => distinct-values()
return
    map:merge(for $k in $keys
    return
        map:entry($k, concat(xs:string(count($json[fn:year-from-dateTime(xs:dateTime(?added)) eq $k]?added)), " darab"))) => serialize(map {'method': 'json'})