#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <neaacdec.h>
#include <math.h>

struct nickaudiofaad {
    NeAACDecHandle decoder;
    uint8_t channels;
    uint32_t sample_rate;
    bool mono;
    float gain;
    NeAACDecFrameInfo frame_info;
    void *pcm_out;
    SV *scalar_in;
    SV *scalar_out;
};

typedef struct nickaudiofaad NICKAUDIOFAAD;

#define MAX_SIZE 8 * 1024
#define PCM_MAX_VALUE (1.0 * 0x8000)

MODULE = Nick::Audio::FAAD  PACKAGE = Nick::Audio::FAAD

static NICKAUDIOFAAD *
NICKAUDIOFAAD::new_xs( init_sample, init_length, channels_out, gain, scalar_in, scalar_out, dont_upsample )
        unsigned char *init_sample;
        U32 init_length;
        unsigned char channels_out;
        float gain;
        SV *scalar_in;
        SV *scalar_out;
        unsigned char dont_upsample;
    CODE:
        Newxz( RETVAL, 1, NICKAUDIOFAAD );
        RETVAL -> decoder = NeAACDecOpen();
        NeAACDecConfigurationPtr config
            = NeAACDecGetCurrentConfiguration( RETVAL -> decoder );
        config -> outputFormat = FAAD_FMT_16BIT;
        config -> downMatrix = 1;
        config -> defObjectType = LC;
        config -> dontUpSampleImplicitSBR = dont_upsample;
        if (
            NeAACDecSetConfiguration( RETVAL -> decoder, config ) == 0
        ) {
            croak( "Problem setting default FAAD config." );
        }
        unsigned long sample_rate;
        unsigned char channels_in;
        if (
            NeAACDecInit2(
                RETVAL -> decoder,
                init_sample,
                init_length,
                &sample_rate,
                &channels_in
            ) < 0
        ) {
            croak( "Problem initializing FAAD." );
        }
        Newx( RETVAL -> pcm_out, MAX_SIZE, void );
        RETVAL -> scalar_in = SvREFCNT_inc(
            SvROK( scalar_in )
            ? SvRV( scalar_in )
            : scalar_in
        );
        RETVAL -> scalar_out = SvREFCNT_inc(
            SvROK( scalar_out )
            ? SvRV( scalar_out )
            : scalar_out
        );
        RETVAL -> sample_rate = sample_rate;
        RETVAL -> channels = channels_in;
        RETVAL -> mono = channels_out == 1;
        RETVAL -> gain = pow( 10, gain / 20 );
    OUTPUT:
        RETVAL

void
NICKAUDIOFAAD::DESTROY()
    CODE:
        NeAACDecClose( THIS -> decoder );
        SvREFCNT_dec( THIS -> scalar_in );
        SvREFCNT_dec( THIS -> scalar_out );
        Safefree( THIS -> pcm_out );
        Safefree( THIS );

U32
NICKAUDIOFAAD::get_sample_rate()
    CODE:
        RETVAL = THIS -> sample_rate;
    OUTPUT:
        RETVAL

U8
NICKAUDIOFAAD::get_channels()
    CODE:
        RETVAL = THIS -> channels;
    OUTPUT:
        RETVAL

SV *
NICKAUDIOFAAD::get_buffer_in_ref()
    CODE:
        RETVAL = newRV_inc( THIS -> scalar_in );
    OUTPUT:
        RETVAL

void
NICKAUDIOFAAD::set_buffer_in_ref( scalar_in )
        SV *scalar_in;
    CODE:
        SvREFCNT_dec( THIS -> scalar_in );
        THIS -> scalar_in = SvREFCNT_inc(
            SvROK( scalar_in )
            ? SvRV( scalar_in )
            : scalar_in
        );

SV *
NICKAUDIOFAAD::get_buffer_out_ref()
    CODE:
        RETVAL = newRV_inc( THIS -> scalar_out );
    OUTPUT:
        RETVAL

void
NICKAUDIOFAAD::set_buffer_out_ref( scalar_out )
        SV *scalar_out;
    CODE:
        SvREFCNT_dec( THIS -> scalar_out );
        THIS -> scalar_out = SvREFCNT_inc(
            SvROK( scalar_out )
            ? SvRV( scalar_out )
            : scalar_out
        );

U32
NICKAUDIOFAAD::decode()
    CODE:
        STRLEN len_in;
        if (
            ! SvOK( THIS -> scalar_in )
        ) {
            sv_setpvn( THIS -> scalar_out, NULL, 0 );
            XSRETURN_UNDEF;
        }
        unsigned char *in_buff = SvPV( THIS -> scalar_in, len_in );
        if (
            ! NeAACDecDecode2(
                THIS -> decoder,
                &( THIS -> frame_info ),
                in_buff, len_in,
                &( THIS -> pcm_out ), MAX_SIZE
            )
        ) {
            croak(
                "FAAD decode error: %s",
                NeAACDecGetErrorMessage(
                    ( THIS -> frame_info ).error
                )
            );
        }
        if ( THIS -> mono ) {
            RETVAL = ( THIS -> frame_info ).samples;
            unsigned char *u_pcm = THIS -> pcm_out;
            signed char *s_pcm = THIS -> pcm_out + 1;
            int i = 0;
            int j = 0;
            for ( i = 0; i < RETVAL; i += 2 ) {
                u_pcm[i] = (
                    u_pcm[j] + u_pcm[ j + 2 ]
                ) / 2;
                s_pcm[i] = (
                    s_pcm[j] + s_pcm[ j + 2 ]
                ) / 2;
                j += 4;
            }
        } else {
            RETVAL = ( THIS -> frame_info ).samples * 2;
        }
        if (THIS -> gain != 1) {
            int sample;
            unsigned char *u_pcm = THIS -> pcm_out;
            signed char *s_pcm = THIS -> pcm_out + 1;
            unsigned int samples = RETVAL / 2;
            while ( samples-- ) {
                sample = (
                    ( s_pcm[0] << 8 ) | u_pcm[0]
                ) * THIS -> gain;
                if (
                    sample > PCM_MAX_VALUE
                ) {
                    sample = PCM_MAX_VALUE - 1;
                } else if (
                    sample < -PCM_MAX_VALUE
                ) {
                    sample = -PCM_MAX_VALUE + 1;
                }
                u_pcm[0] = sample & 0xff;
                s_pcm[0] = ( sample >> 8 ) & 0xff;
                u_pcm += 2;
                s_pcm += 2;
            }
        }
        sv_setpvn( THIS -> scalar_out, THIS -> pcm_out, RETVAL );
    OUTPUT:
        RETVAL

unsigned long
NICKAUDIOFAAD::get_last_samples()
    CODE:
        RETVAL = ( THIS -> frame_info ).samples;
    OUTPUT:
        RETVAL

unsigned long
NICKAUDIOFAAD::get_last_sample_rate()
    CODE:
        RETVAL = ( THIS -> frame_info ).samplerate;
    OUTPUT:
        RETVAL

unsigned char
NICKAUDIOFAAD::get_last_channels()
    CODE:
        RETVAL = ( THIS -> frame_info ).channels;
    OUTPUT:
        RETVAL

unsigned char
NICKAUDIOFAAD::get_last_sbr_xs()
    CODE:
        RETVAL = ( THIS -> frame_info ).sbr;
    OUTPUT:
        RETVAL

unsigned char
NICKAUDIOFAAD::get_last_object_type_xs()
    CODE:
        RETVAL = ( THIS -> frame_info ).object_type;
    OUTPUT:
        RETVAL
