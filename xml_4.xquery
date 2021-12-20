xquery version "3.1";

(: Listázzuk ki azoknak az apiknak a címét és leírását, amely leírásában vagy címében megtalálható
    az "api" szó és a leírás hossza kevesebb mint 500 karakter
:)  
    
import schema default element namespace "" at "xml_4.xsd";

let $json := fn:json-doc("./list.json")?*

return validate { 
    document {
        <APIK>
            {
                 for $api in $json
                      let $added := $api?added
                      let $name := $api?versions?*?info?contact?name
                      let $email := $api?versions?*?info?contact?email
                      let $url := $api?versions?*?info?contact?url
                      where contains($api?versions?*?info?x-providerName, "api") and contains($api?versions?*?info?description, "api")
                            and string-length($api?versions?*?info?description) lt 500
                      order by $api?versions?*?info?x-providerName ascending
                      return 
                          <API name="{$api?versions?*?info?x-providerName}">
                            {           
                                <VERSIONS>
                                    
                                    <VERSION version="{$api?preferred}">
                                          <TITLE title="{$api?versions?*?info?title}"/>
                                          <DESCRIPTION description="{$api?versions?*?info?description}"/>
                                    </VERSION>
                                </VERSIONS>
                            
                            }
                          </API>
            }
        </APIK>
    } 
}