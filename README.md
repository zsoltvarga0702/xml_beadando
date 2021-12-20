# xml_beadando
Ez a projekt az XML technológiák egyetemi kurzusa miatt jött létre,
mely xQuery lekérdezéseket tartalmaz.
A használt API itt érhető el: https://apis.guru/

#### XQuery lekérdezések

**1. lekérdezés:**
Visszaadni hogy tényleg 2337 api van.

```xquery
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";


let $json := fn:json-doc("./list.json")?*

return
    fn:count($json)
```

**Eredmény:**
```json
2337
```

**2. lekérdezés:**
Mennyi ideje van kint élesen az az api aminek a contact email címe “contact@1forge.com”?

```xquery
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
```

**Eredmény:**
```json
"1665 napja"
```

**3. lekérdezés:**
Adjuk vissza a nevét és a leírás hosszát annak az apinak, amelynek a leghosszabb a leírása

```xquery
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
```

**Eredmény:**
```json
"viator.com: 252226"
```

**3. lekérdezés:**
Adjunk vissza egy tömböt, melyben azoknak az apinak a neve és szolgáltatás neve (ha van ilyen)
    található, melyeknek a leírása hosszabb mint 15.000 karakter
    
```xquery
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
```

**Eredmény:**
```json
[
        "apideck.comlead",
        "apideck.comhris",
        "apideck.comats",
        "apideck.comaccounting",
        "apideck.comcustomer-support",
        "apideck.compos",
        "apideck.comcrm",
        "apideck.comconnector",
        "apideck.comsms",
        "apideck.comfile-storage",
        "biapi.pro",
        "bunq.com",
        "digitalocean.com",
        "drchrono.com",
        "linode.com",
        "loket.nl",
        "lumminary.com",
        "nbg.gr",
        "phantauth.net",
        "probely.com",
        "snyk.io",
        "tisane.ai",
        "viator.com",
        "zuora.com"
    ]
```

**5. lekérdezés:**
Állítsunk elő egy olyan map-et melyben a 2019, 2020 és 2021-ben kiadott apik számát láthatjuk

```xquery
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
```

**Eredmény:**
```json
"{\"2019\":\"192 darab\",\"2020\":\"571 darab\",\"2021\":\"627 darab\"}"
```

**6. lekérdezés:**
Listázzuk ki azoknak az apiknak a címét élesítés dátumát és verziószámát
    amelyek 2021 November 1-én vagy után jelentek meg
    és rendezzük be dátum szerint növekvő sorrenbe
```xquery
xquery version "3.1";
    
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
```

