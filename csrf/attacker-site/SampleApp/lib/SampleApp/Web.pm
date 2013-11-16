package SampleApp::Web;

use strict;
use warnings;
use utf8;
use Kossy;

filter 'disable_x_frame_options' => sub {
    my $app = shift;
    sub {
        my ( $self, $c )  = @_;
        $c->res->header('X-Frame-Options' => '');
        $app->($self,$c);
    }
};

get '/' => sub {
    my ( $self, $c )  = @_;
    $c->render('index.tx', { greeting => "Hello" });
};

get '/attack' => [qw/disable_x_frame_options/] => sub {
    my ( $self, $c )  = @_;
    $c->render('attack.tx', { greeting => "Hello" });
};

1;

