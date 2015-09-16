module GenPassphrase
# TODO:
# - Check for passphrase < 17 char.
# - Error handling in post().
# - Handle command line args.
# - Parameterize word length and passphrase.

# Requirements:
# https://github.com/JuliaWeb/Requests.jl
# https://github.com/JuliaLang/JSON.jl
# They can be satisfied via the usual Pkg.add("PACKAGE")


# Word list from http://world.std.com/%7Ereinhold/beale.wordlist.asc
# I formatted it as a Julia dict to save having to do file I/O and muck
# around with transforming it into a Dict (or whatever) on-the-fly.
include("C:\\Users\\balkov\\Dropbox\\stuff\\code\\beale.wordlist.asc.jl")

NumDigits = 30
APIKey = "cdec43fc-f7ef-4281-ade7-eac07f733013"
NumMin = 1
NumMax = 6
PostID = rand(1:10000)
JSONRequest = {
    "jsonrpc" => "2.0",
    "method" => "generateIntegers",
    "params" => {
        "apiKey" => APIKey,
        "n" => NumDigits,
        "min" => NumMin,
        "max" => NumMax,
        "replacement" => true,
        "base" => 10
    },
    "id" => PostID
}
passphrase = string("")


function array_to_string(array)
    # `rep()` `array` into a single String...
    # ...and replace all ','.
    ints = replace("$array", ",", "")
    # Strip "{}".
    ints[2:length(ints) - 1]
end


function split_string_to_array(str)
    indexes = string("")
    # 6 word indexes...
    for i = 1:6
       # ...of 5 char each.
       indexes *= str[i:i+4] * " "
    end
    split(indexes)
end


function main()
    import Requests
    import JSON

    global passphrase
    # Returns a Response *object*.
    response = Requests.post("https://api.random.org/json-rpc/1/invoke";
                             json = JSONRequest)
    # Grab the JSON (the `data` field of the Response object).
    json = JSON.parse(response.data)
    # Array of `Num_Digits`::Any.
    ints = array_to_string(json["result"]["random"]["data"])
    word_indexes = split_string_to_array(ints)
    for w in word_indexes
        passphrase *= wordlist[w] *  " "
    end
    if length(passphrase) < 17
        main()
    end
    # Because we have one space left at the end of the string.
    passphrase = strip(passphrase)
    println("$passphrase")
end


main()
# quit()
end