**Eredmény:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<APIK apiNums="2337">
    <API title="hris"
         releaseDate="2021-11-01T23:17:19.576Z"
         versionNumber="8.10.0"/>
    <API title="Adyen Payout API"
         releaseDate="2021-11-01T23:17:40.475Z"
         versionNumber="68"/>
    <API title="Adyen Recurring API"
         releaseDate="2021-11-01T23:17:40.475Z"
         versionNumber="68"/>
    <API title="Adyen Payment API"
         releaseDate="2021-11-01T23:17:40.475Z"
         versionNumber="68"/>
    <API title="Adyen Checkout API"
         releaseDate="2021-11-01T23:17:40.475Z"
         versionNumber="68"/>
    <API title="Balance Platform Transfers API"
         releaseDate="2021-11-01T23:17:40.475Z"
         versionNumber="2"/>
    <API title="Google Cloud Support API"
         releaseDate="2021-11-03T23:09:20.550Z"
         versionNumber="v2beta"/>
    <API title="Connector API"
         releaseDate="2021-11-03T23:19:04.115Z"
         versionNumber="8.10.0"/>
    <API title="Cloud Firestore API"
         releaseDate="2021-11-04T23:09:19.244Z"
         versionNumber="v1beta2"/>
    <API title="Datastream API"
         releaseDate="2021-11-15T23:09:33.136Z"
         versionNumber="v1"/>
    <API title="Google Cloud Deploy API"
         releaseDate="2021-11-16T23:09:55.962Z"
         versionNumber="v1"/>
    <API title="Retail API"
         releaseDate="2021-11-17T23:09:31.794Z"
         versionNumber="v2alpha"/>
    <API title="pos"
         releaseDate="2021-12-06T23:16:42.731Z"
         versionNumber="8.10.0"/>
    <API title="Transcoder API"
         releaseDate="2021-12-13T23:09:42.532Z"
         versionNumber="v1"/>
    <API title="Cloud Speech-to-Text API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v2beta1"/>
    <API title="Amazon OpenSearch Service"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="2021-01-01"/>
    <API title="Google Cloud Data Catalog API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Composer API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="DoubleClick Bid Manager API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1"/>
    <API title="Security Token Service API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Recommender API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="YouTube Analytics API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1"/>
    <API title="Cloud Trace API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v2beta1"/>
    <API title="Real-time Bidding API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1alpha"/>
    <API title="AWS Snow Device Management"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="2021-08-04"/>
    <API title="Cloud Text-to-Speech API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Healthcare API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Amazon Chime SDK Identity"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="2021-04-20"/>
    <API title="Network Services API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Datastore API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta3"/>
    <API title="Amazon Chime SDK Messaging"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="2021-05-15"/>
    <API title="Cloud Translation API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v3beta1"/>
    <API title="Service Usage API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="AWS Route53 Recovery Readiness"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="2019-12-02"/>
    <API title="Service Networking API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Cloud Tasks API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v2beta3"/>
    <API title="AdMob API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Eventarc API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Workflow Executions API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Cloud Bigtable Admin API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1"/>
    <API title="Container Analysis API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="GKE Hub API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Firebase Hosting API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Route53 Recovery Cluster"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="2019-12-02"/>
    <API title="API Gateway API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1alpha2"/>
    <API title="Cloud OS Login API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Dialogflow API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v3beta1"/>
    <API title="Policy Simulator API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="On-Demand Scanning API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Identity-Aware Proxy API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Secret Manager API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Billing Budget API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Document AI API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta3"/>
    <API title="AWS Route53 Recovery Control Config"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="2020-11-02"/>
    <API title="Gmail Postmaster Tools API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Pub/Sub API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta2"/>
    <API title="Certificate Authority API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Firebase ML API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta2"/>
    <API title="Amazon MemoryDB"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="2021-01-01"/>
    <API title="Tag Manager API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v2"/>
    <API title="App Engine Admin API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Dataproc Metastore API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Cloud Memorystore for Memcached API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta2"/>
    <API title="Cloud Deployment Manager V2 API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v2beta"/>
    <API title="Idea Hub API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Cloud Asset API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1p7beta1"/>
    <API title="Managed Streaming for Kafka Connect"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="2021-09-14"/>
    <API title="Service Directory API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Service Consumer Management API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Database Migration API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Identity API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Resource Manager API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v3"/>
    <API title="Network Security API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Access Context Manager API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Workflows API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Web Security Scanner API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Network Management API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Runtime Configuration API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Cloud Natural Language API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta2"/>
    <API title="Campaign Manager 360 API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v3.5"/>
    <API title="Cloud Video Intelligence API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1p3beta1"/>
    <API title="Cloud Domains API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="OS Config API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta"/>
    <API title="Artifact Registry API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta2"/>
    <API title="Cloud Scheduler API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Binary Authorization API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Blogger API v3"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v3"/>
    <API title="Cloud Data Fusion API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
    <API title="Policy Analyzer API"
         releaseDate="2021-12-15T00:27:29.752Z"
         versionNumber="v1beta1"/>
