<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

define('WP_SITEURL', 'http://' . $_SERVER['SERVER_NAME'] . '/wordpress');
define('WP_HOME',    'http://' . $_SERVER['SERVER_NAME']);
define('WP_CONTENT_DIR', $_SERVER['DOCUMENT_ROOT'] . '/wp-content');
define('WP_CONTENT_URL', 'http://' . $_SERVER['SERVER_NAME'] . '/wp-content');

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wordpress');

/** MySQL database username */
define('DB_USER', 'admin');

/** MySQL database password */
define('DB_PASSWORD', 'takeTheDreadfort');

/** MySQL hostname */
define('DB_HOST', 'wordpress-db.cfiwx4n8dww1.us-west-2.rds.amazonaws.com:3306');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY', 'G||Ehc4g |+]Mq|UoJ4m$`}A%NWmI0~M~#.AZu^aW9!|<yLZK73*s:4Q!7 wQa!C');
define('SECURE_AUTH_KEY', 'B|I(+rnb9-}gIXg:%TtD|{^w2]8Df@s@+3 ?HEwZP3*I?1N`+PY_cGuLl_2-2cX2');
define('LOGGED_IN_KEY', 's]=GY3Brapkf4zhKqwy~V.PWgH~+<kLtj@|}vOJfLpX7<SrC +P.++M{l+N{#l?#');
define('NONCE_KEY', '*e6bHKT&Eh;&+#LVS-;SUMgLm5.?nB@{i9a)KS1Jf){(}hD,25ot|U$N`{-}FE|Q');
define('AUTH_SALT', 'Uw#yt$($?C~[^}-HJh=+NXv]#yaFGb7lziZRGz&Mx52;NoU`hUMb13M&tM <omk]');
define('SECURE_AUTH_SALT', 'D|;k_])FKlmaxpvvpTtSdv+pG@F8k(+j-B$P,Zg$dR-1i_o.cjx5iLs&FyQ>9C7*');
define('LOGGED_IN_SALT', 'KBW%78(>VBG!4%.zNBa+EiwP~T-s2Ejnbu28Ix6TarGs]X|d+-Vi8|Y|6.N0.rd5');
define('NONCE_SALT', '7+)__d^GdS+A{sr 5zd5-$O>T8;O (SI{h?0/gC/dc|%-`%8Km{u>-F[&tW+-Z+b');

define('WP_CACHE_KEY_SALT', 'n/sI &AKkK7sUhoiZ+cz@/--*bLmqV65Pq^VN`1rgFeC:5<T}7y)#3:|F+Yv *m.');
define('WP_CACHE', true);
define('WP_REDIS_HOST', 'web-elasticache.xxg6ca.0001.usw2.cache.amazonaws.com');
define('WP_REDIS_CLIENT', 'pecl');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
