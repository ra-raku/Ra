unit class Ra;

use Ra::Grammar;
use Ra::Actions;

method grammar {Ra::Grammar}
method actions {Ra::Actions.new}

multi method compile(Str:D $code, Str:D :$rule = 'TOP') {
    .ast given $.grammar.parse($code, :$.actions, :$rule);
}

method eval(Str:D $code, *%o) {
    $.compile($code, |%o).EVAL;
}
