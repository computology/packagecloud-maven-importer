module Packagecloud
  module Maven
    module Importer
      PATTERNS =  {
        Mustermann.new('/*/:artifact_id/:version/:name_version.aar') => 'aar',
        Mustermann.new('/*/:artifact_id/:version/:name_version.aar.md5') => 'aar_md5',
        Mustermann.new('/*/:artifact_id/:version/:name_version.aar.sha1') => 'aar_sha1',
        Mustermann.new('/*/:artifact_id/:version/:name_version.aar.asc') => 'aar_asc',

        Mustermann.new('/*/:artifact_id/:version/:name_version.apk') => 'apk',
        Mustermann.new('/*/:artifact_id/:version/:name_version.apk.md5') => 'apk_md5',
        Mustermann.new('/*/:artifact_id/:version/:name_version.apk.sha1') => 'apk_sha1',
        Mustermann.new('/*/:artifact_id/:version/:name_version.apk.asc') => 'apk_asc',

        Mustermann.new('/*/:artifact_id/:version/:name_version.war') => 'war',
        Mustermann.new('/*/:artifact_id/:version/:name_version.war.md5') => 'war_md5',
        Mustermann.new('/*/:artifact_id/:version/:name_version.war.sha1') => 'war_sha1',
        Mustermann.new('/*/:artifact_id/:version/:name_version.war.asc') => 'war_asc',

        Mustermann.new('/*/:artifact_id/:version/:name_version.jar') => 'jar',
        Mustermann.new('/*/:artifact_id/:version/:name_version.jar.md5') => 'jar_md5',
        Mustermann.new('/*/:artifact_id/:version/:name_version.jar.sha1') => 'jar_sha1',
        Mustermann.new('/*/:artifact_id/:version/:name_version.jar.asc') => 'jar_asc',

        Mustermann.new('/*/:artifact_id/:version/:name_version.pom') => 'pom',
        Mustermann.new('/*/:artifact_id/:version/:name_version.pom.md5') => 'pom_md5',
        Mustermann.new('/*/:artifact_id/:version/:name_version.pom.sha1') => 'pom_sha1',
        Mustermann.new('/*/:artifact_id/:version/:name_version.pom.asc') => 'pom_asc',
      }
    end
  end
end
