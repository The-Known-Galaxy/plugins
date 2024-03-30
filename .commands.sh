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