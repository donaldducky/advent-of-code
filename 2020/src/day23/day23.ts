import * as fs from 'fs';
import * as path from 'path';

class Node {
  val: number;
  next: Node;
  constructor(val) {
    this.val = val;
  }

  toString() {
    return `Node { val: ${this.val}, next: ${this.next.val} }`;
  }
}

let file;
file = 'sample2.txt';
file = 'sample.txt';
file = 'input.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('')
  .map(x => +x);

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  console.log(lines);
  let nodes = lines.map(x => new Node(x));
  console.log(nodes);
  let current = nodes[0];
  console.log(current);
  for (let i = 0; i < nodes.length; i++) {
    nodes[i].next = nodes[(i + 1) % nodes.length];
  }
  let min = Math.min(...lines);
  let max = Math.max(...lines);
  console.log(`${current}`);
  for (let i = 0; i < 100; i++) {
    console.log(`-- move ${i + 1} --`);
    console.log('cups:', printList(current, lines.length));
    let pickup = current.next;
    let next = pickup;
    for (let j = 0; j < 3; j++) {
      next = next.next;
    }
    current.next = next;
    next.prev = current;
    //console.log('next:', next.val, next.prev.val);
    //console.log('current:', current.val, current.next.val);
    let pvals = [pickup.val, pickup.next.val, pickup.next.next.val];
    console.log('pick up:', pvals.join(', '));
    let dest = current.val;
    do {
      dest--;
      if (dest < min) dest = max;
    } while (pvals.includes(dest));
    console.log('destination:', dest);
    let dn = findNodeWithValue(current, dest);
    //console.log(dn.prev.val, dn.next.val);
    next = dn.next;
    dn.next = pickup;
    pickup.next.next.next = next;
    current = current.next;
    console.log();
  }

  console.log('-- final --');
  console.log('cups:', printList(current, lines.length));
  let n = findNodeWithValue(current, 1).next;
  let ns = [];
  do {
    ns.push(n.val);
    n = n.next;
  } while (n.val != 1);

  return ns.join('');
}

function part2(lines) {
  lines = lines.concat(
    new Array(1000000 + 1)
      .fill(0)
      .map((_, i) => i)
      .slice(lines.length + 1)
  );

  let nodes = lines.map(x => new Node(x));
  let nodeMap = nodes.reduce((m, n) => {
    m[n.val] = n;

    return m;
  }, {});
  let current = nodes[0];
  for (let i = 0; i < nodes.length; i++) {
    nodes[i].next = nodes[(i + 1) % nodes.length];
  }
  let min = 1;
  let max = 1000000;
  for (let i = 0; i < 10000000; i++) {
    //console.log(i);
    let pickup = current.next;
    let next = pickup;
    for (let j = 0; j < 3; j++) {
      next = next.next;
    }
    current.next = next;
    next.prev = current;
    let pvals = [pickup.val, pickup.next.val, pickup.next.next.val];
    let dest = current.val;
    do {
      dest--;
      if (dest < min) dest = max;
    } while (pvals.includes(dest));
    //let dn = findNodeWithValue(current, dest);
    let dn = nodeMap[dest];
    next = dn.next;
    dn.next = pickup;
    pickup.next.next.next = next;
    current = current.next;
  }

  //let n = findNodeWithValue(current, 1);
  let n = nodeMap[1];
  return n.next.val * n.next.next.val;
}

function printList(current, n) {
  let list = [`(${current.val})`];
  for (let i = 0; i < n - 1; i++) {
    current = current.next;
    list.push(current.val);
  }

  return list.join(', ');
}

function findNodeWithValue(c, v) {
  while (c.val !== v) {
    c = c.next;
  }

  return c;
}
