xquery version "3.1";

(: Listázzuk ki azoknak az apiknak a szolgáltatásainak a háttérszínét és háttér url-jét,
    amelyek az élesítéstől fogva voltak már frissítve és van háttérszínük
:)   
import schema default element namespace "" at "xml_3.xsd";

let $json := fn:json-doc("./list.json")?*

return validate {
    document {
        <APIK>
            {
                 for $api in $json
                      let $updated := $api?versions?*?updated
                      let $backgroundColor := $api?versions?*?info?x-logo?backgroundColor
                      let $url := $api?versions?*?info?x-logo?url
                      where fn:exists($api?versions?*?updated) 
                                and fn:exists($api?versions?*?info?x-logo?backgroundColor) 
                                and fn:exists($api?versions?*?info?x-serviceName)
                      order by $api?versions?*?info?x-providerName ascending
                      return 
                          <API name="{concat(concat($api?versions?*?info?x-providerName, ":"),$api?versions?*?info?x-serviceName)}">  
                                    <VERSION updated="{$updated} ">
                                        <INFO>
                                               <X-LOGO >
                                                       <BACKGROUND-COLOR backgroundColor="{$backgroundColor}" />
                                                       <URL url="{$url}" />                                          
                                               </X-LOGO>                                              
                                        </INFO>     
                                    </VERSION>                        
                          </API>
            }
        </APIK> 
    }
}