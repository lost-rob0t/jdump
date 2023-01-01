import json
import strutils
import tables
import strformat
import terminal
proc format(doc: JsonNode, indent: int = 0, str: var string = ""): string =
  let pairs = doc.getFields
  for key in pairs.keys:
    case pairs[key].kind:
      of JObject:
        var nstr = "\n" & indent(fmt"==={key}===:", indent) & "\n"
        var str1 = pairs[key].format(indent + 2, nstr)
        str &= str1
      of JArray:
        str &=  "\n" & indent(fmt"==={key}===:", indent) & "\n"
        for node in doc[key].getElems:
          case node.kind:
            of JObject:
              var str1 = node.format(indent + 2, str)
              str &= str1
            else:
              str &= indent("\n" & "- " & node.getStr, indent + 2) & "\n"
      else:
        str &= indent("\n" & key & ": "  & pairs[key].getStr, indent) & "\n"
  result = str

#proc fetchUrl(url: string, headers: Table[string, string] = newTab): JsonNode

proc main(mode: string = "file", input: seq[string]) =
  if isatty(stdin):
    for file in input:
      let o = open(file, fmRead)
      for line in o.lines:
        var t = ""
        try:
          echo format(line.parseJson, 2, t)
        except JsonParsingError:
          discard
          when defined(debug):
            echo line
      o.close
  else:
    for line in stdin.lines:
      var t = ""
      try:
        echo format(line.parseJson, 2, t)
      except JsonParsingError:
        discard
        when defined(debug):
          echo line

when isMainModule:
  import cligen; dispatch main, help={"mode": "Get json from file or web", "input": "list of files or http urls"}
