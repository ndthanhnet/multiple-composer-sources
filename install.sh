# !/bin/bash
# manage sub repositories with givent key and packages
DIR="${BASH_SOURCE%/*}"
COMPOSER="$(which composer)"

# include parts for environment initialization
function execute() {
    LOCALSRC='local-src'
    SUBDIR=$1
    PUBLIC_KEY=$2
    PRIVATE_KEY=$3
    shift 3
    PACKAGES=$@

    # verify current webroot directory
    if [ ! -f "./composer.json" ]; then
        echo "please run this script from Magento webroot directory";
        exit;
    fi

    # create local-src if not exist
    if [ ! -d "$DIR/$LOCALSRC" ]; then
        mkdir -p $DIR/$LOCALSRC
    fi

    # make sure PACKAGES is not empty
    if [ -z "$PACKAGES" ]; then
        echo "no packages given, please provide packages to install";
        exit;
    fi

    # download subrepo.sh
    if [ ! -f "$DIR/$LOCALSRC/subrepo.sh" ]; then
        curl -o $DIR/$LOCALSRC/subrepo.sh https://raw.githubusercontent.com/ndthanhnet/multiple-composer-sources/main/subrepo.sh
    fi

    # configure local src repository and pre-install-cmd for webroot composer.json
    $COMPOSER config repositories.local-src path "local-src/$SUBDIR/vendor/*/*"
    $COMPOSER config scripts.pre-install-cmd "bash local-src/subrepo.sh $SUBDIR $PUBLIC_KEY $PRIVATE_KEY $PACKAGES"
}

execute $@
