use Ra;
Ra.eval: q:to<END>;
say "1..4"
a=[10,18+2 , 30]
a[3] = 40
say "{a[0] == 10? 'ok' : 'nok'} 1 - a[0]"
say "{a[1] == 20? 'ok' : 'nok'} 2 - a[1]"
say "{a['2'] == 30? 'ok' : 'nok'} 3 - a['2']"
say "{a[1+2] == 40? 'ok' : 'nok'} 4 - a[1+2]"
END