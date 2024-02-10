import { BarretenbergBackend } from '@noir-lang/backend_barretenberg';
import { Noir } from '@noir-lang/noir_js';
import rec_test_circuit from './rec_test_circuit/target/rec_test_circuit.json';

document.addEventListener('DOMContentLoaded', async () => {
  const backend = new BarretenbergBackend(rec_test_circuit);
  const noir = new Noir(rec_test_circuit, backend);
  const input = { x: 1, y: 2 };
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
}
