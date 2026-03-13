function hello(name = "world") {
  return `Hello, ${name}!`;
}

if (require.main === module) {
  console.log(hello("demo-repo"));
}

module.exports = { hello };