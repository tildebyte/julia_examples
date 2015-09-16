module GenPassphrase
# "If your passphrase, including the spaces between the words, is less than 17
# characters long, we recommend that you start over and create a new
# passphrase."
# Word list URL: http://world.std.com/%7Ereinhold/beale.wordlist.asc
# Random.org API:
#   API URL: https://api.random.org/json-rpc/1/invoke
#   Must use: HHTPS; POST
#   API key: cdec43fc-f7ef-4281-ade7-eac07f733013
#   Content-type: one of application/json-rpc; application/json; application/jsonrequest
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
#                 1,
#                 4,
#                 6,
#                 5,
#                 6,
#                 1,
#                 5,
#                 6,
#                 4,
#                 4,
#                 4,
#                 5,
#                 2,
#                 4,
#                 5,
#                 6,
#                 2,
#                 4,
#                 2,
#                 4,
#                 2,
#                 6,
#                 2,
#                 4,
#                 5,
#                 3,
#                 5,
#                 1,
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
    # Grab only the random `Int` array.
    randints = array
    # `repr` `randints` into a single String...
    # ...and replace all ','.
    digits = replace("$randints", ",", "")
    # Strip "{}".
    digits[2:length(digits) - 1]
end


function split_string_to_array(str)
    indexes = string("")
    for i = 1:6
       indexes *= str[i:i+4] * " "
    end
    split(indexes)
end


# Returns a Response *object*.
response = Requests.post("https://api.random.org/json-rpc/1/invoke"; json = JSONRequest)
# Grab the JSON (the `data` field of the Response object).
json = JSON.parse(response.data)
# Array of `Num_Digits`::Any.
digits = array_to_string(json["result"]["random"]["data"])
word_indexes = split_string_to_array(digits)
for w in word_indexes
    passphrase *= wordlist[w] *  " "
end
passphrase = strip(passphrase)
end
