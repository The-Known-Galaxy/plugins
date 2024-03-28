# plugins
Plugin development for The Known Galaxy on ROBLOX.

# Documentation
Below are links to all documentation relevant to the tooling this project uses.
- [TestEZ](https://roblox.github.io/testez/)
- [Selene](https://kampfkarren.github.io/selene/selene.html)
- [Bash Scripting](https://devhints.io/bash)
- [Lune](https://lune-org.github.io/docs)
- [Luau](https://luau-lang.org/)
- [Moonwave](https://eryn.io/moonwave/)

# Development Workflow

## Getting Started
1. Ensure you have [Node.js 14+](https://nodejs.org/en) installed.
2. Ensure you have [aftman](https://github.com/LPGhatguy/aftman) installed.
3. Run
```sh
aftman install
```
4. Run
```sh
wally install
```
5. Run
```sh
npm install
```

## Developing
Before any development can occur, ensure you run:
```sh
source .commands.sh
```
Then, to get in-depth developer help from a docsite, run:
```sh
run_docsite
```

### Running Unit Tests
After sourcing commands, run:
```sh
run_unit_tests
```

### Static Analysis & Formatting
After sourcing commands, run:
```sh
run_static_analysis
```

## Deploying
TODO