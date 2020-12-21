import * as fs from 'fs';
import * as path from 'path';

let file;
file = 'sample2.txt';
file = 'sample.txt';
file = 'input.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n')
  .map(x => x.split(' (contains '))
  .map(x => [x[0].split(' '), x[1].replace(/\)$/, '').split(', ')]);

let mayContain = lines.reduce((acc, x) => {
  return x[1].reduce((acc, a) => {
    if (!(a in acc)) {
      acc[a] = x[0];
    } else {
      acc[a] = acc[a].filter(v => x[0].includes(v));
    }

    return acc;
  }, acc);
}, {});

let entries: [string, string[]][] = Object.entries(mayContain);
let allergens = {};
while (entries.length) {
  /* how to get rid of newMayContains intermediate value?
   * entries will become empty, how to make this typescript stuff work?
  entries = entries
    .map(([a, xs]) => [a, xs.filter(x => !allergens[x])])
    .filter(([a, xs]) => {
      if (xs.length === 1) {
        allergens[xs[0]] = a;
        return false;
      }
      return true;
    });
    */
  let newMayContains = [];
  for (let i = 0; i < entries.length; i++) {
    let [a, xs] = entries[i];
    xs = xs.filter(x => !allergens[x]);

    if (xs.length === 1) {
      allergens[xs[0]] = a;
    } else {
      newMayContains.push([a, xs]);
    }
  }
  entries = newMayContains;
}

let p1 = part1(lines, allergens);
console.log('Part 1:', p1);
let p2 = part2(allergens);
console.log('Part 2:', p2);

function part1(lines, allergens) {
  let allIngredients = new Set([...lines.flatMap(x => x[0])]);
  const notAllergens = new Set(
    [...allIngredients].filter(x => !(x in allergens))
  );

  return lines
    .map(x => x[0])
    .flat()
    .filter(x => notAllergens.has(x)).length;
}

function part2(allergens) {
  let k = Object.entries(allergens);
  k.sort((a, b) => {
    if (a[1] > b[1]) {
      return 1;
    } else if (a[1] < b[1]) {
      return -1;
    }

    return 0;
  });

  return k.map(x => x[0]).join(',');
}