</APIK>
```
**7. lekérdezés:**
Listázzuk ki azoknak az apiknak a nevét, vezióját, élesítés dátumát és elérhetőségeit (contact),
    amelyeknek van legalább 1 elérhetősége(contacton belüli title, email, url) 
    és 2017 második negyedévében lettek élesítve

```xquery
xquery version "3.1";
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
```

**Eredmény:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<APIK apiNums="47">
    <API name="neutrinoapi.net">
        <VERSIONS versionNum="1">
            <VERSION version="3.5.0">
                <ADDED releaseDate="2017-04-13T09:20:16.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Neutrino API"/>
                            <EMAIL email="ops@neutrinoapi.com"/>
                            <URL url="https://www.neutrinoapi.com/"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="gov.bc.ca">
        <VERSIONS versionNum="1">
            <VERSION version="3.x.x">
                <ADDED releaseDate="2017-04-20T18:04:18.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="BC Geographical Names Office"/>
                            <EMAIL email="geographical.names@gov.bc.ca"/>
                            <URL url="https://www2.gov.bc.ca/gov/content?id=A3C60F17CE934B1ABFA366F28C66E370"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="gov.bc.ca">
        <VERSIONS versionNum="1">
            <VERSION version="3.0.1">
                <ADDED releaseDate="2017-04-20T18:04:18.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Data BC"/>
                            <EMAIL email="data@gov.bc.ca"/>
                            <URL url="http://data.gov.bc.ca/"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="gov.bc.ca">
        <VERSIONS versionNum="1">
            <VERSION version="1.0.0">
                <ADDED releaseDate="2017-04-20T18:04:18.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Drive BC"/>
                            <EMAIL email="TRANBMClientRelations@gov.bc.ca"/>
                            <URL url="http://www.drivebc.ca/"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="gov.bc.ca">
        <VERSIONS versionNum="1">
            <VERSION version="2.0.0">
                <ADDED releaseDate="2017-04-20T18:04:18.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="DataBC"/>
                            <EMAIL email="IDDDBCLS@Victoria1.gov.bc.ca"/>
                            <URL url="https://data.gov.bc.ca/"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="flat.io">
        <VERSIONS versionNum="1">
            <VERSION version="2.13.0">
                <ADDED releaseDate="2017-04-22T11:51:48.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Flat"/>
                            <EMAIL email="developers@flat.io"/>
                            <URL url="https://flat.io/developers/docs/api/"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="lyft.com">
        <VERSIONS versionNum="1">
            <VERSION version="1.0.0">
                <ADDED releaseDate="2017-04-22T14:11:24.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Lyft"/>
                            <EMAIL email="api-support@lyft.com"/>
                            <URL url="http://developer.lyft.com"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="beezup.com">
        <VERSIONS versionNum="1">
            <VERSION version="2.0">
                <ADDED releaseDate="2017-04-24T21:26:55.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title=""/>
                            <EMAIL email="help@beezup.com"/>
                            <URL url=""/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2010-05-08">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2010-08-01">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2014-10-31">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2015-02-02">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2011-06-15">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2013-01-01">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2012-11-05">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2009-04-15">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2012-12-01">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2012-06-01">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="amazonaws.com">
        <VERSIONS versionNum="1">
            <VERSION version="2006-03-01">
                <ADDED releaseDate="2017-05-02T07:59:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Mike Ralphson"/>
                            <EMAIL email="mike.ralphson@gmail.com"/>
                            <URL url="https://github.com/mermade/aws2openapi"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="deutschebahn.com">
        <VERSIONS versionNum="1">
            <VERSION version="2.1">
                <ADDED releaseDate="2017-05-08T14:44:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="Michael Binzen"/>
                            <EMAIL email="michael.binzen@deutschebahn.com"/>
                            <URL url=""/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="deutschebahn.com">
        <VERSIONS versionNum="1">
            <VERSION version="v1">
                <ADDED releaseDate="2017-05-08T14:44:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="DB Systel GmbH"/>
                            <EMAIL email="Joachim.Schirrmacher@deutschebahn.com"/>
                            <URL url=""/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="deutschebahn.com">
        <VERSIONS versionNum="1">
            <VERSION version="v1">
                <ADDED releaseDate="2017-05-08T14:44:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="DB Systel GmbH"/>
                            <EMAIL email="Joachim.Schirrmacher@deutschebahn.com"/>
                            <URL url=""/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="deutschebahn.com">
        <VERSIONS versionNum="1">
            <VERSION version="v1">
                <ADDED releaseDate="2017-05-08T14:44:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="DB Rent GmbH"/>
                            <EMAIL email="partner@flinkster.de"/>
                            <URL url=""/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="deutschebahn.com">
        <VERSIONS versionNum="1">
            <VERSION version="v1">
                <ADDED releaseDate="2017-05-08T14:44:53.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="DBOpenData"/>
                            <EMAIL email="DBOpenData@deutschebahn.com"/>
                            <URL url="https://developer.deutschebahn.com/store/"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="1forge.com">
        <VERSIONS versionNum="1">
            <VERSION version="0.0.1">
                <ADDED releaseDate="2017-05-30T08:34:14.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title="1Forge"/>
                            <EMAIL email="contact@1forge.com"/>
                            <URL url="http://1forge.com"/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="victorops.com">
        <VERSIONS versionNum="1">
            <VERSION version="0.0.3">
                <ADDED releaseDate="2017-06-13T10:07:43.000Z">
                    <INFO>
                        <CONTACT>
                            <TITLE title=""/>
                            <EMAIL email=""/>
                            <URL url=""/>
                        </CONTACT>
                    </INFO>
                </ADDED>
            </VERSION>
        </VERSIONS>
    </API>
</APIK>
```


**8. lekérdezés:**
Listázzuk ki azoknak az apiknak a szolgáltatásainak a háttérszínét és háttér url-jét,
    amelyek az élesítéstől fogva 2021 második félévében voltak frissítve és van háttérszínük

```xquery
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
```

