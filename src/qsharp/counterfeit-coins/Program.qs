namespace CounterfeitCoins {

    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Bitwise;
    
/// N coin total in the bag, k coins are counterfeit.
/// https://arxiv.org/pdf/1009.0416.pdf
///

    @EntryPoint()
    operation HelloQ() : Unit {
        Message("Hello quantum world!");
    }

    operation FindCounterfeits(numCoins : Int) : Int {
        //1. Setup register
        use register1 = Qubit[numCoins];
        // Apply W
        within {
            ApplyW(register1, numCoins);
        }
        apply { 
        //2.       
            use register2 = Qubit[numCoins];
            //ApplyA(register2);
            //ControlledOnBitString(TBD, register2);

        }
        //3.
        return MeasureInteger(LittleEndian(register1));

    }

    operation ApplyW(target : Qubit[], numCoins : Int) : Unit
    is Adj + Ctl {
        //Generate list of all integers up to N
        let QEven = Filtered(Compose(EqualI(0, _), Parity), 
            RangeAsIntArray(0..numCoins));
        
    }
}

