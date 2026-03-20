unit grammar Ra::Grammar;

use HLL::Expression::Grammar;
also does HLL::Expression::Grammar;

use       Ra::Operators;
also does Ra::Operators::Grammar;

use       Ra::Values;
also does Ra::Values::Grammar;

use Ra::HLL::Block;
use Ra::Defs :RaBuiltIn;

token TOP {
    :my $*IN_TEMPLATE = False;           # true, if in a template
    :my $*IN_PARENS   = False;           # true, if in a parenthesised list
    :my $*CUR-BLOCK = Ra::HLL::Block.new;
    :my %*SYM;                           # symbols in current scope
    ^ ~ $ <stmtlist>
        || <.panic('Syntax error')>
}

# Comments and whitespace
proto token comment {*}
token comment:sym<line>   { '#' [<?{!$*IN_TEMPLATE}> \N* || [<!before <tmpl-unesc>>\N]*] }
token comment:sym<podish> {[^^'=begin'\n] [ .*? [^^'=end'[\n|$]] || <.panic('missing ^^=end at eof')>] }

token ws { <!ww> [\h | <.continuation> | <.comment> | <?{$*IN_PARENS}> \n ]* }
token hs { <!ww> [\h | <.continuation> ]* }

rule separator       { ';' | \n <!after continuation> }
token continuation   { \\ \n }

rule stmtlist {
    [ <stmt=.stmtish>? ] *%% <.separator>
}

#| a single statement, plus optional modifier
token stmtish {:s
    <stmt> [ <modifier> <EXPR>]?
}
token modifier {if|unless|while|until}

sub is-variable($op) {
    my $type := %*SYM{$op} // %*SYM-GBL{$op};

    $type ~~ 'var';
}
token var {
    ['\\'|<!keyword>]$<var>=[<ident> <!before [ \! | \? | <hs>\( ]>]
    [  <?before <hs> <.assign-op> >
       || <?{ is-variable(~$<var>) }>
       || <.panic("unknown variable or method: $<var>")>
    ]
}

multi sub callable(RaBuiltIn) {
    True;
}

multi sub callable($) { False }

token operation  {<ident>[\!|\?]?}
token term:sym<call> {
        <!keyword>
       <operation> [# '(' ~ ')' <call-args=.paren-args>? <code-block>?
            #|
            :s <?{callable(~$<operation>)}> <call-args>?
                    ]
}
token call-args {:s [ <arg> ] +% ',' }
proto token arg {*}
token arg:sym<expr>  {:s <EXPR> <!before ['=>'|':']> }

token term:sym<infix=> {<var> <OPER=infix> '=' <EXPR> }
token term:sym<var> { <var> }
token term:sym<value> { <value> }
token term:sym<circumfix> {:s <circumfix> }

proto token stmt { <...> }

token stmt:sym<EXPR> { <EXPR> }

# Reserved words.
token keyword {
    [ True | False | Nil ] <!ww>
}

method panic($err) { die $err }
