run_unit_tests() {
    echo "TOOL VERSIONS"
    rojo --version
    rit --version
    echo "BUILDING PLACE"
    rit build -p default
    echo "RUNNING UNIT TESTS"
    run-in-roblox --place build/default.rbxl --script run-unit-tests.luau
    echo "TEST RUNNING FINISHED"
}

run_static_analysis() {
    echo "TOOL VERSIONS"
    selene --version
    echo "RUNNING STATIC ANALYSIS"
    selene --display-style Rich src lune
    echo "STATIC ANALYSIS FINISHED"
}

run_docsite() {
    echo "TOOL VERSIONS"
    echo "npm $(npm --version)"
    echo "moonwave $(./node_modules/.bin/moonwave --version)"
    echo "STARTING DOC SITE"
    ./node_modules/.bin/moonwave dev --code src
    echo "DOC SITE STOPPED"
}

run() {
    lune --version
    lune run main
}