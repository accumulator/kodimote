#!/usr/bin/python

import sys
import httplib2


def linebreak(indent):
    retval = "\n"
    for i in range(1, indent):
        retval += "  "
    return retval

# Dirty hack to "source" config files


def execfile(file, globals=globals(), locals=locals()):
    try:
        with open(file, "r") as fh:
            exec(fh.read() + "\n", globals, locals)
    except:
        #    print("config file not found")
        pass


def introspect_http(host, port):
    '''Get api definition'''
    h = httplib2.Http()
    res, content = h.request("http://" + host + ":" + str(port) + "/jsonrpc", "POST",
                             "{\"id\":0,\"jsonrpc\":\"2.0\", \"method\":\"JSONRPC.Introspect\"}")  # , headers)
    # print(res)
    # print(content)
    retval = ""
    retval += content.decode("utf-8")
    return retval


def print_file(filename, output):
    '''Write result'''
    file_handle = open(filename, "w")
    file_handle.write(output)


def format_data(data):
    '''format resulting json'''
    bracecount = 0
    methodlevel = -1
    methodstring = ""
    indent = 0
    outputjson = ""

    if not data == "":
        for char in data:
            prefix = ""
            suffix = ""

    #    if(char=="\""):
    #      if(lastchar==","):
    #        prefix+=linebreak();

            if char == "{" or char == "[":
                bracecount += 1
                indent += 1
                suffix += linebreak(indent)

            if char == "}" or char == "]":
                bracecount -= 1
                indent -= 1
                prefix += linebreak(indent)

            if char == ",":
                #      if(lastchar=="}"):
                suffix += linebreak(indent)
                if bracecount == methodlevel + 1:
                    suffix += linebreak(indent)

            # reassemble the string
            outputjson += prefix
            outputjson += char
            outputjson += suffix

            # do some other thecks
            methodstring += char
            tmp = "methods"
            if methodstring == tmp:
                methodlevel = bracecount
                methodstring = ""
    #      print("methodlevel is", methodlevel)

            if not tmp.startswith(methodstring):
                methodstring = ""

    #    print("got brace. total:", bracecount)
            # lastchar = char

    return outputjson


def main():
    """Our main program"""
    # Config here:
    host = "localhost"
    port = 8080
    outputfile = "doc/kodiapi.json"
    config_file = '.fetchapi_config.py'
    nextishost = 0
    nextisport = 0
    nextisof = 0

    execfile(config_file)
    for arg in sys.argv:
        #  print("command line arg", arg)
        if nextishost == 1:
            host = arg
            nextishost = 0
        if nextisport == 1:
            port = arg
            nextisport = 0
        if nextisof == 1:
            outputfile = arg
            nextisof = 0
        if arg == "--help":
            print("usage:", sys.argv[0], "[-h <ip>] [-p <port>] [-o <outputfile>]")
            exit(0)
        if arg == "-h":
            nextishost = 1
        if arg == "-p":
            nextisport = 1
        if arg == "-o":
            nextisof = 1

    print("connecting to host:", host)

    data = introspect_http(host, port)
    outputjson = format_data(data)
    print_file(outputfile, outputjson)


if __name__ == "__main__":
    main()
