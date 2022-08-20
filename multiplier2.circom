// in circom first we define a circuits
// | |
// | |
//  V

pragma circom 2.0.0; // manage the vercuis

template Multiplier2() // temple define the shape of a new circuit called Multiplier2 
{
    signal input    a;
    signal input    b;
    signal output   o;

    o <== a * b; // we have a computation and constraints 
    // a*b is R1CS  quadratic equation
}

component main = Multiplier2();



//1. we need to compile the circuits
/////   commande: circom muliplier2.circom --r1cs --wasm --sym --c
////    --r1cs: it generates the file multiplier2.r1cs that contains the R1CS constraint system of the circuit in binary format.
///     --wasm: it generates the directory multiplier2_js that contains the Wasm code (multiplier2.wasm) and other files needed to generate the witness.
////    --sym : it generates the file multiplier2.sym , a symbols file required for debugging or for printing the constraint system in an annotated mode.
////    --c : it generates the directory multiplier2_cpp that contains several files needed to compile the C code to generate the witness.
// multiplier2.r1cs: all the equations are here
// multiplier2.sym: all the symbolic information
// multiplier2_cpp  multiplier2_js(wasm): help us in computing all the values of all the wires of our circuis




/// inside one of directories we create a input.json values that takes our circuits .the program will just compute just the output
/// output = 44 
// to generate all the values of the wires of this circuit we use wasm program

//  commande: node generate_witness.js multiplier2.wasm input.json witness.wtns
//      run generate_witness.js using multiplier2.wasm taking this input.json and storing all the value of all the wires in this witness.wtns(binary format to store all the values of all wires of our circuits)

// inside the c++ directorie we run a make file and after that "./multiplier2 input.json witness.wtns" and faster that the js files

//we have now a file with extension .wtns that contains all the computed signals and, a file with extension .r1cs that contains the constraints describing the circuit. Both files will be used to create our proof.

// we can test that the two witness are the same we use the commande:"sha256sum multiplier2_js(cpp)/witness.wtns"


// we need to create proofs with one proving system that is called groth16 (where there is a trusted setup per circuit )
// trusted setup consist of 2 parts:
// 1.the powers of tau, which is independent of the cercuit
// 2.the phase 2, which depends on the circuit




//(phase 1)
//commande : snarkjs powersoftau new bn128 12 pot12_0000.ptau -v (building to the 12 small circuits)
// this commande is gonna create the phase one of the trusted setup this phase is common for all the circuits
// we use snarkjs tool to generate and validate a proof for our input
// trusted setup is buit as multi-party computation with several people contributes and this gives more security because if one of the contrubutorsdoes it right then the result is oky

// snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v 

// (prepqring for phqse 2)

// command: snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
// its a optimization for doing computation later faster
// we doo all this steps independently of the compilation


// command: snarkjs groth16 setup multiplier2.r1cs pot12_final.ptau multiplier2_0000.zkey
// here we are using multiplier2.r1cs all these constraint all these equation that are forcing that the inputs and the outputs are related porabely
// this is generating some stuuf wich is the zk this all the previous cryptographic material merge with the these equations we create
// all the cryptographic material for the approver and the verifier


// we still need to generate the randomness of this second phasewhisv is specific for the circuits
// commande: snarkjs zkey contribute multiplier2_0000.zkey multiplier2_0001.zkey --name="1st contribution" -v
// multiplier2_0001.zkey: this key already contais the randomness and it is valid for the prover and the verifier

// commande: snarkjs zkey export verificationkey multiplier2_0001.zkey verification_key.json
// now we are exporting all the randomness and storing them in verification_key.json from this key multiplier2_0001.zkey

// and now we have two process one guy that will generate the proof and the other that gonna check that the proof is correct

//  first part generating the proof
//  command: snarkjs groth16 prove multiplier2_0001.zkey ./multiplier2_js/witness.wtns proof.json public.json
//  to generate the proof we need to provide multiplier2_0001.zkey that contains all the randomness the witness were we have all the values of the circuits and with this data we generate the proof.json and public.json

  

//  now we just need to verify the proof
//  snarkjs can generate smart contracts that also check this proofs
//  snarkjs verify verification_key.json public.json proof.json 













//
// circom muliplier2.circom --r1cs --wasm --sym --c we need to generate values  you will provide me all the input in the circuit and 
//  the compiler will generate the program that when we run it with input it will generate tha value for all the wires


// circom muliplier2.circom --r1cs --wasm --sym --c
//node generate_witness.js muliplier2.wasm input.json witness.wtns
//snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
//snarkjs powersoftau contribute pot12_0000.ptau --name="first contribute" -v
//snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="first contribution" -v
//snarkjs powersoftau prepare phase2 pot12_0001.ptau pot_final -v 
//snarkjs groth16 setup  muliplier2.r1cs pot_final muliplier2_0000.zkey
//snarkjs zkey contribute muliplier2_0000.zkey muliplier2_0001.zkey --name="1st contribute" -v 
//snarkjs zkey export verificationkey muliplier2_0001.zkey verification_key.json
//snarkjs groth16 prove muliplier2_0001.zkey witness.wtns proof.json public.json
//snarkjs groth16 prove muliplier2_0001.zkey ./muliplier2_js/witness.wtns proof.json public.json
//snarkjs groth16 verify verification_key.json public.json proof.json 

// circom produces like a lot of equations and then a lot of values for all the wires of our circuits and from this we need to produce the proof
//   used by the verifier to check that the cercuit that you know a valid input for the circuit the tools that come after circom is snarkjs and we gonna use ghroth16 system to prove
///  that you know the witness that the private input of a cercuits 
// //