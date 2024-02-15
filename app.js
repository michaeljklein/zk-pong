import { BarretenbergBackend } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import rec_test_circuit from './rec_test_circuit/target/rec_test_circuit.json';
import input_json from './rec_test_circuit/Prover.json';

document.addEventListener('DOMContentLoaded', async () => {
  const backend = new BarretenbergBackend(rec_test_circuit);
  const noir = new Noir(rec_test_circuit, backend);

  // const input = { x: 1, y: 2 };
  // (toml2json --pretty Prover.toml > Prover.json)
  const input = input_json; // parse(readFileSync('./rec_test_circuit/Prover.toml', 'utf-8'));
  console.log('input', input);

  display('logs', 'Generating proof... ⌛');
  const proof = await noir.generateFinalProof(input);
  display('logs', 'Generating proof... ✅');
  display('results', proof.proof);
  display('logs', 'Verifying proof... ⌛');
  const verification = await noir.verifyFinalProof(proof);
  if (verification) display('logs', 'Verifying proof... ✅');
});

function display(container, msg) {
  const c = document.getElementById(container);
  const p = document.createElement('p');
  p.textContent = msg;
  c.appendChild(p);
  console.log(container, msg);
}
