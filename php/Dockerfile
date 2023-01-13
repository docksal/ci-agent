FROM docksal/ci-agent:base-build

# Switch to root to install some system-wide stuff
USER root

RUN set -xe; \
	apk add --update --no-cache \
		mysql-client \
		php81 \
		php81-ctype \
		php81-curl \
		php81-dom \
		php81-gd \
		php81-json \
		php81-mbstring \
		php81-openssl \
		php81-pdo_mysql \
		php81-phar \
		php81-posix \
		php81-simplexml \
		php81-tokenizer \
		php81-xml \
		php81-xmlreader \
		php81-xmlwriter \
		php81-zlib; \
	rm -rf /var/cache/apk/*;

ENV COMPOSER_VERSION=2.5.1 \
	DRUSH_VERSION=8.4.11 \
	DRUPAL_CONSOLE_LAUNCHER_VERSION=1.9.7 \
	WPCLI_VERSION=2.6.0
RUN set -xe; \
	# Composer
	curl -fsSL "https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar" -o /usr/local/bin/composer; \
	# Drush 8 (default)
	curl -fsSL "https://github.com/drush-ops/drush/releases/download/${DRUSH_VERSION}/drush.phar" -o /usr/local/bin/drush; \
	# Drupal Console
	curl -fsSL "https://github.com/hechoendrupal/drupal-console-launcher/releases/download/${DRUPAL_CONSOLE_LAUNCHER_VERSION}/drupal.phar" -o /usr/local/bin/drupal; \
	# Install wp-cli
	curl -fsSL "https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar" -o /usr/local/bin/wp; \
	# Make all downloaded binaries executable in one shot
	(cd /usr/local/bin && chmod +x composer drush drupal wp);

# Switch back to user
USER $AGENT_USER
SHELL ["/bin/bash", "-c"]

ENV PATH $PATH:$AGENT_HOME/.composer/vendor/bin
# Don't use -x here, as the output may be excessive
RUN set -e; \
	\
	# Set drush8 as a global fallback for Drush Launcher
	echo -e "\n""export DRUSH_LAUNCHER_FALLBACK=/usr/local/bin/drush8" >> $AGENT_HOME/.profile; \
	# Composer based dependencies
	echo -e "\n"'export PATH="$PATH:$AGENT_HOME/.composer/vendor/bin"' >> $AGENT_HOME/.profile; \
	# Reload updated PATH from profile to make composer/drush/etc. visible below
	. $AGENT_HOME/.profile; \
	# Drupal Coder & WP Coding Standards w/ a matching version of PHP_CodeSniffer
	# Set allow-plugins. See https://getcomposer.org/allow-plugins
	composer global config allow-plugins.dealerdirect/phpcodesniffer-composer-installer true; \
	composer global require drupal/coder wp-coding-standards/wpcs phpcompatibility/phpcompatibility-wp; \
	# Don't fix the indentation or installed_paths will not be set correctly
	phpcs --config-set installed_paths \
$AGENT_HOME/.composer/vendor/drupal/coder/coder_sniffer/,\
$AGENT_HOME/.composer/vendor/wp-coding-standards/wpcs/,\
$AGENT_HOME/.composer/vendor/phpcompatibility/php-compatibility/PHPCompatibility/,\
$AGENT_HOME/.composer/vendor/phpcompatibility/phpcompatibility-wp/PHPCompatibilityWP,\
$AGENT_HOME/.composer/vendor/phpcompatibility/phpcompatibility-paragonie/PHPCompatibilityParagonieRandomCompat; \
	# Cleanup
	composer clear-cache
