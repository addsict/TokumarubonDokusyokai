package SampleApp::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use Log::Minimal;
use SampleApp::Config;
use DBI;

use constant DB_TABLE => 'bank_account'; 

sub dbh {
    my $dsn = config->param('dsn');
    my $db_user = config->param('db_user');
    my $db_password = config->param('db_password');
    my $dbh = DBI->connect($dsn, $db_user, $db_password, {
        mysql_enable_utf8 => 1,
        mysql_multi_statements => 1,
    });
    die $DBI::errstr
        unless defined $dbh;
    return $dbh;
}

get '/' => sub {
    my ( $self, $c )  = @_;

    my $result = $c->req->validator([
        'username' => { rule => [['NOT_NULL', '']], },
    ]);
    if ($result->has_error) {
        $c->redirect('/');
    }
    my $username = $result->valid('username');

    # access to MySQL
    my $dbh = dbh;
    my $vulnerable_sql = "SELECT balance FROM " . DB_TABLE . " WHERE username='$username'";
    debugf $vulnerable_sql;
    my $balance = $dbh->selectrow_array($vulnerable_sql);

    $c->render('index.tx', {
        username => $username,
        balance => $balance,
    });
};

1;

