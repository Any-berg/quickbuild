<?php // /var/www/html/register.php
  
require 'vendor/autoload.php';
use Auth0\SDK\Auth0;
use josegonzalez\Dotenv\Loader;

if (!file_exists('.env')) {
    header($_SERVER['SERVER_PROTOCOL'].' 404 Not Found', true, 404);
    exit("set environment vars for <a href='https://auth0.com'>Auth0</a>");
}

// load environment vars from outside of version control
$Dotenv = new Loader('.env');
$Dotenv->parse()->putenv(true);

$auth0 = new Auth0([
  'domain' => getenv('AUTH0_DOMAIN'),
  'client_id' => getenv('AUTH0_CLIENT_ID'),
  'client_secret' => getenv('AUTH0_CLIENT_SECRET'),
  'redirect_uri' => getenv('AUTH0_REDIRECT_URI'),
  'scope' => 'openid email',
]);

$userInfo = $auth0->getUser();
if (empty($userInfo)) {
    $auth0->login();
}

setcookie('email', $userInfo['email'], time() + 10, '/');
header("Location: /"); // /?email=".urlencode($userInfo['email']));

// https://auth0.com/docs/libraries/auth0-php
?>
