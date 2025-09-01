function L = calc_log_likelihood(Xstd_rgb, D, X, Y) %#codegen

Npix_h = size(Y, 1);
Npix_w = size(Y, 2);

N = size(X,2);

L = zeros(1,N);
Y = permute(Y, [3 1 2]);

A = -log(sqrt(2 * pi) * Xstd_rgb);
B = - 0.5 / (Xstd_rgb.^2);

X = round(X);

for k = 1:N
    
    m = X(1,k);
    n = X(2,k);
    
    I = (m >= 1 & m <= Npix_h);
    J = (n >= 1 & n <= Npix_w);
    
    if I && J
        L(k) =  A + B * D(k);
    else
        L(k) = -10000;
    end
end
