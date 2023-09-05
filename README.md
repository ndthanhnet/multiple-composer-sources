## Multiple Composer Sources
This utility helps you to install packages from same domain using multiple usernames and password

## User cases
- Using multiple Magento 2 marketplace accounts with composer in the same installation

## How it works
- It create a directory name `local-src` in Webroot directory if not exist
- download subrepo.sh script to `local-src/`
- configure webroot composer.json to support package installation from `local-src` and configure composer [scripts.pre-install-cmd](https://getcomposer.org/doc/articles/scripts.md#command-events) to run subrepo.sh script prior to `composer install`
- subrepo.sh script will create sub directory under `local-src` and download packages there using the other Magento 2 marketplace account
- `composer install` execution inside webroot will check for available packages from previous step to install them inside vendor/ directory

## Installation
- cd to project webroot directory
- execute below command 
```
curl -o- https://raw.githubusercontent.com/ndthanhnet/multiple-composer-sources/main/install.sh | bash  -s -- arg_subdir arg_public_key arg_private_key arg_packages
```

Arguments : 

- arg_subdir :  name of sub directory under `local-src`
- arg_public_key : public key of the other Magento 2 Marketplace account
- arg_private_key : private key of the other Magento 2 Marketplace account
- arg_packages : list of packages to install, separate by space

example 
```
curl -o- https://raw.githubusercontent.com/ndthanhnet/multiple-composer-sources/main/install.sh | bash -s -- jajuma d8cf8877e7e04b12635a2c16f43c05b0 2adc070b740241aefc92c61ff9c403e0 jajuma/bfcache jajuma/pagepreload jajuma/assetpreload
```
