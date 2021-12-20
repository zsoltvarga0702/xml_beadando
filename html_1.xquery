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