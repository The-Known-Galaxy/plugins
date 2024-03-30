docsite() {
    echo "TOOL VERSIONS"
    echo "npm $(npm --version)"
    echo "moonwave $(./node_modules/.bin/moonwave --version)"
    echo "STARTING DOC SITE"
    ./node_modules/.bin/moonwave dev --code src
    echo "DOC SITE STOPPED"
}

docsuite_build() {
    echo "TOOL VERSIONS"
    echo "npm $(npm --version)"
    echo "moonwave $(./node_modules/.bin/moonwave --version)"
    echo "BUILDING DOC SITE AND PUBLISHING"
    ./node_modules/.bin/moonwave build --publish --out-dir moonwave_build
    echo "DOC SITE BUILT"
}

plugins() {
    lune --version
    lune run main
}