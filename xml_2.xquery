xquery version "3.1";

(: Listázzuk ki azoknak az apiknak a nevét, vezióját, élesítés dátumát és elérhetőségeit (contact),
    amelyeknek van legalább 1 elérhetősége(contacton belüli title, email, url) 
    és 2017 második negyedévében lettek élesítve :)   
import schema default element namespace "" at "xml_2.xsd";

let $json := fn:json-doc("./list.json")?*

return validate {
    document {
        <APIK apiNums="{fn:count($json[xs:dateTime(?added) gt xs:dateTime("2017-04-01T00:00:00") and xs:dateTime(?added) lt xs:dateTime("2017-07-01T00:00:00") ])}">
            {
                 for $api in $json[xs:dateTime(?added) gt xs:dateTime("2017-04-01T00:00:00") and xs:dateTime(?added) lt xs:dateTime("2017-07-01T00:00:00") ]
                      let $added := $api?added
                      let $name := $api?versions?*?info?contact?name
                      let $email := $api?versions?*?info?contact?email
                      let $url := $api?versions?*?info?contact?url
                      where count($api?versions?*?info?contact) gt 0
                      order by $api?added ascending
                      return 
                          <API name="{$api?versions?*?info?x-providerName}">
                            {           
                                <VERSIONS versionNum="{count($api?versions)}">
                                    
                                    <VERSION version="{$api?preferred}">
                                        {
                                          <ADDED releaseDate="{$api?versions?*?added}">
                                                    <INFO>
                                                        <CONTACT>
                                                              <TITLE title="{$name}" />
                                                              <EMAIL email="{$email}" />
                                                              <URL url="{$url}" />                                            
                                                        </CONTACT>                                              
                                                    </INFO> 
                                          </ADDED>
                                          }
                                    </VERSION>
                                </VERSIONS>
                            
                            }
                          </API>
            }
        </APIK>
    }   
}