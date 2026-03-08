function d = compute_distances(pos, bs_xy)

[T,U,~] = size(pos);
B = size(bs_xy,1);

d = zeros(T,B,U);

for t = 1:T
    for b = 1:B
        for u = 1:U

            dx = pos(t,u,1) - bs_xy(b,1);
            dy = pos(t,u,2) - bs_xy(b,2);

            d(t,b,u) = sqrt(dx^2 + dy^2);

        end
    end
end

end