use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Nick::Audio::FAAD',
    VERSION_FROM        => 'lib/Nick/Audio/FAAD.pm',
    AUTHOR              => 'Nick Peskett',
    LIBS                => [ '-lfaad' ],
    DEFINE              => '-DINCLUDE_NEAACDEC_H',
    TEST_REQUIRES       => {
        'Test::More' => 0,
        'MIME::Base64' => 0,
        'Digest::MD5' => 0
    }
);
