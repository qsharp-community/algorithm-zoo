namespace Factoring {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Characterization;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Diagnostics;

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

// 3. Use iterative phase estimation to find the frequency of the classical 
// function f(x) = ax mod N. The frequency tells you about how quickly f 
// returns to the same value as x increases.
// 4. Use a classical algorithm known as the continued fractions expansion to 
// convert the frequency from the previous step into a period (r). 
// The period r should then have the property that f(x) = f(x + r) for all inputs x.

    operation EstimatePeriod(a : Int, number : Int) : Int {
        let bitSize = BitSizeI(number);
        let nBitsPrecision = 2 * bitSize + 1;
        // Values selected below make sure that default conditions for the loop 
        // are ok.
        mutable result = 1;
        mutable frequencyEstimate = 0;

        repeat{
            // QUANTUM PART START
            set frequencyEstimate = EstimateFrequency(nBitsPrecision,bitSize, ApplyPeriodFindingOracle(a, _, number, _));
            // QUANTUM PART END
            if (frequencyEstimate != 0){
                set result = PeriodFromFrequency(frequencyEstimate,nBitsPrecision, number, result);
            } else {
                Message("Estimated 0 as the frequency, trying again.");
            }

        } until (ExpModI(a, result, number) == 1)
        fixup{
            Message("So sorry eh, trying period estimation again.");
        }
        return result;
    }

    function PeriodFromFrequency(
        frequencyEstimate : Int,
        nBitsPrecision : Int,
        number : Int,
        result : Int
    ) : Int {
        let continuedFraction = ContinuedFractionConvergentI(
            Fraction(frequencyEstimate, 2^nBitsPrecision), 2^nBitsPrecision
        );
        let denominator = AbsI(continuedFraction::Denominator);
        return ((denominator * result) / GreatestCommonDivisorI(result, denominator));
    }

    operation EstimateFrequency(
        nBitsPrecision : Int,
        bitSize : Int, 
        oracle : ((Int, Qubit[]) => Unit is Adj+Ctl)
    ) : Int {
        using (register = Qubit[bitSize]) {
            let registerLE = LittleEndian(register);
            ApplyXorInPlace(1, registerLE);

            let phase = RobustPhaseEstimation(
                nBitsPrecision,
                DiscreteOracle(oracle),
                registerLE!
            );
            ResetAll(register);

            return Round((phase * IntAsDouble(2 ^ nBitsPrecision))/(2.0 * PI()));
        }  
    }

    operation ApplyPeriodFindingOracle(
        a : Int, x : Int, number :Int, register : Qubit[]
    ) : Unit is Adj + Ctl {
        Fact(IsCoprimeI(a, number), "Must be co-prime to modulus.");
        MultiplyByModularInteger(
            ExpModI(a, x, number),
            number, 
            LittleEndian(register)
        );
    }

    function MaybeFactorsFromPeriod(a : Int, r : Int, number : Int
    ) : (Bool, (Int, Int)) {
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