**Eredmény:**
```json
<?xml version="1.0" encoding="UTF-8"?>
<APIK>
    <API name="amentum.space:aviation_radiation">
        <VERSION updated="2021-08-23T09:34:59.789Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_twitter.com_amentumspace_profile_image"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="amentum.space:space_radiation">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_twitter.com_amentumspace_profile_image"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="amentum.space:gravity">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_twitter.com_amentumspace_profile_image"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="amentum.space:global-magnet">
        <VERSION updated="2021-08-23T09:34:59.789Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_twitter.com_amentumspace_profile_image.jpeg"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="amentum.space:atmosphere">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_twitter.com_amentumspace_profile_image.jpeg"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="ebay.com:sell-marketing">
        <VERSION updated="2021-07-26T08:51:53.432Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_twitter.com_ebay_profile_image.jpeg"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="ebay.com:sell-fulfillment">
        <VERSION updated="2021-08-23T09:34:59.789Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_twitter.com_ebay_profile_image.jpeg"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="ebay.com:sell-account">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_twitter.com_ebay_profile_image.jpeg"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="ebay.com:buy-feed">
        <VERSION updated="2021-08-23T09:34:59.789Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_twitter.com_ebay_profile_image.jpeg"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="epa.gov:air">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_pbs.twimg.com_profile_images_632233890594299904_DgRDU6dx_400x400.png"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="epa.gov:case">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_pbs.twimg.com_profile_images_632233890594299904_DgRDU6dx_400x400.png"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="epa.gov:eff">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_pbs.twimg.com_profile_images_632233890594299904_DgRDU6dx_400x400.png"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="epa.gov:sdw">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_pbs.twimg.com_profile_images_632233890594299904_DgRDU6dx_400x400.png"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="epa.gov:rcra">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_pbs.twimg.com_profile_images_632233890594299904_DgRDU6dx_400x400.png"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="epa.gov:dfr">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_pbs.twimg.com_profile_images_632233890594299904_DgRDU6dx_400x400.png"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="epa.gov:echo">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_pbs.twimg.com_profile_images_632233890594299904_DgRDU6dx_400x400.png"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
    <API name="epa.gov:cwa">
        <VERSION updated="2021-07-05T15:07:17.927Z ">
            <INFO>
                <X-LOGO>
                    <BACKGROUND-COLOR backgroundColor="#FFFFFF"/>
                    <URL url="https://api.apis.guru/v2/cache/logo/https_pbs.twimg.com_profile_images_632233890594299904_DgRDU6dx_400x400.png"/>
                </X-LOGO>
            </INFO>
        </VERSION>
    </API>
</APIK>
```

**9. lekérdezés:**
Listázzuk ki azoknak az apiknak a címét és leírását, amely leírásában vagy címében megtalálható
    az "api" szó és a leírás hossza kevesebb mint 500 karakter

```xquery
xquery version "3.1";
    
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
```

**Eredmény:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<APIK>
    <API name="api.video">
        <VERSIONS>
            <VERSION version="1">
                <TITLE title="api.video"/>
                <DESCRIPTION description="api.video is an API that encodes on the go to facilitate immediate playback, enhancing viewer streaming experiences across multiple devices and platforms. You can stream live or on-demand online videos within minutes."/>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="apis.guru">
        <VERSIONS>
            <VERSION version="2.0.2">
                <TITLE title="APIs.guru"/>
                <DESCRIPTION description="Wikipedia for Web APIs. Repository of API specs in OpenAPI 3.0 format.&#xA;&#xA;**Warning**: If you want to be notified about changes in advance please join our [Slack channel](https://join.slack.com/t/mermade/shared_invite/zt-g78g7xir-MLE_CTCcXCdfJfG3CJe9qA).&#xA;&#xA;Client sample: [[Demo]](https://apis.guru/simple-ui) [[Repo]](https://github.com/APIs-guru/simple-ui)&#xA;"/>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="apisetu.gov.in">
        <VERSIONS>
            <VERSION version="3.0.0">
                <TITLE title="Gujarat Vidyapith, Ahmedabad"/>
                <DESCRIPTION description="Gujarat Vidyapith, Ahmedabad (http://www.gujaratvidyapith.org/) is issuing Degree certificates through DigiLocker. These can be pulled by students into their DigiLocker accounts. Currently, data for the year 2019 is made available by Gujarat Vidyapith."/>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="googleapis.com">
        <VERSIONS>
            <VERSION version="v1beta1">
                <TITLE title="Service Broker"/>
                <DESCRIPTION description="The Google Cloud Platform Service Broker API provides Google hosted&#xA;implementation of the Open Service Broker API&#xA;(https://www.openservicebrokerapi.org/).&#xA;"/>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="googleapis.com">
        <VERSIONS>
            <VERSION version="v1beta1">
                <TITLE title="Recommendations AI (Beta)"/>
                <DESCRIPTION description="Note that we now highly recommend new customers to use Retail API, which incorporates the GA version of the Recommendations AI funtionalities. To enable Retail API, please visit https://console.cloud.google.com/apis/library/retail.googleapis.com. The Recommendations AI service enables customers to build end-to-end personalized recommendation systems without requiring a high level of expertise in machine learning, recommendation system, or Google Cloud."/>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="googleapis.com">
        <VERSIONS>
            <VERSION version="v1">
                <TITLE title="IAM Service Account Credentials API"/>
                <DESCRIPTION description="Creates short-lived credentials for impersonating IAM service accounts. To enable this API, you must enable the IAM API (iam.googleapis.com). "/>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="openapi-generator.tech">
        <VERSIONS>
            <VERSION version="5.2.1">
                <TITLE title="OpenAPI Generator Online"/>
                <DESCRIPTION description="This is an online openapi generator server.  You can find out more at https://github.com/OpenAPITools/openapi-generator."/>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="papinet.io">
        <VERSIONS>
            <VERSION version="1.0.0">
                <TITLE title="papiNet API"/>
                <DESCRIPTION description="papinet API is a global initiative for the Forst and Paper supply chain."/>
            </VERSION>
        </VERSIONS>
    </API>
    <API name="webscraping.ai">
        <VERSIONS>
            <VERSION version="2.0.4">
                <TITLE title="WebScraping.AI"/>
                <DESCRIPTION description="A client for https://webscraping.ai API. It provides a web scaping automation API with Chrome JS rendering, rotating proxies and builtin HTML parsing."/>
            </VERSION>
        </VERSIONS>
    </API>
