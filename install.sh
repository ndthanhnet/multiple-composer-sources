# !/bin/bash
COMPOSER="$(which composer)"

# include parts for environment initialization
function execute() {
    LOCALSRC='./local-src'
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

    # verify composer is installed, prioritize local composer.phar
    if [ -f "./composer.phar" ]; then
        COMPOSER="php ./composer.phar"
        echo $COMPOSER
    else
        echo $PWD
        if [ -z "$COMPOSER" ]; then 
            echo "composer not found, please install composer or place composer.phar in Magento webroot directory";
            exit;
        fi
    fi  

    # create local-src if not exist
    if [ ! -d "$LOCALSRC" ]; then
        mkdir -p $LOCALSRC
    fi

    # make sure PACKAGES is not empty
    if [ -z "$PACKAGES" ]; then
        echo "no packages given, please provide packages to install";
        exit;
    fi

    # download subrepo.sh
    if [ ! -f "$LOCALSRC/subrepo.sh" ]; then
        curl -o $LOCALSRC/subrepo.sh https://raw.githubusercontent.com/ndthanhnet/multiple-composer-sources/main/subrepo.sh
    fi

    # configure local src repository and pre-install-cmd for webroot composer.json
    echo "$COMPOSER config repositories.local-src path \"local-src/$SUBDIR/vendor/*/*\""
    $COMPOSER config repositories.local-src path "local-src/$SUBDIR/vendor/*/*"
    echo "$COMPOSER config scripts.pre-install-cmd \"bash local-src/subrepo.sh $SUBDIR $PUBLIC_KEY $PRIVATE_KEY $PACKAGES\""
    $COMPOSER config scripts.pre-install-cmd "bash local-src/subrepo.sh $SUBDIR $PUBLIC_KEY $PRIVATE_KEY $PACKAGES"
}

execute $@
