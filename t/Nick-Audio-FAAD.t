use strict;
use warnings;

use Test::More tests => 10;

use MIME::Base64 'decode_base64';
use Digest::MD5 'md5_base64';

BEGIN {
    use_ok( 'Nick::Audio::FAAD' );
};

my @data = map(
    decode_base64( $_ ),
    "3gQAAGxpYmZhYWMgMS4yOAAAApwvImgwFgoInjIrFVWTx7Xa5JIkSSIkkq8kUix/yf+T/yfnPzn5\nz85+c/zLbff/438+GE3yYG0MDfL5fLj8ovlFxi4xcYoooooooooooiiiiEUUQiiiKKKKIatWo1at\nUDVqgNWrUGrVqDVq1QDVq1agatQDVq1aoA1QAGrUAGrVAANWoAEAqFQQQAAVqAKgCECACFUFUAHA\n",
    "ASQXiOgqDIUCSxCQxoVlZuvHf8f5+utXdy4tckWugic527qhz/T6efn5+fa9qNzn80apu873O888\n88888888888888x55mvWeeY888Hnnhr1za9czXLXJrmk1z+GuYw2tIkHCySU0hNliCYWkStOwCwE\niQSAAJyAIpAULAACioIgACABUAC4AOA=\n",
    "ASAXiEh6DIWCgiSJiCMVSs3nPjn+P9/jqau5ckkkk1kq6vFt977xQ5ubtu27btu27btnfmn463mR\n+Ne8a9PPPPPPPPPPPPPPPOqedW/e372/fdv33b992/eonnVPPTepde928XKb6b1IDArAYFF6oKIl\nVBReoRbwAXFAADEgBUUALAYrgAEBUAAVAAAgADg=\n",
    "ARgXiCgiKgaEgSWJSEMU33m9875/r/t8da1d3clrkuRrahbnfje6Dn7Xte/v7+/v4mJzvlR/xPL9\ns0vPPPPPPPPPPPPPPPPMeeZr1tetr1za9c2vXM8lKUseYxmuckmuaWsklrCTrNNOQsEhkDERhJYI\n1KkwWAIQAExAkFiaAAUCYAEgAAiATAAAiA4=\n",
    "ARIXiTQlCSxIQRm53m83z3n9v9/bzrV3dyXJLtZQZqc+N53Qa+np6enp6en9G984U70bh+jdFFFF\nFFFFFFFFFFFFFBqKDbNjZsbNkWzZFRQteyMYtmxG2zYtG17RsRRjEWdpzUCPda5QmLJCRNagLLog\nJATREwXyAAlcAUiAQAEQAAJgACYAXA4=\n",
    "AR4XiEh4DIWCgiSIiIMlTMze+8/4/2+/V3q5ckkkuLpJlSX43zvKocePo+j6Po+j6PQ4n8/q06UF\nOpl6mWKKKKKKKKKKKKKKKIooi1amrUiiIRREIoiEURIKuqqurVDUVrVCBqhApWoqhCtKoFoFSChU\nKlBdqVAABSoALWAICoAXBQAEQAKAAACQAiA4\n",
    "ASIXiMg4DIWCgiSIyCISCMlMzG+8/4/2+/U1dy5JJJIsJWqne8zurGvX9N27d0XovRY38fqkaBQe\nqm6qaiiiiiiiiiiiiiiig1FBtmxs2NmyKiigbNkVFFBhs2WNlooxRtsi2IpRjIlZFYNloyC0WEnE\nFIAkSmsACNgABSwAI3CICxYqJBYmAAEgTAATAAhw\n",
    "ASQXiTQlCSxCRhCQReqqrN77z+3+/t1rVy5Ja0tIirqSb34zNh8suXLly5cvyM79w5/tzL5Fxi4l\nxiiiiiiiiiiiiiLjFFq1IoiiiIRREIoohFEghESBFp1XVoo5ECIPRCtV1Kl4XKClcUBegFSoMCCl\nQBUqAFwsAEBCJYAVAgAFAAQAAFgEwAHA\n",
    "ASQXiQgaEgSWOFVVZvnfP9f9vjq9XckkkkkupEo1W878UD6efn5+fn5+fERuc8oO+M5fRnO88888\n888888888888x55mvW162vXNr1za9c2vXM16/GfyJCU52TmklFPgmJpJxsRjOYSLTERYLNkSwE1g\nACQJgFStQEQoVAARAACqYAAAEAOA\n",
    "ASIXiIhaDIWCgiUIyCISCMVMZvfrf8f7/HUu7uSS0lpBKlSc5zmd2Obm+XN23bdt23bO/Nvx9uMj\n8a9416eeeeeeeeeeeeeeeeeedU86t+9v33b990884377ilTqPvvRdS91L0KUpcove8oFai4K0XVK\n1UUqAVquABcuAF4gXAmABMQC6oAAIBUAUAAgADg=\n",
    "ARwXiEh6DIUCSxEQRCQRmyZmb58d/x/t8da1d3JLkktF0KszxzzlaHPz9r2va9r2va9qJzv82aju\n6XtLzzzzzzzzzzzzzzzzzHnma9bXrPPPDXrkeeeZr1yk1ylra5yJa5SmkSJa5SkmJCeEkwyA2CQS\nCMwjyABMmACJCICVAFgBEAAuAgAAALAJiAA4\n",
    "AQgXkCSKDAUCQhCSBGQRCQRk9+c3nO/Gf0/3+OtcS7u1yXckl8ylXU7553lUOKevr6+vr6+v6H5h\n/6b443+jfpX9X6V1K6ldSupXVP1TiedW/e372/fdPPPPvvvTzznG/fci7N67RS8Ro7CNF1gZL0Li\n6IHJQT0xA2kQFrAAAvcAUIgAA2AAC4ALABEAAAqH\n",
    "ARoXiCgiNAaCwSWISIISCMUzvM3z4f3/39vOtXdyS5clokqqupVeN7dhx9H0e7u7u7u7mP79GP0o\nKcouUUUUUUUUUUUUUUUUURRRFq1IoiiiiEUUQiiiGrVWqIERaitaq1hBqFakK6QalaiFcQCiExzA\nQAagXAUAAqsABnAAxLAIgLgAEUgKgATAA4A=\n",
    "ASAXiGhqDIWCgiSIiCNVVMze/E/7f7/XU1d3JLS5IkVdEZ4rncDXr1+l6Xpel6XpS/pfwI41IPVT\ndVNRRRRRRRRRRRRRRRQaig2zY2bFFFA2bItmyLZs2GzYR2LI2t67Do4ESMkbBGJwIz6AFlrE0iKQ\nRsLAskACYgAAgoCooTAAisAgAABAXAKgBRw=\n",
    "ASQXiTAaCwSWIiIIiCLzKrN77f6/7+3WtXclrS1wurUkc5vneB8vlly5cuXL8mf7dHP1IKcYuMUU\nUUUUUUUUUUUUUURRRFq1NWpFFEIoiEUUQiiiQWrVVXVCtwohEg9FakKL11EIDfAhRAgXKFxBIXYF\nQAAGkCAqCICQACu8BS4AAAgARAAEwA4=\n",
    "ASQXiTQkCQhKQREQRKQRkqqrN895/X/Px5vVy7S1rkQl1lpm+fGVB9PPz8/Pz8/P6Dcx6wd8Za+h\nvo3/J/J/J/J/J9Gfyfym+nOP5Tfym/lM/l8D+Ws+mvnA2WlrYfVEnhkJxkHqT6CeG1kZRssstaYD\npEJawTExEErAAAPYADbUEBKAAABMAAsgAAAAUDg=\n",
    "ASQXiOgqDIUCSxEQxmplZuvHf8f5+utXdy4tLkSRKq4V455xQ5ub5bNmzZxbthedfg2pr3NPzTzz\nzzzzzzzzzzzzzzqnnVv3t+9PPOJ55xPOpW/fvN696L896/uvcN5RihvFClaCtRpFChquK1IAhRAA\nBUQBVQJASBUBUEAAASAsAAABIAAS4A==\n",
    "ASAXiGhqDIWCgiSJCGMVVM3nPjn+P9/jqau5clpJJESpTVc891ug5+fn7Xte17Xte1deb/jzaRl4\nt3xbrzzzzzzzzzzzzzzzzHnntetr1teubXrmeeYx555gS8x5k9aUk5E54SUhKSaQ8YmJ2wphZEtF\nJMD1gkJgmAEwJAKBYEwoAASCAASACAAAJADg\n",
    "ARgXiCgiKgaEgSYIyCMzO83vnfP9f9vjrWru5cuSTVS6mSqi+ee8zA5u27b19fX19eKD845Sd8cz\n/U/VPPPPPPPPPPPPPPPPOqeeeedW/e377t++6eeeffvXb2+i9Kb17qUopehS4pWlLuxcuIFKRZAB\nvC4AdgBFQAEqAAguAQqAmgAAABcAC4ExYAHA\n",
    "AQwXkCSKEoSWIiGISCMXrebzfPef2/39vOtXd3Jcku0kYZa+fHO9qHo93d3d3d3d37Mb/wx/q1L9\nlyi5FFFFFFFFFFFFFFEUURatTVqRREIoiEUURaoaiJAIqwK6tRBqrDUVQJOKtYJkCC5rFToEAOsy\nqi4CBcqAGoSABOABUFAAAuAIAAmAAAKBwA==\n",
    "AUJXiKhIDQWCRBGQhCQRw673Ovt3l/P49p04riuMu5VxZa0lQrK2G3T2eXz5ZrDWH8hsPA6KH8co\nCj7fa5Pz+Zn9P6H+PmY3h/SZPzMt/T7pf4if0zH+InzmS0Hzml+MThMlE+cyUThM6ROEzpEnMROE\nyQ2wETgJAJRJgLCQAADgXSAAAUVATAJioAgAACoc\n",
    "AT6f/YyWKl0pdKzQl+f561bO8K80ElC4tp8i5tufWe749H6bP7VH5q/IPvb8BP73FAikAoEbE6fT\npEyhS1Xh+v0SAtSHxOaQBS3h6YAB6fyAAAADw92PYAAAABq8PwNUAAAAPo6+XyAAAAAAAz8e/0fH\nmAAAAAABnEfH19gAAAAf/8f//mngAAAAD0vmR6wAAAAAGl/bh/Xg\n",
    "AUKf/syXMp1JfhcJurlVAS+LhqFkAAAAAAAB/C/aPNaQAHvtvpf8IAH1jr+ZxgANv3PjbwAPb3fe\n6AAH2HyOq64AD4p8w/QNvP9V7juAAAA+L23bep+N77PkgAAAcrrvF4HW7Oq98AAAB6vW+L1Xb/e6\nfU8nRrIAAAAAD7L+X8bxa8Ssq1tLIAAAAADq+88nV8nsPhzfJgy0sgAAAAAAAPD1+F6fqup4fLyl\nq8mr1QAAAAAAANTHl9HgcnuPm9tjo1llypxvVgAAAAAAAAADgA==\n"
);

