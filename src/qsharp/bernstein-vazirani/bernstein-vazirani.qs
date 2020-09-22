namespace BernsteinVazirani {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;

    //TODO: Implement the oracle!

    operation ApplyBV(
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

}
