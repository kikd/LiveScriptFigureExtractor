function outputPath = extractFigure(mlx, output_path)
arguments
    mlx string
    output_path string = "."
end

%% Check version
if verLessThan('matlab', '9.9')
    error('Your version is not supported. Please use R2020b or later.')
    exit
end

%% Constants
extractdir_name = 'tmp';
documentdir_name = 'matlab';

%% Extract mlx file as zip
unzip(mlx, extractdir_name);

%% Create output dir
[path,name,ext] = fileparts(mlx);
figfolder_name = strcat(name, "_figures");
output_dir = fullfile(output_path, figfolder_name);
mkdir(output_dir);

%% Parse output.xml
outputxml_path = fullfile(extractdir_name, documentdir_name, 'output.xml');
figure_path = '';
figure_name = '';
output_xml = readstruct(outputxml_path);
output_elements = output_xml.outputArray.element;
figure_num = 1;
fp = -1;
for elem = output_elements
    output_info = struct();
    output_info.type = elem.type;
    output_info.linenum = elem.lineNumbers.element;
    switch elem.type
        case 'figure'
            %display(elem.outputData.figureUri)
            fig_str = split(elem.outputData.figureUri, ',');
            decoded_fig = matlab.net.base64decode(fig_str(2));
            figure_name = strcat('figure',string(figure_num), '.png');
            figure_path  = fullfile(output_dir, figure_name);
            fp = fopen(figure_path, 'w');
            fwrite(fp, decoded_fig);
            fclose(fp);
            figure_num = figure_num + 1;
        otherwise
            % do nothing...
    end
end

%% Cleanup
rmdir(extractdir_name, "s");
end