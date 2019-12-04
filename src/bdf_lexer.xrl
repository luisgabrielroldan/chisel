%% BDF lexer

Definitions.

Whitespace = [\s\t]
Terminator = \n|\r\n|\r
Comma = ,

Keywords    = STARTFONT|COMMENT|FONT|SIZE|FONTBOUNDINGBOX|STARTPROPERTIES|ENDPROPERTIES|CHARS|STARTCHAR|ENCODING|SWIDTH|DWIDTH|BBX|BITMAP|ENDCHAR|ENDFONT

Digit = [0-9]
NonZeroDigit = [1-9]
NegativeSign = [\-]
Sign = [\+\-]
FractionalPart = \.{Digit}+
Comment = COMMENT.*\n|\r\n|\r

IntegerPart = {NegativeSign}?0*|{NegativeSign}?{NonZeroDigit}{Digit}*
Integer = {IntegerPart}
Decimal = {IntegerPart}{FractionalPart}
String   = "(.|\n)*"|[A-Za-z0-9\-_.+]+

Rules.

{Keywords} : {token, {keyword, TokenLine, TokenChars}}.
{Comma} : skip_token.
{Whitespace} : skip_token.
{Terminator} : {token, {eol, TokenLine, TokenChars}}.
{String}   : {token, {string, TokenLine, TokenChars}}.
{Comment}   : skip_token.

Erlang code.
