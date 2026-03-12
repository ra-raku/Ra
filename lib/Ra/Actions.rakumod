unit class Ra::Actions;

use experimental :rakuast;

use HLL::Expression::Grammar::Actions;
also does HLL::Expression::Grammar::Actions;

use       Ra::Operators;
also does Ra::Operators::Actions;

use       Ra::Values;
also does Ra::Values::Actions;

use Ra::Util :&compile, :&infix;
use Ra::Defs :RaBuiltIn;
use Method::Also;

method TOP($/) {
    make $<stmtlist>.&compile;
}

method stmtlist($/) {
    my RakuAST::Statement::Expression:D @stmts = @<stmt>>>.ast;
    make RakuAST::StatementList.new: |@stmts;
}

method modifier($/) {
    my constant %Modifier = %(
        :if(condition-modifier => RakuAST::StatementModifier::If),
        :unless(condition-modifier => RakuAST::StatementModifier::Unless),
        :while(loop-modifier => RakuAST::StatementModifier::While),
        :until(loop-modifier => RakuAST::StatementModifier::Until),
    );
    make %Modifier{$/};
}

multi method stmtish($/ where $<modifier>) {
    my $expression = $<stmt>.ast;
    my $mod-expr = $<EXPR>.&compile;
    given $<modifier>.ast {
        make RakuAST::Statement::Expression.new(
            :$expression,
            |(.key => .value.new($mod-expr))
        );
    }
}

multi method stmtish($/) {
    my $expression = $<stmt>.ast;
    make RakuAST::Statement::Expression.new(
        :$expression,
    );
}

method var($/) {
    my $name := ~$<ident>;
    my RakuAST::Name $id .= from-identifier: $name;

    make do given %*SYM{$name} {
        when 'var'  { RakuAST::Term::Name.new($id) }
        when 'func' { RakuAST::Call::Name::WithoutParentheses.new($id) }
        default     { $id }
    }
}

method stmt:sym<EXPR>($/) {
    make $<EXPR>.&compile;
}

method term:sym<call>($/ where $<call-args>) {
    my $id  := ~$<operation>;
    my $args = $<call-args>.ast;
    given ~$<operation> {
        when RaBuiltIn {
            my RakuAST::Name $name .= from-identifier($_);
            make RakuAST::Call::Name.new(:$name, :$args);
        }
        default {
            ...
        }
    }
}

method call-args($/) {
    my @args = @<arg>>>.ast;
    make RakuAST::ArgList.new(|@args);
}

method arg:sym<expr>($/) {
    make $<EXPR>.&compile;
}

method term:sym<value>($/) {
    make $<value>.ast;
}

method term:sym<var>($/) {
    my $var =  $<var>.ast;
    make $<var>.ast;
}

method term:sym<infix=>($/) {
    my $op = ~$<OPER>;
    my $left = $<var>.ast;
    my $right = $<EXPR>.&compile;
    make $op.&infix($left, $right);
}

method term:sym<circumfix>($/) { make $<circumfix>.ast }

method ws($/) is also<ww hs decint escale separator hexdigits xdigit before assign-op comment:sym<line> keyword comma operation> {}

method FALLBACK($method, $/) {
    die "Missing $method actions method"
        unless $method.contains('fix');
}
