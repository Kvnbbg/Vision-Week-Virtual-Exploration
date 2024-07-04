{pkgs}: {
  deps = [
    pkgs.php
    pkgs.php82Packages.composer
    pkgs.phpunit
    pkgs.php83Packages.deployer
    pkgs.php82Extensions.dom
    pkgs.php82Extensions.pdo_pgsql
    pkgs.php82Extensions.pdo_sqlsrv
    pkgs.emacsPackages.sqlite3
  ];
}