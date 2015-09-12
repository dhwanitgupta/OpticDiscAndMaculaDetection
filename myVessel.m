function vessel = myVessel(im)
% This is a function to detect vessels in retinal image
% this function detect the major vessels map 
% it ignores the vessels with less width

% from the paper Zang 

    S0 = im(:,:,2);
    S0 = uint8(imcomplement(S0));
    
    imgVess = uint8(zeros(size(S0)));
    
    Sopen = uint8(zeros(size(S0,1),size(S0,2),12));
    Sop = uint8(zeros(size(S0)));
    
    
    
    i=1;
    for q = 0:15:165
        stline = strel('line',10,q);
        Sopen(:,:,i) = imopen(S0,stline);
        Sop = max(Sop, Sopen(:,:,i));           %supremum
        i = i+1;
    end
    
  
    Sop = imreconstruct(S0,Sop);            %Resconstruct
   
    
   Ssum = uint8(zeros(size(S0)));       %sum of top hat
   for i=1:12
        Ssum = Ssum + (Sop - Sopen(:,:,i));
   end
   

   h = fspecial('log',7,7/5);           %log filter
   Slap = imfilter(Ssum,h);
   
   
   %final step 
   
   Smax = uint8(zeros(size(S0)));       %morphological opening;
   for q = 0:15:165
       stline = strel('line',20,q);
       Smax = max(Smax, imopen(Slap,stline));           
   end
   S1 = imreconstruct(Slap, Smax);
   
   
   Smin = uint8(zeros(size(S0)));
   for q = 0:15:165
       stline = strel('line',20,q);
       Smin = min(Smax, imclose(S1,stline));           
   end
   S2 = imreconstruct(S1, Smin);


    Smax = uint8(zeros(size(S0)));
   for q = 0:15:165
       stline = strel('line',25,q);
       Smax = max(Smax, imopen(S2,stline));           %supremum
   end
   Sres = imreconstruct(S2,Smax);

    
   bw = Sres>0.8;
   imgt = logical(zeros(size(S0)));       
   
   % some post-processing 
   % This section removes the vessels with less width and height
   % we set threshold of length to 20
   
   for q = 0:15:165
       stline = strel('line',20,q);
       imgt = imgt | imopen(bw,stline);
   end
      
   
   [L,NUM] = bwlabel(imgt);
   a = [];
   for i=1:NUM
        a = [a size(find(L==i))];
   end
   med = median(a);
   
   % remove the vessels having less than 60 connected pixel
   for i=1:NUM
       ind = find(L==i);
       if size(ind,1) < 60
           imgt(ind) = 0;
       end
   end
   
    vessel = Sres;
end