</APIK>
```

**10. lekérdezés:**
Jelenítsük meg HTML kimenetben azoknak az apiknak a címét, leírását, vezióját,
    élesítés dátumát és elérhetőségeit, melyeknek a leírásának hossza 300 és 800 karakter köz van,
    mindhárom elérhetőséget tartalmazza, az élesítés dátuma 2017-ben történt 
    és a verzió hossza kevesebb 6 karakternél.

```xquery
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html";
declare option output:html-version "5.0";
declare option output:indent "yes";

(:
    Jelenítsük meg HTML kimenetben azoknak az apiknak a címét, leírását, vezióját,
    élesítés dátumát és elérhetőségeit, melyeknek a leírásának hossza 300 és 800 karakter köz van,
    mindhárom elérhetőséget tartalmazza, az élesítés dátuma 2017-ben történt 
    és a verzió hossza kevesebb 6 karakternél.

:)

declare variable $stylesheet := "./global.css";

let $json := fn:json-doc("./list.json")?*

return document {
    <html>
        <head>
            <title>Szűrt apik listája</title>
            <link rel="stylesheet" href="{$stylesheet}"/>
        </head>
            <body>
                <div class="container">
                    {
                    for $adat in $json
                        let $added := $adat?added
                        let $description := $adat?versions?*?info?description
                        let $url := $adat?versions?*?info?x-logo?url
                        let $email := $adat?versions?*?info?contact?email
                        let $name := $adat?versions?*?info?contact?name
                        let $title := $adat?versions?*?info?title
                         where string-length($description) gt 300 and string-length($description) lt 800
                            and fn:exists($url) and fn:exists($email) and fn:exists($name) 
                            and xs:dateTime($added) gt xs:dateTime("2017-01-01T00:00:00") and xs:dateTime($added) lt xs:dateTime("2018-01-01T00:00:00")
                            and string-length($adat?preferred) lt 6
                         order by $title ascending
                    return 
                    <div class="wrapper">
                        <a class="header-text" href="{ $url }">
                          <img src="{ $url }"/>
                          { $title }
                       </a>
                       <div class="content">
                           <div class="title-text">
                                Description
                           </div>
                           <div class="text">
                                {$description}
                           </div>
                           <div class="versions">
                               <div class="text">
                                    Version: {$adat?preferred}
                               </div>
                               <div class="text">
                                    Added: {format-dateTime(xs:dateTime($adat?added), "[Y,4].[M,2].[D,2]")}
                               </div>
                           </div>
                       </div>
                       <div class="footer">
                         <div class="contact">
                            <div class="title-text">
                                Contacts
                            </div>
                            <div class="text">
                                Email: {$email}
                            </div>
                            <div class="text">
                                Name: {$name}
                            </div> 
                            <div class="text ">
                                URL: {$url}
                            </div> 
                          </div> 
                       </div>
                       
                    </div>
                    }
               </div>
            </body>   
        </html>
}
```
