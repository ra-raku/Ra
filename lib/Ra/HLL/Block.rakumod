unit class Ra::HLL::Block;

use Ra::HLL::Symbol;
has Ra::HLL::Symbol %!symbol;

method symbol(Str:D $name) {
    %!symbol{$name} //= Ra::HLL::Symbol.new;
}
