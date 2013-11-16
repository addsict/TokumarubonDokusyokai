package SampleApp::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use Log::Minimal;

use constant VALID_USERNAME => 'taro';
use constant VALID_PASSWORD => 'pass';

sub is_valid_account {
    my ($username, $password) = @_;
    return 1 if $username eq VALID_USERNAME && $password eq VALID_PASSWORD;
    return;
}

get '/' => sub {
    my ( $self, $c )  = @_;
    my $session = $c->env->{'psgix.session'};
    if ($session->{id}) {
        $c->render('index.tx', {entries => $session->{entries}});
    } else {
        $c->redirect('/login');
    }
};

post '/' => sub {
    my ( $self, $c )  = @_;
    my $session = $c->env->{'psgix.session'};
    my $result = $c->req->validator([
        'title' => {
            rule => [
                ['NOT_NULL', '']
            ],
        },
        'body' => {
            rule => [
                ['NOT_NULL', '']
            ],
        },
    ]);
    my $title = $result->valid('title');
    my $body = $result->valid('body');
    my ($sec, $min, $hour, $day, $month, $year) = localtime(time);
    my $date = sprintf("%d-%d-%d %d:%d:%d", $year+1990, $month+1, $day, $hour, $min, $sec);
    my $entry = {
        date => $date,
        title => $title,
        body => $body,
    };
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
        'username' => {
            rule => [
                ['NOT_NULL', '']
            ],
        },
        'password' => {
            rule => [
                ['NOT_NULL', '']
            ],
        },
    ]);

    my $username = $result->valid('username');
    my $password = $result->valid('password');
    debugf($username);
    debugf($password);

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

