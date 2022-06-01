module CeDataAnalysis

# "export" functions / variables that should be accessible when you do `using CeDataAnalysis`
export foo,
       # bar
       baz,
       this_uses_bar # this is defined in "src/othercode.jl"

foo() = "that's foo!"
bar() = "that's bar!"
baz() = "that's baz!"

include("othercode.jl")

end