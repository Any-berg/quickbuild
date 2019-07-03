<?php // --> /var/www/html/register.php
  
require 'vendor/autoload.php';
use Auth0\SDK\Auth0;
use josegonzalez\Dotenv\Loader;

// load secrets that are not for version control; if missing, inform how to add
if (!file_exists('.env')) {
    header($_SERVER['SERVER_PROTOCOL'].' 404 Not Found', true, 404);
    $information = <<<HTML
get your application variables from <a href='https://auth0.com'>Auth0</a><br/>
save them in <code>/var/www/html/.env</code> (see <a href="https://raw.githubusercontent.com/Any-berg/quickbuild/master/.env.default">example</a>)<br/>
<b>REMEMBER</b> to <code>chown www-data .env</code> and <code>chmod 400 .env</code>
HTML;
    exit($information);
}
$loader = new Loader([
  __DIR__ . '/.env',
  __DIR__ . '/.env.default'
]);
$loader->parse()->putenv(true);

// construct AUTH0_REDIRECT_URI from current one, as they should be identical
$auth0_redirect_uri = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://{$_SERVER['HTTP_HOST']}{$_SERVER['REQUEST_URI']}";

// contact authenticator for user information and login if new session is needed
$auth0 = new Auth0([
  'domain' => getenv('AUTH0_DOMAIN'),
  'client_id' => getenv('AUTH0_CLIENT_ID'),
  'client_secret' => getenv('AUTH0_CLIENT_SECRET'),
  'redirect_uri' => $auth0_redirect_uri,
  'scope' => 'openid email',
]);
$userInfo = $auth0->getUser();
if (empty($userInfo)) {
    $auth0->login();
}// else

$single_signon_header = getenv('SINGLE_SIGNON_HEADER');

// if email address is OK, use it to sign to QuickBuild; else show Forbidden
preg_match(getenv('EMAIL_PATTERN'), $userInfo['email'], $matches);
if (!empty($matches))
  echo <<<HTML
    <html>
      <body>
        <script language="javascript">
var xhr = new XMLHttpRequest();
xhr.open('GET', '/', true); // asynchronous
xhr.onreadystatechange = function (aEvt) {
  if (xhr.readyState == 4) {
    if(xhr.status == 200)
      window.location = '/';
     else
      alert("Error "+xhr.status); //TODO: improve error handling
  }
};
xhr.setRequestHeader('$single_signon_header', '{$matches[0]}');
xhr.send();
        </script>
      <body>
    </html>
HTML;
else
  header($_SERVER['SERVER_PROTOCOL'].' 403 Forbidden', true, 403);

// https://auth0.com/docs/libraries/auth0-php
// https://github.com/josegonzalez/php-dotenv
// https://stackoverflow.com/questions/6768793/get-the-full-url-in-php
?>
