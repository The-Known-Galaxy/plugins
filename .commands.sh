docsite() {
    echo "TOOL VERSIONS"
    echo "npm $(npm --version)"
    echo "moonwave $(./node_modules/.bin/moonwave --version)"
    echo "STARTING DOC SITE"
    ./node_modules/.bin/moonwave dev --code src
    echo "DOC SITE STOPPED"
}

plugins() {
    lune --version
    lune run main
}