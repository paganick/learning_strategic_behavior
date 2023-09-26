function testcase = set_Medici_testcase()
% set_Medici_testcase: sets the initial variable for testing the Medici
% dataset

%% Filename
testcase.filename = 'Medici_combined';
%testcase.filename = 'Medici_marriage_directed';
%testcase.filename = 'Medici_business_directed';
testcase.legendFilename = [testcase.filename, '_legend'];
testcase.delimiter = '\t';
testcase.block = 1;
testcase.listOfAgents = 9;

testcase.h = 1;

testcase.name = [testcase.filename, '_estimates_h=', num2str(testcase.h)];
testcase.result_table_filename = [testcase.name, '.txt'];
testcase.result_table_vertices_filename = [testcase.name, '_vertices.txt'];
testcase.result_table_rays_filename = [testcase.name, '_rays.txt']; 

end

%1: Acciaiuoli
%2: Albizzi
%3: Barbadori
%4: Bischeri
%5: Castellani
%6: Ginori
%7: Guadagni
%8: Lamberteschi
%9: Medici
%10: Pazzi
%11: Peruzzi
%12: Ridolfi
%13: Salviati
%14: Strozzi
%15: Tornabuoni