my @want_md5 = qw(
    kGwflQ3HHNlHSCb9OzCCtA
    kNQS/ARuPzhoLz77cpS4Ag
    CHTmM6Xb3GNTHuheEgUs8w
    CVNgacnYC4SquuHGGo3nrA
    Grf2DudZBhq2uRa4JuLm7w
    GzF2dfRVdHjHjISNDqrtJg
    QyWLNQ9O9RLcv671xeRPzw
    eC0uKlcNvCFe/SNuCrjE/A
    0rA/8/8WneL4EilTSDdQdA
    +L6NKCShsGr6MbZaefrLxQ
    69ACbOUXne3IoCuaQPwzfw
    xAwOTbyGOEUq1UOkuswwfQ
    nHDVzfHgvIgp+txQsPd2bQ
    Mk8kbZ1jRfrSiYnyo7EDvg
    mndFVW4+OTuILKxABA1cOA
    4Wsg1ybaoxoKER9fB2t9gg
    3T0Yg9MTZKCasBCFYsbUHA
    e8/lE39UIlpC5KfpxSmWjw
    LVPg/FRfluMIu7GyCJC9Qg
    NgXA0aNRouvtn5wrFY5VZw
    J/KeU3QsTzM8dHCgksDkJw
    vJE0XSqfUqO9qs/37EYoWw
);

