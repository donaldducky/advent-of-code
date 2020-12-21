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
  .split('\n');

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  lines = lines
    .map(x => x.split(' (contains '))
    .map(x => [x[0].split(' '), x[1].replace(/\)$/, '').split(', ')]);
  console.log(lines);

  let allIngredients = lines.reduce((s, x) => {
    return x[0].reduce((acc, x) => {
      acc.add(x);
      return acc;
    }, s);
  }, new Set());
  console.log(allIngredients);

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

  console.log(mayContain);

  mayContain = Object.entries(mayContain);
  console.log(mayContain);

  let allergens = {};

  while (mayContain.length) {
    let newMayContains = [];
    for (let i = 0; i < mayContain.length; i++) {
      let [a, xs] = mayContain[i];
      console.log(a, xs, allergens);
      xs = xs.filter(x => !allergens[x]);
      console.log(a, xs, allergens);

      if (xs.length === 1) {
        allergens[xs[0]] = a;
      } else {
        newMayContains.push([a, xs]);
      }
    }
    mayContain = newMayContains;
  }

  console.log('allergens', allergens);
  const notAllergens = new Set(
    [...allIngredients].filter(x => !(x in allergens))
  );
  console.log(notAllergens);
  return lines
    .map(x => x[0])
    .flat()
    .filter(x => notAllergens.has(x)).length;
}

function part2(lines) {
  lines = lines
    .map(x => x.split(' (contains '))
    .map(x => [x[0].split(' '), x[1].replace(/\)$/, '').split(', ')]);
  console.log(lines);

  let allIngredients = lines.reduce((s, x) => {
    return x[0].reduce((acc, x) => {
      acc.add(x);
      return acc;
    }, s);
  }, new Set());
  console.log(allIngredients);

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

  console.log(mayContain);

  mayContain = Object.entries(mayContain);
  console.log(mayContain);

  let allergens = {};

  while (mayContain.length) {
    let newMayContains = [];
    for (let i = 0; i < mayContain.length; i++) {
      let [a, xs] = mayContain[i];
      console.log(a, xs, allergens);
      xs = xs.filter(x => !allergens[x]);
      console.log(a, xs, allergens);

      if (xs.length === 1) {
        allergens[xs[0]] = a;
      } else {
        newMayContains.push([a, xs]);
      }
    }
    mayContain = newMayContains;
  }

  console.log('allergens', allergens);
  const notAllergens = new Set(
    [...allIngredients].filter(x => !(x in allergens))
  );
  console.log(notAllergens);

  let k = Object.entries(allergens);
  k.sort((a, b) => {
    if (a[1] > b[1]) {
      return 1;
    } else if (a[1] < b[1]) {
      return -1;
    }

    return 0;
  });
  console.log(k);

  return k.map(x => x[0]).join(',');
}
