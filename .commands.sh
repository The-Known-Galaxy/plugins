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
    selene --version
    selene --display-style Rich src lune
}