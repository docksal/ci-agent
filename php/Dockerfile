FROM docksal/ci-agent:base-build

# Switch to root to install some system-wide stuff
USER root

RUN set -xe; \
	apk add --update --no-cache \
		mysql-client \
		php82 \
		php82-ctype \
		php82-curl \
		php82-dom \
		php82-gd \
		php82-json \
		php82-mbstring \
		php82-openssl \
		php82-pdo_mysql \
		php82-phar \
		php82-posix \
		php82-simplexml \
		php82-tokenizer \
		php82-xml \
		php82-xmlreader \
		php82-xmlwriter \
		php82-zlib; \
	rm -rf /var/cache/apk/*;

ENV COMPOSER_VERSION=2.7.1 \
	DRUSH_VERSION=8.4.12 \
	DRUPAL_CONSOLE_LAUNCHER_VERSION=1.9.7 \
	WPCLI_VERSION=2.10.0
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
