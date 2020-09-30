namespace Searching {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;

    // Note: this is Grover's algorithm

    @EntryPoint()
    operation RunGroverSearch(nItem : Int, markedItem : Int) : Int {
       let markedOracle = ApplyOracle(markedItem, _, _);
       let foundItem = SearchForMarked(markedOracle, nItem);
       Message($"Marked : {markedItem}, Found : {foundItem}");
       return foundItem;
    }

    operation ApplyOracle(
        markedItem : Int, 
        inputRegister :  Qubit[], 
        outputRegister : Qubit
    ) : Unit is Adj + Ctl 
    {
        (ControlledOnInt(markedItem, X))(inputRegister, outputRegister);
    }

    operation SearchForMarked(
        oracle : ((Qubit[], Qubit) => Unit is Adj), 
        nItems : Int
    ) : Int {
        using (inputRegister = Qubit[BitSizeI(nItems)]) {
            ApplyToEach(H, inputRegister);
            for (n in 0..nIterations(BitSizeI(nItems)) - 1) {
                ReflectAboutMarked(oracle, inputRegister);
                ReflectAboutUniform(inputRegister);
            }
            return MeasureInteger(LittleEndian(inputRegister));
        }
    }

    operation PrepareAllOnes(register : Qubit[]) : Unit
    is Adj + Ctl {
        ApplyToEachCA(X, register);
    }

    operation ReflectAboutAllOnes(register : Qubit[]) : Unit
    is Adj + Ctl {
        Controlled Z(Most(register), Tail(register));
    }

    operation ReflectAboutUniform(register : Qubit[]) : Unit
    is Adj + Ctl {
        within {
            Adjoint ApplyToEachCA(H, register);
            PrepareAllOnes(register);
        } apply {
            ReflectAboutAllOnes(register);
        } 
    }

    operation ReflectAboutMarked(
        oracle : ((Qubit[], Qubit) => Unit is Adj), 
        register : Qubit[]
    ) : Unit is Adj {
        using( output = Qubit()) {
            within {
                X(output);
                H(output);
            } apply {
                oracle(register, output);
            }
        }
    }

    function nIterations(nQubits : Int) : Int {
        let nItems = 1 <<< nQubits;                        
        let angle = ArcSin(1. / Sqrt(IntAsDouble(nItems)));
        let total = Round(0.25 * PI() / angle - 0.5);
        return total;
    }
}
