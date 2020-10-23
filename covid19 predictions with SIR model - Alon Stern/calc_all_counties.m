% load all countries
clear all;

quest = 'Load last updated data from ECDC?';
opts.Default = 'No (Choose from existing file)';
opts.Interpreter = 'tex';
answer = questdlg(quest,'ECDC data','Yes (Load updated data from ECDC)','No (Choose from existing file)',opts)
if(strcmp(answer,'No (Choose from existing file)'))
    % open dialog box to choose input file
    [file,path] = uigetfile('./ecdc_input/*.xlsx');
    %input_data = readtable('ecdc_covid19_25-Aug-2020.xlsx', 'ReadVariableNames', true);
    outputExcelFileName = [path file];
    input_data = readtable(outputExcelFileName, 'ReadVariableNames', true);    
else
    % download last updated Corona data from European Centre for Disease
    % Prevention and Control (An agency of the European Union)
    outputExcelFileName = ['./ecdc_input/ecdc_covid19_' datestr(date) ['.xlsx']];
    websave(outputExcelFileName,'https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide.xlsx');    
    input_data = readtable(outputExcelFileName, 'ReadVariableNames', true);
end

% write the name of the last file for which the calculation were done
fileID = fopen('./ecdc_input/file_name_of_last_calc.txt','w');
fprintf(fileID,'%s',outputExcelFileName);
fclose(fileID);

all_countries = unique(input_data.countriesAndTerritories);

for(country_index=1:length(all_countries))
    close all;
    country = all_countries{country_index};
    fprintf('-------------- country iteration: %d, country name: %s --------------\n',country_index,country);
    result = calc(country, input_data);
    save(['mat_files/' country],'result');
end
stop=1