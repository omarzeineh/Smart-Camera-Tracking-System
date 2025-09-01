function X = resample_particles(X, L_log)

    % Convert log-likelihood to weights
    L = exp(L_log - max(L_log));  % subtract max for stability
    Q = L / sum(L);               % normalize to get probabilities

    % Ensure R is strictly increasing (avoid duplicate edges)
    R = cumsum(Q);
    R = min(R, 1);                % Ensure it stays within [0, 1]
    R(end) = 1;                   % Force last value to be exactly 1

    % Generate N uniform samples
    N = size(X, 2);
    T = rand(1, N);

    % Fix monotonicity: prepend 0 to R
    edges = [0, R];

    % Use discretize instead of histc (since histc is old)
    [~, I] = histc(T, edges);

    % Fix indexing
    I(I == 0) = 1;
    X = X(:, I);
end