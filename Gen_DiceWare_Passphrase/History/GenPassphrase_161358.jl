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

# Random.org API:
#   API URL: https://api.random.org/json-rpc/1/invoke
#   Must use: HHTPS; POST
#   Must have API key; get one here: https://api.random.org/json-rpc/1 "Get a Beta Key" button.
#   Return codes: successful, HTTP 200; client error, HTTP 400 (Bad Request)
#     or 404 (Method Not Found); server error, HTTP 500

# Random.org API JSON request:
# {
#     "jsonrpc": "2.0",
#     "method": "generateIntegers",
#     "params": {
#         "apiKey": "00000000-0000-0000-0000-000000000000",
#         "n": 30,
#         "min": 1,
#         "max": 6,
#         "replacement": true,
#         "base": 10
#     },
#     "id": RANDOM_INT_HERE
# }

# Random.org API JSON return (note missing "error" field):
# {
#     "jsonrpc": "2.0",
#     "result": {
#         "random": {
#             "data": [
#                 5,
#               *snip*
#                 3
#             ],
#             "completionTime": "2015-03-02 21:04:34Z"
#         },
#         "bitsUsed": 33,
#         "bitsLeft": 932908,
#         "requestsLeft": 197829,
#         "advisoryDelay": 0
#     },
#     "id": RANDOM_INT_HERE
# }

# Random.org API JSON error return:
# {
#     "jsonrpc": "2.0",
#     "error": {
#         "code": 12,
#         "message": "Error message",
#         "data": [ 17, 3 ]
#     },
#     "id": RANDOM_INT_HERE
# }


import Requests
import JSON
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
    digits = replace("$array", ",", "")
    # Strip "{}".
    digits[2:length(digits) - 1]
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
    # Returns a Response *object*.
    response = Requests.post("https://api.random.org/json-rpc/1/invoke";
                             json = JSONRequest)
    # Grab the JSON (the `data` field of the Response object).
    json = JSON.parse(response.data)
    # Array of `Num_Digits`::Any.
    digits = array_to_string(json["result"]["random"]["data"])
    word_indexes = split_string_to_array(digits)
    for w in word_indexes
        passphrase *= wordlist[w] *  " "
    end
    if length(passphrase) < 17
        main()
    end
    # Because we have one space left at the end of the string.
    passphrase = strip(passphrase)
end


main()
end
