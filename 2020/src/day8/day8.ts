import * as fs from 'fs';
import * as path from 'path';

let file = 'input.txt';
//file = 'sample.txt';
//file = 'sample2.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n')
  .map(l => l.split(' '));

console.log('Part 1:', part1(lines));
console.log('Part 2:', part2(lines));

function part1(lines) {
  return run(lines)[0];
}

function part2(lines) {
  for (let i = 0; i < lines.length; i++) {
    let [op] = lines[i];
    if (!['jmp', 'nop'].includes(op)) {
      continue;
    }
    // using [...lines] is a shallow clone...all the elements are references
    // ie. changing ops[i][0] = 'jmp' will modify it in lines and require resetting
    // deep clone array, is there a better way? this json business is slow
    let ops = JSON.parse(JSON.stringify(lines));
    ops[i][0] = op == 'jmp' ? 'nop' : 'jmp';
    const [acc, ip] = run(ops);
    if (ip >= ops.length) {
      return acc;
    }
  }
}

function run(ops) {
  let acc = 0;
  let ip = 0;
  let seen = new Set();

  while (!seen.has(ip)) {
    seen.add(ip);
    const [op, v] = ops[ip];
    switch (op) {
      case 'acc':
        acc += +v;
        ip++;
        break;
      case 'nop':
        ip++;
        break;
      case 'jmp':
        ip += +v;
        break;
    }
    if (ip >= ops.length) {
      break;
    }
  }

  return [acc, ip];
}
