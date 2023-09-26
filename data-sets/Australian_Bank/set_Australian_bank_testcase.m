function testcase = set_Australian_bank_testcase()
% set_Australian_bank_testcase: sets the initial variable for testing the 
% Austrsalian bank dataset

%% Filename
testcase.filename = 'Australian_bank';
testcase.legendFilename = [testcase.filename, '_legend'];
testcase.delimiter = '\t';
testcase.block = 3;
testcase.listOfAgents = 1:11;

testcase.h = 1;
testcase.name = [testcase.filename, '_estimates_h=', num2str(testcase.h)];
testcase.result_table_filename = [testcase.name, '.txt'];
testcase.result_table_vertices_filename = [testcase.name , '_vertices.txt'];
testcase.result_table_rays_filename = [testcase.name,'_rays.txt']; 
end