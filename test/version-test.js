const assert = require("assert");
const fs = require("fs");
const path = require("path");
const { hello } = require("../src/index");

const packageJsonPath = path.join(__dirname, "..", "package.json");
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));

assert.strictEqual(hello("team"), "Hello, team!");
assert.ok(packageJson.version, "package.json version must exist");

console.log("All tests passed");