%% Script to plot pressure data and transform it using FFT using standard Keller transducer input 

%pressure and temperature manipulations from the trandsucer data
data_file1 = readtable('C:\Users\cspurin\Documents\SLS_pressure_data\q01_fw085_14-06-2019.csv','Delimiter',',','Format', '%s%f%s%f%s', 'HeaderLines', 4, 'ReadVariableNames', true);
data_file2 = readtable('C:\Users\cspurin\Documents\SLS_pressure_data\q01_fw05_q04_allfwv2.csv','Delimiter',',','Format', '%s%f%s%f%s', 'HeaderLines', 4, 'ReadVariableNames', true);
data_file3 = readtable('C:\Users\cspurin\Documents\SLS_pressure_data\q07_fw085and07_16-06-2019.csv','Delimiter',',','Format', '%s%f%s%f%s', 'HeaderLines', 4, 'ReadVariableNames', true);
data_file4 = readtable('C:\Users\cspurin\Documents\SLS_pressure_data\q07_fw05_16-06-2019.csv','Delimiter',',','Format', '%s%f%s%f%s', 'HeaderLines', 4, 'ReadVariableNames', true);
data_file5 = readtable('C:\Users\cspurin\Documents\SLS_pressure_data\q01_fw07_15-06-2019.csv','Delimiter',',','Format', '%s%f%s%f%s', 'HeaderLines', 4, 'ReadVariableNames', true);
%NB won't load floats without 'HeaderLines' and 'ReadVariables' if there are NaNs in the data file

%all data files collated in single table
data_all_files = [data_file1; data_file2; data_file3; data_file4; data_file5];

%splitting table to extract time data 
time_table = data_all_files.TimeSN_872034_S30X__P1; 
%time converted into datetime for further analysis 
time_pressure                                                           = datetime(time_table(:,1) ,'InputFormat','dd.MM.yyyy H:mm:s.SSS');
%splitting table to extract pressure data 
pressure                                                                = data_all_files.SN_872034_S30X__P1Bar; 


