function data = lineLoadData(fld, stamp_project,start_spectrum,nbr_spectra,reps)

addpath(fld);

% 1 for yes 0 for no
iv = 1;
dfv = 0;
dmpv = 0;
%iv_file_tmp = [stamp_project num2str(start_spectrum) '_1.I(V)_flat'];
iv_file_tmp = [stamp_project num2str(start_spectrum) '_1.I(V)_flat'];
fiv_tmp = flat_parse(iv_file_tmp);
miv_tmp = flat2matrix(fiv_tmp);
N = length(miv_tmp{1})/2;
data.V = miv_tmp{2}(1:N);

% load start position
%data.start = [fiv_tmp.x, fiv_tmp.y];
data.start = [fiv_tmp.offset_count, fiv_tmp.offset_count];
%{
if iv
    iv_data = NaN(N,nbr_spectra);
    ifwd = NaN(N,nbr_spectra);
    ibwd = NaN(N,nbr_spectra);
    
    for k = 1:nbr_spectra
        i_sum = zeros(size(data.V));
        ifwd_sum = zeros(size(data.V));
        ibwd_sum = zeros(size(data.V));
        for l = 1:reps
            iv_file_tmp = [stamp_project num2str(start_spectrum+k-1) '_' num2str(l) '.I(V)_flat'];
            fiv_tmp = flat_parse(iv_file_tmp);
            miv_tmp = flat2matrix(fiv_tmp);
            itmp = miv_tmp{1};
            i_sum = i_sum+(itmp(1:N)+flipdim(itmp(N+1:2*N),1))/2;
            ifwd_sum = ifwd_sum + itmp(1:N);
            ibwd_sum = ibwd_sum + itmp(N+1:2*N);
        end
        iv_data(:,k) = i_sum/reps;
        ifwd(:,k) = ifwd_sum/reps;
        ibwd(:,k) = ibwd_sum/reps;
    end
    data.iv = iv_data;
    data.ifwd = ifwd;
    data.ibwd = ibwd;
end
%}

if iv
    iv_data = NaN(N,nbr_spectra);
    %i_sum = zeros(size(data.V));
    for k = 1:nbr_spectra
        i_sum = zeros(size(data.V));
        for l = 1:reps
            iv_file_tmp = [stamp_project num2str(start_spectrum+k-1) '_' num2str(l) '.I(V)_flat'];
            fiv_tmp = flat_parse(iv_file_tmp);
            miv_tmp = flat2matrix(fiv_tmp);
            itmp = miv_tmp{1};
            i_sum = i_sum+(itmp(1:N)+flipdim(itmp(N+1:2*N),1))/2;
        end
        iv_data(:,k) = i_sum(:,k)/reps;
    end
    data.iv = iv_data;
    % load end position
    data.end = [fiv_tmp.offset_count, fiv_tmp.offset_count];
end
      
if dfv
    dfv_data = NaN(N,nbr_spectra);
    for k = 1:nbr_spectra
        dfv_file_tmp = [stamp_project num2str(start_spectrum+k-1) '_1.Df(V)_flat'];
        fdfv_tmp = flat_parse(dfv_file_tmp);
        mdfv_tmp = flat2matrix(fdfv_tmp);
        dftmp = mdfv_tmp{1};
        df_avg = (dftmp(1:N)+flipdim(dftmp(N+1:2*N),1))/2;
        dfv_data(:,k) = df_avg;
    end
    data.dfv = dfv_data;
end

if dmpv
    dmpv_data = NaN(N,nbr_spectra);
    for k = 1:nbr_spectra
        dmpv_file_tmp = [stamp_project num2str(start_spectrum+k-1) '_1.Damping(V)_flat'];
        fdmpv_tmp = flat_parse(dmpv_file_tmp);
        mdmpv_tmp = flat2matrix(fdmpv_tmp);
        dmptmp = mdmpv_tmp{1};
        dmp_avg = (dmptmp(1:N)+flipdim(dmptmp(N+1:2*N),1))/2;
        dmpv_data(:,k) = dmp_avg;
    end
    data.dmpv = dmpv_data;
end