my( $buff_in, $buff_out );
my $aac = Nick::Audio::FAAD -> new(
    'init_sample'   => "\x13\x88",
    'buffer_in'     => \$buff_in,
    'buffer_out'    => \$buff_out,
    'channels'      => 1,
    'gain'          => -3,
    'dont_upsample' => 1
);

ok( defined( $aac ), 'new()' );

# Comes from AudioSpecificConfigFromBitfile which ignores dontUpSampleImplicitSBR
is( $aac -> get_sample_rate(), 44100, 'get_sample_rate()' );

is( $aac -> get_channels(), 2, 'get_channels()' );

my @got_md5;
for ( 0 .. $#data ) {
    $buff_in = $data[$_];
    $aac -> decode()
        and push @got_md5 => md5_base64( $buff_out );
}

is_deeply( \@got_md5, \@want_md5, 'decode()' );

is( $aac -> get_last_samples(), 2048, 'get_last_samples()' );

is( $aac -> get_last_sample_rate(), 22050, 'get_last_sample_rate()' );

is( $aac -> get_last_channels(), 2, 'get_last_channels()' );

eval {
    $buff_in = 'bad data';
    $aac -> decode();
};
is( substr( $@, 0, 17 ), 'FAAD decode error' );

$buff_in = undef;
$aac -> decode();
is( $buff_out, undef, 'Undefined input');
$aac = Nick::Audio::FAAD -> new(
    'init_sample'   => "\x13\x88",
    'channels'      => 1,
    'gain'          => -3,
    'dont_upsample' => 0
);

$aac -> set_buffer_in_ref( $buff_in );
$aac -> set_buffer_out_ref( $buff_out );

$buff_in = shift @data;
$aac -> decode();
is(
    md5_base64( $buff_out ),
    '1B2M2Y8AsgTpgAmY7PhCfg',
    'upsampled'
);
is(
    $aac -> get_last_sample_rate(),
    44100,
    'upsampled get_last_sample_rate()'
);

