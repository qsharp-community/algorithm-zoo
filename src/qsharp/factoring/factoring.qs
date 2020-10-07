namespace Factoring {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Random;

    @EntryPoint()
    operation FactorSemiprimeInteger(number : Int) : (Int, Int) 
    {
        if (number % 2 == 0) {
            Message("An even number has been provided, 2 is a factor.");
            return (number/2, 2);
        }

        mutable factors = (1, 1);
        mutable foundFactors = false;

        repeat {
            let a = DrawRandomInt(3, number-1);
            if (IsCoprimeI(a, number)){
                let r = EstimatePeriod(a, number);
                set (foundFactors, factors) = MaybeFactorsFromPeriod(a, r, number);
            } else {
                let gcd = GreatestCommonDivisorI(a, number);
                Message($"We did it by accident, {gcd} is a factor of {number}.");
                set foundFactors = true;
                set factors = (gcd, number/gcd); 
            }
        } until (foundFactors)
        fixup {
            Message("Current guess failed, trying again.");
        }

        return factors;
    }

    operation EstimatePeriod(a : Int, number : Int) : Int {
        return 1;
    }

    function MaybeFactorsFromPeriod(a : Int, r : Int, number : Int) 
    : (Bool, (Int, Int)) {
        if (r % 2 == 0) {

            let halfPower = ExpModI(a, r/2, number);
            if (halfPower != number - 1){
                let factor = MaxI(
                    GreatestCommonDivisorI(halfPower + 1, number),
                    GreatestCommonDivisorI(halfPower - 1, number)
                );
                return (true, (factor, number/factor));

            } else {
                return (false, (1, 1));
            }

        } else {
            return (false, (1, 1));
        }
    }
    
}
