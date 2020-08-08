use strict;
use Data::Dumper qw(Dumper);
use Test::More;
use Config::Simple;
use Time::HiRes qw(time);
use Bio::KBase::AuthToken;
use installed_clients::WorkspaceClient;
use kb_RAST::kb_RASTImpl;

local $| = 1;
my $token = $ENV{'KB_AUTH_TOKEN'};
my $config_file = $ENV{'KB_DEPLOYMENT_CONFIG'};
my $config = new Config::Simple($config_file)->get_block('kb_RAST');
my $ws_url = $config->{"workspace-url"};
my $ws_name = undef;
my $ws_client = new installed_clients::WorkspaceClient($ws_url,token => $token);
my $scratch = $config->{scratch};
my $callback_url = $ENV{'SDK_CALLBACK_URL'};
my $auth_token = Bio::KBase::AuthToken->new(token => $token, ignore_authrc => 1, auth_svc=>$config->{'auth-service-url'});
my $ctx = LocalCallContext->new($token, $auth_token->user_id);
$kb_RAST::kb_RASTServer::CallContext = $ctx;
my $impl = new kb_RAST::kb_RASTImpl();

sub get_ws_name {
    if (!defined($ws_name)) {
        my $suffix = int(time * 1000);
        $ws_name = 'test_kb_RAST_' . $suffix;
        $ws_client->create_workspace({workspace => $ws_name});
    }
    return $ws_name;
}


eval {

    # Prepare test data using the appropriate uploader for that data (see the KBase function
    # catalog for help, https://narrative.kbase.us/#catalog/functions)
    
    # Run your method by
    # my $ret = $impl->your_method(parameters...);
    #
    # Check returned data with
    # ok(ret->{...} eq <expected>, "tested item") or other Test::More methods
    # my $ret = $impl->run_kb_RAST({workspace_name => get_ws_name(),
    #                                     parameter_1 => "Hello world"});

};

my @default_stages = (
    { name => 'call_features_CDS_prodigal' },
    { name => 'call_features_CDS_glimmer3', failure_is_not_fatal => 1,
      glimmer3_parameters => { min_training_len => '2000'} },
    { name => 'call_features_rRNA_SEED' },
    { name => 'call_features_tRNA_trnascan' },
    { name => 'call_selenoproteins', failure_is_not_fatal => 1 },
    { name => 'call_pyrrolysoproteins', failure_is_not_fatal => 1 },
    { name => 'call_features_repeat_region_SEED',
          repeat_region_SEED_parameters => {} },
    { name => 'call_features_strep_suis_repeat',
          condition => '$genome->{scientific_name} =~ /^Streptococcus\s/' },
    { name => 'call_features_strep_pneumo_repeat',
          condition => '$genome->{scientific_name} =~ /^Streptococcus\s/' },
    { name => 'call_features_crispr', failure_is_not_fatal => 1 },
    { name => 'call_features_CDS_genemark' }
  );
my $default_wf = { stages => \@default_stages };


subtest 'run_rast_workflow' => sub {
    # 1. creating default genome object
    my $inputgenome1 = {
        id => "test_kb_RAST_1",
        features => []
    };
    my $wf = {
        [{name => 'call_features_CDS_prodigal' }]
    };
};

my $err = undef;
if ($@) {
    $err = $@;
}
eval {
    if (defined($ws_name)) {
        $ws_client->delete_workspace({workspace => $ws_name});
        print("Test workspace was deleted\n");
    }
};
if (defined($err)) {
    use Scalar::Util 'blessed';
    if(blessed $err && $err->isa("Bio::KBase::Exceptions::KBaseException")) {
        die "Error while running tests. Remote error:\n" . $err->{data} .
            "Client-side error:\n" . $err;
    } else {
        die $err;
    }
}

{
    package LocalCallContext;
    use strict;
    sub new {
        my($class,$token,$user) = @_;
        my $self = {
            token => $token,
            user_id => $user
        };
        return bless $self, $class;
    }
    sub user_id {
        my($self) = @_;
        return $self->{user_id};
    }
    sub token {
        my($self) = @_;
        return $self->{token};
    }
    sub provenance {
        my($self) = @_;
        return [{'service' => 'kb_RAST', 'method' => 'please_never_use_it_in_production', 'method_params' => []}];
    }
    sub authenticated {
        return 1;
    }
    sub log_debug {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
    sub log_info {
        my($self,$msg) = @_;
        print STDERR $msg."\n";
    }
}
