# lib-audio-faad

Interface to the FAAD2 (Freeware Advanced Audio Decoder) AAC decoder library.

## Dependencies

You'll need the [FAAD2 library](http://www.audiocoding.com/faad2.html).

On Ubuntu distributions;

    sudo apt install libfaad-dev

## Installation

    perl Makefile.PL
    make test
    sudo make install

## Example

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

## Methods

### new()

Instantiates a new Nick::Audio::LAME object.

Arguments are interpreted as a hash.

There's only one mandatory key.

- init\_sample

    Data from input to initialise stream.

The rest are optional.

- init\_length

    Length in bytes of init\_sample.

- buffer\_in

    Scalar that'll be used to pull AAC frames from.

- buffer\_out

    Scalar that'll be used to push decoded PCM to.

- channels

    How many audio channels the stream has.

- gain

    Decibels of gain to apply to the decoded PCM.

### decode()

Decodes the frame (if present) in the buffer\_in scalar, returning number of bytes of PCM written to buffer\_out.

### get\_sample\_rate()

Returns current sample rate.

### get\_channels()

Returns current number of channels being output.

### get\_buffer\_in\_ref()

Returns the scalar currently being used to pull AAC frames from.

### get\_buffer\_out\_ref()

Returns the scalar currently being used to push decoded PCM to.

### get\_last\_samples()

Returns the number of samples in the last decoded frame.

### get\_last\_sample\_rate()

Returns the sample rate of the last decoded frame.

### get\_last\_channels()

Returns the number of audio channels of the last decoded frame.
