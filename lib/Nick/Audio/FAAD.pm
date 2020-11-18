package Nick::Audio::FAAD;

use strict;
use warnings;

use XSLoader;
use Carp;

our $VERSION = '0.01';

XSLoader::load 'Nick::Audio::FAAD' => $VERSION;

=pod

=head1 NAME

Nick::Audio::FAAD - Interface to the FAAD2 (AAC decoding) library.

=head1 SYNOPSIS

    use Nick::Audio::FAAD;
    use Nick::Audio::M4B;

    my( $buff_in, $buff_out );
    my $m4b = Nick::Audio::M4B -> new( 'test.m4b', $buff_in );

    use FileHandle;
    my $sox = FileHandle -> new( sprintf
            "| sox -q -t raw -b 16 -e s -r %d -c %d - -t pulseaudio",
            $m4b -> get_sample_rate(),
            $m4b -> get_channels()
    ) or die $!;
    binmode $sox;

    my %aac_set = (
        'buffer_in' => \$buff_in,
        'buffer_out' => \$buff_out,
        'channels' => $m4b -> get_channels(),
        'gain' => -3
    );
    @aac_set{ qw( init_sample init_length ) } = $m4b -> get_init_sample();

    my $aac = Nick::Audio::FAAD -> new( %aac_set );
    while (
        $m4b -> get_audio()
    ) {
        $aac -> decode()
            and $sox -> print( $buff_out );
    }
    $sox -> close();

=head1 METHODS

=head2 new()

Instantiates a new Nick::Audio::FAAD object.

Arguments are interpreted as a hash.

There's only one mandatory key.

=over 2

=item init_sample

Data from input to initialise stream.

=back

The rest are optional.

=over 2

=item init_length

Length in bytes of init_sample.

=item buffer_in

Scalar that'll be used to pull AAC frames from.

=item buffer_out

Scalar that'll be used to push decoded PCM to.

=item channels

How many audio channels the stream has.

=item gain

Decibels of gain to apply to the decoded PCM.

=item dont_upsample

Suppress upsampling audio.

=back

=head2 decode()

Decodes the frame (if present) in the buffer_in scalar, returning number of bytes of PCM written to buffer_out.

=head2 get_sample_rate()

Returns current sample rate.

=head2 get_channels()

Returns current number of channels being output.

=head2 get_buffer_in_ref()

Returns the scalar currently being used to pull AAC frames from.

=head2 get_buffer_out_ref()

Returns the scalar currently being used to push decoded PCM to.

=head2 get_last_samples()

Returns the number of samples in the last decoded frame.

=head2 get_last_sample_rate()

Returns the sample rate of the last decoded frame.

=head2 get_last_channels()

Returns the number of audio channels of the last decoded frame.

=cut

sub new {
    my( $class, %settings ) = @_;
    exists( $settings{'init_sample'} )
        or croak( 'Missing init_sample parameter' );
    exists( $settings{'init_length'} )
        or $settings{'init_length'}
            = length $settings{'init_sample'};
    exists( $settings{'dont_upsample'} )
        or $settings{'dont_upsample'} = 1;
    for ( qw( in out ) ) {
        exists( $settings{ 'buffer_' . $_ } )
            or $settings{ 'buffer_' . $_ } = do{ my $x = '' };
    }
    $settings{'channels'} ||= 2;
    $settings{'gain'} ||= 0;
    return Nick::Audio::FAAD -> new_xs(
        @settings{ qw(
            init_sample init_length channels gain
            buffer_in buffer_out dont_upsample
        ) }
    );
}

1;
