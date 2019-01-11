class TigerTamer::Action::InstallPostGIS
  pattr_initialize :conn

  def install
    if has_extension?
      logger.debug('postgis extension already installed.')
    else
      logger.info('Installing postgis extension.')
      conn.exec(%|CREATE EXTENSION IF NOT EXISTS postgis|)
    end
  end

  private

  def has_extension?
    logger.debug('Checking for postgis extension.')

    !!conn
      .exec(%|SELECT true AS exists FROM pg_extension WHERE extname = 'postgis'|)
      .first
  end
end
