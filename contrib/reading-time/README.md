# Reading time in DocBook 5 documents

It is good to give readers a rough estimate of how long a text will take to read.

## Calculating reading time

The formular is:

    Tr = ⌈W/WPM⌉

The symbols have the following meaning:

* Tr = the reading time in minutes
* W = the word count of your text
* WPM = Words per minute, the average reading speed. A common assumption is 200 words/min.
* The `⌈...⌉` is the _ceiling_ function which rounds up to the nearest whole number
  because reading time is usually expressed in whole minutes.

## Example calculation

If a text has 450 words:

   Tr = ⌈450/200⌉ = ⌈2.25 min⌉ = 3 min

## Alternatives

There are different methods to determine the word count of a DocBook 5 XML document:

* `xmllint`

      xmllint --xpath "string(//*)"  XMLFILE

  The `string(//*)` concatenates all text nodes together. However, it may also add text nodes which you don't want (for example, `info/meta`).

* `xmlstarlet`

      xmlstarlet sel -t -m "//*[not(*)]" -v "." -n XMLFILE

  Selects only elements that do not have child elements (leaf elements). This prevents duplication by excluding parent elements. It extracts the text content of each selected element (via `-v "."`) and adds a newline after each element's text (via `-n`).

* `sed` (Quick and Dirty)

      sed -e '/<!--/,/-->/d' -e '/<\?xml.*\?>/d' -e 's/<[^>]*>//g' XMLFILE

  Handles multi-line comments and processing instructions.

## Example

```shell-session
$ xsltproc contrib/reading-time/reading-time.xsl contrib/reading-time/sample-1.xml 
<?xml version="1.0"?>
<result xmlns:d="http://docbook.org/ns/docbook">
  <word-count>22</word-count>
  <reading-time unit="min">1</reading-time>
</result>
```