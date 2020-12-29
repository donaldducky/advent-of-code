import * as fs from 'fs';
import * as path from 'path';
import { inspect } from 'util';

let file;
file = 'sample.txt';
file = 'input.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n');

lines[0] = lines[0] + ` An elerium generator.  An elerium-compatible microchip.  A dilithium generator.  A dilithium-compatible microchip.  `;

let floors = lines.map(x => {
  return (x.match(/(\w+-compatible microchip|\w+ generator)/g) || [])
    .map(x => x.replace(/(\w{2})\w+(\-compatible)? (\w)\w+/, "$1-$3")/*.split('-')*/);
});

type State = [number, string[][]];

let floor = 0;
let state: State = [floor, floors];

//console.log(inspect(state, false, null, true));
//console.log(hashState(state));
let edges = getEdges(state);
//console.log(inspect(edges, false, null, true));

const n = floors.length;
let goal: State = [n - 1, new Array(n).fill([])];
goal[1][n - 1] = floors.flat();

//console.log(hashState(goal));

let open = [];
let seen = new Set();
seen.add(hashState(state));
open.push(state);
let steps = 0;
let found = false;
let c = 0;

while (!found) {
  let open2 = [];
  c += open.length;
  while (open.length) {
    let v = open.shift();
    //console.log('considering', hashState(v));
    if (hashState(v) == hashState(goal)) {
      console.log('Part 2:', steps);
      console.log('open count:', c);
      found = true;
      break;
    }
    getEdges(v).forEach(e => {
      if (!seen.has(hashState(e))) {
        //console.log('adding', hashState(e));
        seen.add(hashState(e));
        open2.push(e);
      }
    });
  }
  steps++;
  open = open2;
  //console.log();
}

function hashState([floor, floors]: State): String {
  let mapping = floors.reduce((acc, items, n) => {
    items.map(item => item.split('-')).forEach(([k, t]) => {
      if (!(k in acc)) {
        acc[k] = {};
      }
      acc[k][t] = n;
    });

    return acc;
  }, {});
  //console.log(mapping);
  let pairs = Object.values(mapping).map(({g, m}) => [g, m].join('-'));
  //console.log(pairs);
  pairs.sort();
  //console.log(pairs);

  //floors.forEach(x => x.sort());

  return JSON.stringify([floor, pairs]);
}

function getEdges(s: State): State[] {
  const [floor, floors] = s;
  const n = floors.length;
  let validFloors = [];
  if (floor - 1 >= 0 && floors.slice(0, floor).find(items => items.length)) {
    validFloors.push(floor-1);
  }
  if (floor + 1 < n) {
    validFloors.push(floor + 1);
  }

  const items = floors[floor];
  const nItems = floors[floor].length;

  let edges = validFloors.reduce((edges, nextFloor) => {
    for (let i = 0; i < nItems; i++) {
      edges.push(nextState(s, nextFloor, [items[i]]));
      for (let j = i + 1; j < nItems; j++) {
        edges.push(nextState(s, nextFloor, [items[i], items[j]]));
      }
    }

    return edges;
  }, []);

  return edges.filter(s => isValid(s, floor))
}

function nextState([cur, floors]: State, next, itemsToMove) {
  // deep copy
  let newFloors = JSON.parse(JSON.stringify(floors));
  //console.log(itemsToMove);
  newFloors[cur] = newFloors[cur].filter(x => !itemsToMove.includes(x));
  newFloors[next] = newFloors[next].concat(itemsToMove);

  return [
    next,
    newFloors
  ];
}

function isValid([cur, floors]: State, prev) {
  return isValidFloor(floors[cur]) && isValidFloor(floors[prev]);
}

function isValidFloor(items) {
  let [chips, generators] = items.reduce(([cs, gs], item) => {
    if (item.match('-g')) {
      gs.push(item.replace('-g', ''));
    } else if (item.match('-m')) {
      cs.push(item.replace('-m', ''));
    }

    return [cs, gs];
  }, [[], []]);

  if (chips.length === 0 || generators.length === 0) {
    return true;
  }

//  console.log('is valid floor', items);
//  console.log(chips, generators);

  // remove shielded, anything left = incompatible
  if (chips.find(x => !generators.includes(x))) {
    return false;
  }

  return true;
}
