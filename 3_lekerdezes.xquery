declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(:
    Adjuk vissza a nevét és a leírás hosszát annak az apinak, amelynek a leghosszabb a leírása
:)
declare option output:method "json";
declare option output:indent "yes";

let $json := fn:json-doc("./list.json")?*

let $length_array := array {
    for $api in $json
        return fn:string-length($api?versions?*?info?description)
}
let $max := fn:max($length_array)
return fn:concat(fn:concat($json?versions?*?info[$max eq fn:string-length(?description)]?x-providerName , ": "), $max)