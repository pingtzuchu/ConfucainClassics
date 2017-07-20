xquery version "3.0";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="http://exist-db.org/apps/cc/config";

declare namespace templates="http://exist-db.org/xquery/templates";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";

(: 
    Determine the application root collection from the current module load path.
:)
declare function config:homepage(){
    <div>
        <h1>儒家經典注疏研究平台</h1>
        <div class="alert alert-success">
            <p>歡迎來到儒家經典注疏研究平台。本平台設計的目的，在於發掘與測試數位科技對於儒家經典注疏的可能影響。目前主要功能設定為閱覽與研究。就閱覽而言，數位平本和傳統紙本呈現的方式有何不同，如何呈現更有利於經學的研究，會是平台建置的重點。就研究而言，又可分成兩個部分，第一個部分的重點在幫助一般經學研究會遇到的問題，例如不同版本的經文比較、注疏文字與經文的異同度、經文中斷詞標點等等問題；另一部分的重點，則在於幫助參加本整合型計畫之子計畫的進行。</p>
            <p>如果你對於利用數位工具來研究儒家經典感到興趣，也非常在目前的階段與我們共同建造這個平台，或是在未來和我們一起進行整合型計畫。</p>
            <p>Kanripo的分卷有一些問題，通常卷首的序、卷中的考證，會另起一卷，但Kanripo常常會附在前卷，而沒有重新起始頁碼。</p>
            <p>也歡迎你加入<a href="http://tadh.org.tw/">台灣數位人文學會</a>，與我們一起發掘數位人文的可能性。</p>
        </div>
    </div>
};
declare variable $config:app-root := 
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

declare variable $config:data-root := $config:app-root || "/data";

declare variable $config:repo-descriptor := doc(concat($config:app-root, "/repo.xml"))/repo:meta;

declare variable $config:expath-descriptor := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve($relPath as xs:string) {
    if (starts-with($config:app-root, "/db")) then
        doc(concat($config:app-root, "/", $relPath))
    else
        doc(concat("file://", $config:app-root, "/", $relPath))
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-descriptor() as element(repo:meta) {
    $config:repo-descriptor
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function config:expath-descriptor() as element(expath:package) {
    $config:expath-descriptor
};

declare %templates:wrap function config:app-title($node as node(), $model as map(*)) as text() {
    $config:expath-descriptor/expath:title/text()
};

declare function config:app-meta($node as node(), $model as map(*)) as element()* {
    <meta xmlns="http://www.w3.org/1999/xhtml" name="description" content="{$config:repo-descriptor/repo:description/text()}"/>,
    for $author in $config:repo-descriptor/repo:author
    return
        <meta xmlns="http://www.w3.org/1999/xhtml" name="creator" content="{$author/text()}"/>
};

(:~
 : For debugging: generates a table showing all properties defined
 : in the application descriptors.
 :)
declare function config:app-info($node as node(), $model as map(*)) {
    let $expath := config:expath-descriptor()
    let $repo := config:repo-descriptor()
    return
        <table class="app-info">
            <tr>
                <td>app collection:</td>
                <td>{$config:app-root}</td>
            </tr>
            {
                for $attr in ($expath/@*, $expath/*, $repo/*)
                return
                    <tr>
                        <td>{node-name($attr)}:</td>
                        <td>{$attr/string()}</td>
                    </tr>
            }
            <tr>
                <td>Controller:</td>
                <td>{ request:get-attribute("$exist:controller") }</td>
            </tr>
        </table>
};