package SampleApp::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use Log::Minimal;
use Data::Dumper;

use constant VALID_USERNAME => 'taro';
use constant VALID_PASSWORD => 'pass';

sub is_valid_account {
    my ($username, $password) = @_;
    return 1 if $username eq VALID_USERNAME && $password eq VALID_PASSWORD;
    return;
}

sub create_entry {
    my ($title, $body) = @_;
    my ($sec, $min, $hour, $day, $month, $year) = localtime(time);
    my $date = sprintf("%d-%d-%d %d:%d:%d", $year+1990, $month+1, $day, $hour, $min, $sec);
    return {
        date => $date,
        title => $title,
        body => $body,
    };
}

filter 'token_check' => sub {
    my $app = shift;
    sub {
        my ( $self, $c )  = @_;
        my $session_id = $c->env->{'psgix.session.options'}->{id};
        my $result = $c->req->validator([
            'token' => { rule => [['NOT_NULL', '']], },
        ]);
        my $token = $result->valid('token');
        if ($session_id eq $token) {
            $app->($self,$c);
        } else {
            $c->res->status(403);
            $c->res;
        }
    }
};

get '/' => sub {
    my ( $self, $c )  = @_;
    my $session = $c->env->{'psgix.session'};
    if ($session->{id}) {
        my $session_id = $c->env->{'psgix.session.options'}->{id};
        debugf $session_id;
        $c->render('index.tx', {
            entries => $session->{entries},
            session_id => $session_id,
        });
    } else {
        $c->redirect('/login');
    }
};

post '/' => [qw/token_check/] => sub {
    my ( $self, $c )  = @_;
    my $session = $c->env->{'psgix.session'};

    # show request header
    for my $header (keys %{$c->req->headers}) {
        debugf $header . ": " . $c->req->headers->{$header};
    }

    # fetch request body
    my $result = $c->req->validator([
        'title' => { rule => [['NOT_NULL', '']], },
        'body' => { rule => [['NOT_NULL', '']], },
    ]);
    my $title = $result->valid('title');
    my $body = $result->valid('body');

    my $entry = create_entry($title, $body);

    if ($session->{entries}) {
        push $session->{entries}, $entry;
    } else {
        $session->{entries} = [$entry]; 
    }
    $c->redirect('/');
};

get '/login' => sub {
    my ( $self, $c )  = @_;
    $c->render('login.tx', {});
};

post '/login' => sub {
    my ( $self, $c )  = @_;
    
    my $result = $c->req->validator([
        'username' => { rule => [['NOT_NULL', '']], },
        'password' => { rule => [['NOT_NULL', '']], },
    ]);
    my $username = $result->valid('username');
    my $password = $result->valid('password');

    if ($result->has_error || !is_valid_account($username, $password)) {
        # login fail
        $c->redirect('/login');
    } else {
        # login success
        $c->env->{'psgix.session'}->{id} = $username;
        $c->redirect('/');
    }
};

1;

