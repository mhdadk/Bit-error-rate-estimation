%-------------------------------------------------------------
% initialize constants

N0 = 2;
Eb = N0 * 0.5;

%-------------------------------------------------------------
% define the confidence level

alpha = 0.317;

y = norminv(1-(alpha/2));

%-------------------------------------------------------------
% compute the population mean of X (this is the same as the
% true BER)

mean_X_pop = 0.5 * erfc(sqrt(Eb/N0));

%-------------------------------------------------------------
% compute the population variance of X

var_X_pop = (normcdf(0,(-sqrt(Eb)),(N0/2)))*...
            (1 - normcdf(0,(-sqrt(Eb)),(N0/2)));

%-------------------------------------------------------------
% ask user for what kind of variance to use

txt1 = ['\nWhich variance would you like to use? Enter ''sample''\n'...
        '(without the quotation marks) for sample variance or\n'...
        'enter ''population'' for population variance:\n\n'];

chosen_variance = input(txt1,'s');

%-------------------------------------------------------------
% define seed used to initialize random number generator

% 'a'  +  'o'  +  'u'  +  'a'  +  'e'  +  'a'  +  'e'
%  16  +  512  +  1024 +   16  +   64  +   16  +   64 = 1712

seed = 1712;

%-------------------------------------------------------------
% number of trials

m = 100;

%-------------------------------------------------------------
% initialize the random number generator

rng(seed,'twister');

%-------------------------------------------------------------
% initialize string used to print the percentage of trials
% for which the true BER fell in the confidence interval

txt2 = ['\nThe percentage of %d trials for which the true BER\n'...
        'fell in the confidence interval is %d%% for n = %d.\n'];

%-------------------------------------------------------------
% initialize array to store results for the first 10 trials
% of each iteration. The first column contains the sample
% mean, the second column contains the lower confidence
% boundary, and the third column contains the upper
% confidence boundary

results = zeros(10,3,3);

%-------------------------------------------------------------
% initialize array indexing variable for use inside for loop

i = 0;

for n = [10,100,1000] % number of received values for each trial
    %-------------------------------------------------------------
    % increment array indexing variable
    
    i = i + 1;
    
    %-------------------------------------------------------------
    % generate an m x n array of standard Normal random numbers
    
    N = randn(m,n);
    
    %-------------------------------------------------------------
    % generate m x n array B of transmitted -1's
    
    B = -ones(m,n);
    
    %-------------------------------------------------------------
    % generate m x n array R of received values
    
    R = sqrt(Eb)*B + sqrt(N0/2)*N;
    
    %-------------------------------------------------------------
    % generate m x n array X of bit errors
    
    X = R > 0;
    
    %-------------------------------------------------------------
    % compute the sample mean of X, which is the same as the
    % estimated BER, for each of the m trials and store the results
    % for the first 10 trials
    
    mean_X_samp = mean(X,2);
    
    results(:,1,i) = mean_X_samp(1:10);
    
    %-------------------------------------------------------------
    % compute the appropriate variance of X based on user input
    
    if strcmp(chosen_variance,'sample')
        
        var_X = (n/(n-1))*(mean_X_samp - mean_X_samp.^2);
        
    else
        
        var_X = var_X_pop;
        
    end
    
    %-------------------------------------------------------------
    % find the confidence intervals for each of the m trials and
    % store the results for the first 10 trials
    
    delta = (y*sqrt(var_X))/(sqrt(n));
    
    conf_interval = [(mean_X_samp - delta), (mean_X_samp + delta)];
    
    results(:,2:3,i) = conf_interval(1:10,:);
    
    %-------------------------------------------------------------
    % compute the fraction of m trials for which the true BER
    % is in the confidence interval
    
    is_in_interval = mean_X_pop > conf_interval(:,1) &...
                     mean_X_pop < conf_interval(:,2);
    
    frac_BER = (sum(is_in_interval)/size(is_in_interval,1));
    
    %-------------------------------------------------------------
    % show percentage of m trials for which true BER is in
    % the confidence interval for each of n
    
    fprintf(txt2,m,frac_BER*100,n);
    
    %-------------------------------------------------------------
    % plot results in three separate figures with confidence
    % intervals
    
    figure(i)
    errorbar(1:10,results(:,1,i),...
            (results(:,3,i)-results(:,2,i))/2,'-r');
    hold on
    yline(mean_X_pop,'-b');
    hold off
    xlim([0,11]);
    xticks(1:1:10);
    legend('Estimated BER','True BER');
    title(['n = ',num2str(n)]);
    xlabel('Trial Number');
end