declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
(:
    Visszaadni hogy tényleg annyi api van 2337
:)
declare option output:method "json";
declare option output:indent "yes";


let $json := fn:json-doc("./list.json")?*

return
    fn:count($json)