%You can use use a moving median filter to filter the pressure data if
%needed (changing the last value changes the number of points you average
%over
M  = movmedian(pressure, 12); %filtered data 
M1 = movmedian(pressure, 1);  %unfiltered data 

%% The times of interest for the FFT (steady-state) 
%stored as experiment description, scan interval (s), no. of scans and time
%scan started 
exp31 = ["q01_fw085_ss"; 2; 299;  datestr(datetime(2019,6,15,05,34,00))];
exp58 = ["q04_fw085_ss"; 2; 100; datestr(datetime(2019,6,15,21,35,00))];
exp74 = ["q07_fw085_ss"; 2; 100;  datestr(datetime(2019,6,16,10,46,00))];

exp40 = ["q01_fw07_ss"; 2; 95;  datestr(datetime(2019,6,15,11,08,00))]; 
exp66 = ["q04_fw07_ss"; 1; 79;  datestr(datetime(2019,6,16,2,28,00))];
exp77 = ["q07_fw07_ss"; 1; 100; datestr(datetime(2019,6,16,12,09,00))];

exp44 = ["q01_fw05_ss"; 60; 30; datestr(datetime(2019,6,15,14,31,00))];
exp70 = ["q04_fw05_ss"; 2; 100; datestr(datetime(2019,6,16,7,21,00))];
exp80 = ["q07_fw05_ss"; 1; 100; datestr(datetime(2019,6,16,14,33,00))]; 

%collating all experimental input data 
dir_working   = [exp31; exp40; exp44; exp58; exp66; exp70; exp74; exp77; exp80];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of user input 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% defining directories of interest 
scan_interval = str2double(dir_working(2:4:length(dir_working)));
no_scans      = str2double(dir_working(3:4:length(dir_working)));
scan_time     = datetime(dir_working(4:4:length(dir_working))); 
length_scan   = (scan_interval + 2) .*no_scans; %this is in seconds

                                                          
%% pressure plot for 1 hr of ss
%time in hours from the start of an exp 
end_point           = scan_time(end) +hours(2);
start_point         = scan_time(1)   -hours(2);
x_time              = hours((time_pressure(time_pressure < end_point & time_pressure > start_point)) - start_point);
y_pressure          = M(time_pressure < end_point & time_pressure > start_point);
unfiltered_pressure = M1(time_pressure < end_point & time_pressure > start_point);
clrmap              = [[0.5843, 0.8157, 0.9882];[0,0,1];[0.2824, 0.2392, 0.5451];[0.7020,1,0.7020];[0,1,0];[0, 0.5529, 0];[1, 0.541, 0.541];[1, 0, 0];[0.8, 0, 0];[1, 0.541, 0.541];[1, 0, 0];[0.8, 0, 0]];
t                   = hours(scan_time(:) - scan_time(1)); %time steady-state

figure;
hold on 
for m = 1:length(no_scans)
    pressure_ss_full_scan = y_pressure(x_time > t(m) & x_time <= t(m) +1) ;
    time_ss_full_scan     = x_time(x_time > t(m)     & x_time <= t(m) +1);
    s_freq                = 10; %sampling frequency
    pressure_ss           = pressure_ss_full_scan(1:s_freq:length(pressure_ss_full_scan));
    time_ss               = time_ss_full_scan(1:s_freq:length(time_ss_full_scan));
    p1                    = plot((time_ss- t(m) + 1), pressure_ss, '-', 'Color',clrmap(m  ,:), 'LineWidth', 1.5);
end 
ylabel('Differential pressure (kPa)')
xlabel('Time (hours)')


% FT of pressure data 
cmap = ['-kx'; '-ko';'-bd'; '-bo'; '-b^'; '-gd'; '-go'; '-g^'; '-rd'; '-ro'; '-r^'; '-cx'; '-cd';'-co'];
c_index = [1 0.5 0.25 1 0.5 0.25 1 0.5 0.25];
style_line = ['- ';'--';'-.';'- ';'--';'-.';'- ';'--';'-.'];
t_int = [0.1 0.2 0.35 0.5 0.75 1]; %can change time interval of observations here

for m = 1:length(no_scans)
    for z = length(t_int) %can iterate for smaller time intervals here 
        pressure_ss_full_scan = y_pressure(x_time > t(m) & x_time <= t(m) + t_int(z)) ;
        time_ss_full_scan     = x_time(x_time > t(m)     & x_time <= t(m) + t_int(z));
        sampling_time         = (time_ss_full_scan(end) - time_ss_full_scan(1)) *60*60 / length(time_ss_full_scan);                               
        Fs                    = 1/sampling_time;
        L                     = length(time_ss_full_scan)*sampling_time;       %Length of signal 
        time_v                = (0:L-1)*sampling_time;                         %Time vector   
        input_pressure = (pressure_ss_full_scan- mean(pressure_ss_full_scan)); 
        v = round(1/sampling_time);
    
    
%     figure(f); 
%     histogram(input_pressure) 

    
    %fft ALL DATA
    N = length(input_pressure); 
    dn = Fs/N;
    nyqFreq = Fs/2;
    freqRange = 0+dn:dn:nyqFreq; % skipping n=0    
    Fn = fft(input_pressure)/N;
    EnSingle=[2*abs(Fn(2:N/2)).^2; abs(Fn(length(freqRange))).^2] ;
    FnSingle=[2*abs(Fn(2:N/2)); abs(Fn(length(freqRange)))] ;
    SnSingle=EnSingle/dn; % dividing by dn
    figure; hold on 
    plot(log10(freqRange),log10(SnSingle), cmap(m,2:end), 'MarkerFaceColor','k', 'MarkerSize', 2)


    x = log10(freqRange);
    y = log10(SnSingle);
    Bp = polyfit(x(2:end), transpose(y(2:end)), 1);
    gradfft(m) = Bp(1);
    plot([-4,  1], (([-4,  1]*-2) + Bp(2)),'--k', 'Linewidth', 1.5) %red noise plotted for reference 

ylabel('log Power spectrum [Pa^2s]')
xlabel('log Frequency [Hz]')

    end 
end

