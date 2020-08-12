/*
A KBase module: kb_RAST
*/

module kb_RAST {
    /*
        defined as [contig, start, strand, end]
    */
    typedef tuple<string, int, string, int> location_spec;

    /*
        a basic 'dry' feature data structure for building the dummy protein object
        for RAST annotation

        Required parameters for PseudoFeature:
        fid - feature id,
        protein_translation - protein sequence

        @optional feature_type
        @optional location
        @optional annotator
        @optional annotation
    */
    typedef structure{
        string fid;
        string protein_translation;
        string feature_type;
        list<location_spec> location;
        string annotator;
        string annotation;
    } PseudoFeature;


    /*
    Required parameters for run_rast_workflow:
        genome_id - name/reference to a Genome or Assembly object,
        features - protein features to be annotated
    */
    typedef structure {
        string genome_id;
        list<PseudoFeature> features;
    } PseudoGenome;

    typedef structure {
        map<string, map<string, string>>;
    } AnnotateStage;

    typedef structure {
        list<AnnotateStage> stages;
    } RASTWorkflow;

    typedef structure {
        PseudoGenome pseudo_genome;
        RASTWorkflow rast_workflow;
    } RunRastWorkflowParams;

    typedef structure {
        string genome_id;
        list<PseudoFeature> features;
    } RunRastWorkflowOutput;

    funcdef run_rast_workflow(RunRastWorkflowParams params)
        returns (RunRastWorkflowOutput output) authentication required;

    /*
    Required parameters for rast_annotate_ama:
        features - protein features to be annotated
    */
    typedef structure {
        list<PseudoFeature> features;
    } RASTama;

    funcdef rast_annotate_ama(RASTama params)
        returns (RASTama output) authentication required;
};
