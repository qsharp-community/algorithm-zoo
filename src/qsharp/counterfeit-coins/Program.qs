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
    operation FindCounterfeits(numCoins : Int, numCounterfeit : Int) : Int {
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
        //let QEven = Filtered(Compose(EqualI(0, _), Parity), 
        //    RangeAsIntArray(0..numCoins));
        let most = Most(target);
        ApplyToEachCA(H, most);
        // |uniform⟩|0⟩
        ApplyToEachCA(CNOT(Tail(target), _), most);
        // 
    }

    operation ApplyR(
        control : Qubit[], 
        target : LittleEndian) 
    : Unit is Adj + Ctl {
        // R |i_0, i_1, i_2,..i_N⟩|0⟩ - > |i⟩|wt(i)⟩
        // wt() =  the number of 1's in your bitstring
        let arrayControl = Mapped(ConstantArray<Qubit>(1, _), control);
        ApplyToEachCA((Controlled IncrementByInteger)(_ ,(1, target)) , arrayControl);
    }
}
