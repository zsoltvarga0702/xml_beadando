xquery version "3.1";

(: Adjunk vissza egy tömböt, melyben azoknak az apinak a neve és szolgáltatás neve (ha van ilyen)
    található, melyeknek a leírása hosszabb mint 15.000 karakter :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "json";
declare option output:indent "yes";

let $json := fn:json-doc("./list.json")?*

let $apiNames := array {
    for $api in $json
        let $name := $api?versions?*?info?x-providerName
        order by $name ascending
        where string-length($api?versions?*?info?description) gt 15000
        
    return if(string-length($api?versions?*?info?x-serviceName) gt 0)
            then fn:concat($name, $api?versions?*?info?x-serviceName)
            else $name
}
return $apiNames