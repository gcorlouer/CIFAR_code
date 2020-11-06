classdef Subject
    properties 
        name
        task 
        run
    end
    methods 
        function subject_path = subject_path(Subject)
            cohort_path = fullfile('~','CIFAR_data','iEEG_10', 'subjects');
            subject_path = fullfile(cohort_path, Subject.name);
        end
        function processing_stage_dir = processing_stage_dir(Subject, processing_stage)
            if nargin <2, processing_stage = 'raw_signal'; end % default to raw signal
            subject_path = Subject.subject_path();
            processing_stage_dir = path(subject_path, processing_stage); 
        end
    end
end
