%% BDF Parser

Nonterminals
items item values value.

Terminals
eol string keyword.

Rootsymbol items.

items -> item : ['$1'].
items -> item items : ['$1'] ++ '$2'.

item -> keyword eol : {keyword, to_string(unwrap('$1')), []}.
item -> keyword values eol : {keyword, to_string(unwrap('$1')), '$2'}.
item -> values eol : '$1'.

values -> value : ['$1'].
values -> value values : ['$1'] ++ '$2'.

value -> string : to_string(unwrap('$1')).

Erlang code.

unwrap({_Token,_Line,Value}) -> Value.
to_string(Value) -> 'Elixir.List':to_string(Value).
