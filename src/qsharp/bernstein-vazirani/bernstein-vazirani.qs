namespace BernsteinVazirani {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arithmetic;


    @EntryPoint()
    operation RunBernsteinVazirani(secret : Int, nQubits : Int) 
    : Int {
        let oracle = DotProductOracle(secret);
        return ApplyBernsteinVazirani(oracle, nQubits);
    }

    operation ApplyBernsteinVazirani(
        oracle : ((Qubit[],Qubit) => Unit is Adj + Ctl),
        n : Int
    ) : Int {
        using ((queryRegister, target) = (Qubit[n], Qubit())) {
            within {
                ApplyToEach(H, queryRegister);
                X(target);
                H(target); 
                //After these steps the registers are: |+++++..++>|->
            } apply {
                oracle(queryRegister, target);
            }
            return MeasureInteger(LittleEndian(queryRegister));
        }
    }

    operation ApplyDotProductOracle(s : Int, x : Qubit[], target : Qubit) 
    : Unit is Adj + Ctl {
        Fact(Length(x)>=BitSizeI(s), "The query register is not big enough to hold the secret.");

        let secretString = IntAsBoolArray(s, Length(x));
        ApplyToEach(CControlled(CNOT(_,target)), Zip(secretString, x));
    }

    function DotProductOracle(s : Int) : ((Qubit[],Qubit) => Unit is Adj + Ctl) {
        return ApplyDotProductOracle(s, _, _);
    }


}
