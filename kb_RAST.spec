/*
A KBase module: kb_RAST
*/

module kb_RAST {

    /*
        a basic 'dry' feature data structure for building the dummy protein object
        for RAST annotation

        Required parameters for PseudoFeature:
        fid: feature id,
        protein_translation: protein sequence

        Optional parameters for PseudoFeature:
        feature_type: feature type,
        location: protein location,
        annotator: annotation source,
        annotation: annotation content
    */
    typedef structure{
        string fid;
        string feature_type;
        list<list<string>> location;
        string annotator;
        string annotation;
        string protein_translation;
    } PseudoFeature;

    /*
    Required parameters for run_rast_workflow rast_annotate_ama:
        genome_id - name/reference to a Genome or Assembly object,
        features - protein features to be annotated
    */
    typedef structure {
        string genome_id;
        list<PseudoFeature> features;
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
