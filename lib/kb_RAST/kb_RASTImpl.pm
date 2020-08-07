#BEGIN_HEADER
use Bio::KBase::AuthToken;
use installed_clients::KBaseReportClient;
use Config::IniFiles;
#END_HEADER
#BEGIN_CONSTRUCTOR
    my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
    my $cfg = Config::IniFiles->new(-file=>$config_file);
    my $scratch = $cfg->val('kb_RAST', 'scratch');
    my $callbackURL = $ENV{ SDK_CALLBACK_URL };

    $self->{scratch} = $scratch;
    $self->{callbackURL} = $callbackURL;
#END_CONSTRUCTOR
#BEGIN run_kb_RAST
    my $repcli = installed_clients::KBaseReportClient->new($self->{callbackURL});
    my $report = $repcli->create({
        workspace_name => $params->{workspace_name},
        report => {
            text_message => $params->{parameter_1},
            objects_created => []
        }
    });

    my $output = {
        report_name => $report->{name},
        report_ref => $report->{ref}
    };
#END run_kb_RAST

#BEGIN_STATUS
    $return = {"state" => "OK", "message" => "", "version" => $VERSION, "git_url" => $GIT_URL, "git_commit_hash" => $GIT_COMMIT_HASH};
#END_STATUS
