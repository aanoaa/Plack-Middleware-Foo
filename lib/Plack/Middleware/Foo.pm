package Plack::Middleware::Foo;
use parent qw/Plack::Middleware/;
use JSON;
use Plack::Util;
use Plack::Request;
use File::Slurp qw/write_file/;
sub call {
    my ($self, $env) = @_;
    my $req = Plack::Request->new($env);

    my $req_content = sprintf "[Request] %s\n", $req->path_info;
    my $headers = $req->headers;
    $req_content .= $headers->as_string . "\n";
    my $params = $req->parameters;
    $req_content .= "\t[Params]\n" if $params->keys;
    for my $key ($params->keys) {
        $req_content .= sprintf "\t%s: %s\n", $key, $params->get($key);
    }

    $req_content .= "\n";
    write_file('log/res.log', { append => 1 }, $req_content);

    my $res = $self->app->($env);
    $self->response_cb($res, sub {
        my $res = shift;
        my $headers = Plack::Util::headers($res->[1]);
        my $content_type = $headers->get('Content-Type');
        if ($content_type =~ m/json/i) {
            return sub {
                my $chunk = shift;
                return unless defined $chunk;
                my $data = from_json($chunk);
                my $res_content .= sprintf("[Response]\n%s\n", to_json($data, { pretty => 1 }));
                write_file('log/res.log', { append => 1 }, $res_content);
                return $chunk;
            }
        }
    });
}

1;
