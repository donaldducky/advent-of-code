import * as fs from 'fs';
import * as path from 'path';

let file;
file = 'sample.txt';
file = 'sample2.txt';
file = 'input.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n');

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  return lines
    .reduce(
      ([mask, mem], line) => {
        if (line.match(/mask/)) {
          mask = line
            .replace('mask = ', '')
            .split('')
            .map((b, i) => [b, i])
            .filter(([b]) => b !== 'X');
          //console.log('mask', mask);
        } else {
          const [addr, val] = line
            .replace(/mem\[(\d+)] = (\d+)/, '$1 $2')
            .split(' ');
          const bitStr = (+val).toString(2).padStart(36, '0');
          const bits = bitStr.split('');
          const masked = mask
            .reduce((bits, [bit, idx]) => {
              bits[idx] = bit;
              return bits;
            }, bits)
            .join('');
          //console.log('mem', addr, val, bitStr, masked, parseInt(masked, 2));
          mem[addr] = parseInt(masked, 2);
        }

        return [mask, mem];
      },
      [[], []]
    )[1]
    .reduce((a, b) => a + b, 0);
}

function part2(lines) {
  const [mask, mem] = lines.reduce(
    ([mask, mem], line) => {
      if (line.match(/mask/)) {
        mask = line
          .replace('mask = ', '')
          .split('')
          .map((b, i) => [b, i])
          .filter(([b]) => b !== '0')
          .reduce(
            ([xs, ones], [b, i]) => {
              if (b === 'X') {
                xs.push(i);
              } else {
                ones.push(i);
              }

              return [xs, ones];
            },
            [[], []]
          );
      } else {
        const [addr, val] = line
          .replace(/mem\[(\d+)] = (\d+)/, '$1 $2')
          .split(' ');

        const bitStr = (+addr).toString(2).padStart(36, '0');
        const [xs, ones] = mask;
        const masked = ones
          .reduce((bits, i) => {
            bits[i] = '1';
            return bits;
          }, bitStr.split(''))
          .join('');
        const addrs = xs
          .reduce(
            (addrs, i) => {
              return addrs.reduce((addrs, addr) => {
                const a0 = [...addr];
                const a1 = [...addr];
                a0[i] = '0';
                a1[i] = '1';
                addrs.push(a0);
                addrs.push(a1);

                return addrs;
              }, []);
            },
            [masked.split('')]
          )
          .map(x => parseInt(x.join(''), 2));
        //console.log(bitStr, masked, addrs);
        addrs.forEach(addr => {
          //console.log(addr, val);
          mem[addr] = +val;
        });
        //console.log(mem);
      }

      return [mask, mem];
    },
    // initializing mem to an array and using reduce on that doesn't work and is super slow
    // probably because it's a sparse array and some other weird reason
    // [[], []]
    [[], {}]
  );

  /*
  let sum = 0;
  for (const i in mem) {
    sum += mem[i];
  }

  return sum;
  */
  return Object.values(mem)
    .map(n => +n)
    .reduce((a, b) => a + b, 0);
}
