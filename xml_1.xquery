xquery version "3.1";

(: Listázzuk ki azoknak az apiknak a címét élesítés dátumát és verziószámát
    amelyek 2021 November 1-én vagy után jelentek meg
    és rendezzük be dátum szerint növekvő sorrenbe :)
    
import schema default element namespace "" at "xml_1.xsd";

let $json := fn:json-doc("./list.json")?*

return validate {
    document {
        <APIK apiNums="{fn:count($json?added)}">
            {
                 for $api in $json[xs:dateTime(?added) gt xs:dateTime("2021-11-01T00:00:00") ]
                      let $added := $api?added
                      order by $api?added ascending
                      return <API title="{$api?versions?*?info?title}" releaseDate="{$added}" versionNumber="{$api?preferred}"/>
            }
        </APIK>
    }
}