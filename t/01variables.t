use Ra;
Ra.eval: q:to<END>;
say "1..4";
my $a = 10;
END

sub test-eval(Str:D $code, Any $expected-result) {
    my Ra::Actions $actions .= new;
    subtest $code, {
        my RakuAST::StatementList $stmts = Ra.compile: $code;
        is-deeply $stmts.EVAL, $expected-result, "statement eval";
    }
}

subtest "scalars", {
    for ("my $x=42" => 42, "my $x=42;$x" => 42, "my $x=40;$x+2" => 42, "my $x=40;$x=42" => 42,
         "$x=40;$x=$x+2;$x" => 42, "$x=40;$x+=2" => 42, "\\if=40;\\if+2" => 42) {
        .key.&test-eval: .value;
    }
}

subtest "arrays", {
    for ("[10,20]" => [10,20], "$x=10;[$x, 19+1]" => [10,20], '[10,20,30][1]' => 20,
    "my @a=[10,20];@a[1]=30;@a" => [10,30]) {
        .key.&test-eval: .value;
    }
}

subtest "hashes", {
    for (q`%('a' => 10, "b" => 20)` => %(:a(10),:b(20)), q`my $x=10;B='b';%('a' => $x, B => 19+1)` =>  %(:a(10),:b(20)), q`%('a' => 10, 'b' => 20, 'c' => 30)<b>` => 20) {
        .key.&test-eval: .value;
    }
}
