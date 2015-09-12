function mask = get_mask( image )

[x,y] = size(image);
mask = logical(zeros(x,y));

for i = 1:x
    j = 1;
    while j  <  y  && image(i,j) < 50
        j = j + 1;
        mask(i,j-1) = 1;
    end
    if j < y/2
        for k  = j:j+10
            mask(i,k) = 1;
        end
    end
    j = y;
    while j >= 1&& image(i,j) < 50
        mask(i,j) = 1;
        j = j - 1;
    end
    if j >= y/2
        for k = j-50:j
            mask(i,k) = 1;
        end
    end
end


for i = 1:y
    j = 1;
    while j  <  x  && image(j,i) < 50
        j = j + 1;
        mask(j-1,i) = 1;
    end
    if j < x/2
        for k  = j:j+20
            mask(k,i) = 1;
        end
    end
    j = x;
    while j >= 1&& image(j,i) < 50
        mask(j,i) = 1;
        j = j - 1;
    end
    if j >= x/2
        for k = j-20:j
            mask(k,i) = 1;
        end
    end
end
end

