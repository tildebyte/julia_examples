module GenPassphrase
# Assumptions:
# User's going to want spaces between words. This does not seem unreasonable to me.

# TODO:
# - Error handling in post().
# - Test length

# Requirements:
# https://github.com/JuliaWeb/Requests.jl
# https://github.com/JuliaLang/JSON.jl
# https://github.com/carlobaldassi/ArgParse.jl
# They can be satisfied via the usual Pkg.add("PACKAGE")
import Requests
import JSON
import ArgParse


# Word list from http://world.std.com/%7Ereinhold/beale.wordlist.asc
# I formatted it as a Julia dict to save having to do file I/O and muck
#     around with transforming it into a Dict (or whatever) on-the-fly.
include("C:\\Users\\balkov\\Dropbox\\stuff\\code\\beale.wordlist.asc.jl")


function handle_args()
    parser = ArgParse.ArgParseSettings(description =
                        "Generate a passphrase with an arbitrary number
                        of words, comprised of an arbitrary minimum number
                        of characters, using the Diceware rules and
                        random Integers from Random.org",
                        autofix_names = true,
                        version = "1.0",
                        add_version = true)
    ArgParse.@add_arg_table parser begin
        "--phrase-length", "-l"
            help = "Number of words in the generated passphrase. Default 6"
            arg_type = Int
            default = 6
        "--min-chars", "-n"
            help = "Minimum number of characters in the generated passphrase. Default 17"
            arg_type = Int
            default = 17
        "api-key"
            help = "Your personal Random.org API key."
            arg_type = String
            required = true
            metavar = "API_KEY"
    end
    return ArgParse.parse_args(parser)
end


function array_to_string(array)
    # `repr()` `array` into a single String...
    #     ...and remove all ','.
    s = replace("$array", ",", "")
    # Strip "{}".
    s[2:length(s) - 1]
end


function split_string_to_array(str, phrase_length)
    s = string("")
    # 6 word indexes...
    for i = 1:phrase_length
       # ...of 5 char each, delimited by spaces.
       s *= str[i:i+4] * " "
    end
    split(s)
end


function main()
    args = handle_args()
    phrase_length = args["phrase_length"]
    passphrase = string("")
    JSONRequest = {
                   "jsonrpc" => "2.0",
                   "method" => "generateIntegers",
                   "params" => {
                       "apiKey" => args["api_key"],
                       # Number of ints to get. Diceware requires 5 * Int
                       #    for its index.
                       "n" => phrase_length * 5,
                       # Simulate a die-6 roll.
                       "min" => 1,  # Requested Int minimum.
                       "max" => 6,  # Requested Int maximum.
                       "replacement" => true,
                       "base" => 10
                   },
                   # `id` value doesn't matter. I think this is to allow us and
                   #     the server to verify that we're talking about the
                   #     same request.
                   "id" => rand(1:10000)
    }
    # Returns a Response *object*.
    response = Requests.post("https://api.random.org/json-rpc/1/invoke";
                             json = JSONRequest)
    # Grab the JSON (the `data` field of the Response object).
    json = JSON.parse(response.data)
    # Array of `Num_Digits`::Any.
    ints = array_to_string(json["result"]["random"]["data"])
    word_indexes = split_string_to_array(ints, phrase_length)
    for w in word_indexes
        passphrase *= wordlist[w] *  " "
    end
    if length(passphrase) < args["min_chars"]
        passphrase = string("")
        main()
    end
    # Because we have one space left at the end of the string.
    passphrase = strip(passphrase)
    println("$passphrase")
end


main()
end
