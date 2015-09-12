function data  = angle(image,vessel,mx,my,name)
% It give local minimas of vessel density
% Intution behind this : We knew that there is line joining OD and
% macula which divides the vessel density in equal parts ( due to symmerty)
% we have OD co-ordinates therefore we try to draw a line passing through
% OD having slope ranging from -30 to 30 and plot the difference of vessel
% density below and above the line.
orig = image;
orig = rgb2gray(orig);

prev = -1;
[a,b] = size(vessel);
orig = imresize(orig,[a,b]);
angle1 = -1;
flag = 0;
startangle = 0;
endangle = 0;
s = orig;
mymin = 10000;
angle1 = -45;
prevs = -1;
prev = 100;

data = [];
mycompare = 0;
for i = -30:30
    im = imrotate(vessel,i);
    [a1,b1] = size(im);
    irad = i/180*pi;
    mx1 = floor(a1/2 - (my-b/2)*sin(irad) - (a/2-mx)*cos(irad));
    my1 = floor((my-b/2)*cos(irad)-(a/2-mx)*sin(irad) + b1/2);
    im(mx1:end, :) = 0;
    r = imrotate(orig,i);
    temp = r;
    r(mx1:end, :) = 0;
    ind = find(r>10);
    [N,M] = size(ind);
    ind1 = find(im(:, :)==1);
    [n,m] = size(ind1);
    dup = n*n/N;
    
    im = imrotate(vessel,i);
    im1 = im;
    im(1:mx1, :) = 0;
    r = imrotate(orig,i);
    r(1:mx1, :) = 0;
    ind = find(r>10);
    [N,M] = size(ind);
    
    ind1 = find(im(:, :)==1);
    [n,m] = size(ind1);
    
    ddown = n*n/N;
    
    diff = dup-ddown;
    
    mycompare = abs(diff);% - 2*term;
    [i,dup, ddown,mycompare];
    
    data = [data mycompare];
end

end