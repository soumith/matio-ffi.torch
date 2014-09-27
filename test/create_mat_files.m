# call this script if you want to generate the test .mat files
# > octave create_mat_files.m

seq = zeros(1, 24)

for i=1:24
  seq(i) = i;
end

a = reshape(seq, [2 3 4])

save -mat7-binary 'test.mat' a


m = [1, 1, 2; 3, 5, 8; 13, 21, 34]

c = cell();

c(1) = "one";
c(2) = "two";
c(3) = 3;

s = struct ("matrix", m, "scalar", 2, "cell_array", {c});

save -mat7-binary 'test2.mat' m c s;


