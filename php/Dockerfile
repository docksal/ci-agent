FROM docksal/ci-agent:base-build

# Switch to root to install some system-wide stuff
USER root

RUN set -xe; \
	apk add --update --no-cache \
		mysql-client \
		php7 \
		php7-ctype \
		php7-curl \
		php7-dom \
		php7-gd \
		php7-json \
		php7-mbstring \
		php7-openssl \
		php7-pdo_mysql \
		php7-phar \
		php7-posix \
		php7-simplexml \
		php7-tokenizer \
		php7-xml \
		php7-xmlreader \
		php7-xmlwriter \
		php7-zlib; \
	rm -rf /var/cache/apk/*;

ENV COMPOSER_VERSION=1.10.21 \
	DRUSH_VERSION=8.4.8 \
	DRUPAL_CONSOLE_LAUNCHER_VERSION=1.9.7 \
	WPCLI_VERSION=2.4.0
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

ENV PATH $PATH:$AGENT_HOME/.composer/vendor/bin
RUN set -xe; \
	# Add composer bin directory to PATH
	echo "\n"'PATH="$PATH:$AGENT_HOME/.composer/vendor/bin"' >> $AGENT_HOME/.profile; \
	# Drush modules
	drush dl registry_rebuild --default-major=7 --destination=$AGENT_HOME/.drush; \
	drush cc drush; \
	# Drupal Coder w/ a matching version of PHP_CodeSniffer
	composer global require drupal/coder; \
	phpcs --config-set installed_paths $AGENT_HOME/.composer/vendor/drupal/coder/coder_sniffer; \
	# Cleanup
	composer clear-cache;

# Cannot use variables with COPY --chown. See https://github.com/moby/moby/issues/35018
COPY --chown=agent:agent config/.drush $AGENT_HOME/.drush
