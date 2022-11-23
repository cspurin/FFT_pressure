% function showing the pressure and fourier transform 
close all; 

data              = readtable('pressure_ss.xlsx'); 
input_pressure     = data.ex1; 
input_time_sec     = data.Timenumber* 128*10^-3;
FFT_fun(input_pressure, input_time_sec)


function FFT_plot = FFT_fun(input_pressure, input_time_sec)


      sampling_time         = (input_time_sec(end) - input_time_sec(1)) / length(input_time_sec);                               
      Fs                    = 1/sampling_time;
      L                     = length(input_time_sec)*sampling_time;       %Length of signal 
      time_v                = (0:L-1)*sampling_time;                         %Time vector   
      input_pressure        = (input_pressure- mean(input_pressure)); 
      v                     = round(1/sampling_time);
    

    figure(1); hold on 
    plot(input_time_sec, input_pressure)
      
      
    %fft ALL DATA
    N = length(input_pressure); 
    dn = Fs/N;
    nyqFreq = Fs/2;
    freqRange = 0+dn:dn:nyqFreq; % skipping n=0    
    Fn = fft(input_pressure)/N;
    EnSingle=[2*abs(Fn(2:N/2)).^2; abs(Fn(length(freqRange))).^2] ;
    FnSingle=[2*abs(Fn(2:N/2)); abs(Fn(length(freqRange)))] ;
    SnSingle=EnSingle/dn; % dividing by dn
    
    figure(2); hold on 
    FFT_plot = plot(log10(freqRange),log10(SnSingle),'MarkerSize', 7);

    x = log10(freqRange);
    y = log10(SnSingle);
    Bp = polyfit(x(2:end), transpose(y(2:end)), 1);
    gradfft = Bp(1);

    ylabel('log Power spectrum [Pa^2s]')
    xlabel('log Frequency [Hz]')

 
    plot([min(log10(freqRange)),  max(log10(freqRange))], (([min(log10(freqRange)),  max(log10(freqRange))]*-2))  + 4*mean(log10(SnSingle)) ,'--k', 'Linewidth', 1.5) %red noise plotted for reference 
    plot([min(log10(freqRange)),  max(log10(freqRange))], (([min(log10(freqRange)),  max(log10(freqRange))]*-1)) +  2*mean(log10(SnSingle)),'--r', 'Linewidth', 1.5) %pnik  noise plotted for reference 

end 