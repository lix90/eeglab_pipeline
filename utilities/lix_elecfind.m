function ind = lix_elecfind( chanLabels, elecname )

if ~iscellstr(chanLabels)
    disp('first input must be cellstr of channel labels')
end

ind = [];
names = chanLabels;

if ~exist( 'elecname', 'var' ); error( 'no electrodes defined' ); end;
eleclass = class( elecname );

switch eleclass
case 'char'
	E = find(strcmpi( names, elecname ));
	ind = [ind, E];

case 'cell'
	numElec = numel( elecname );	
	for indE = 1:numElec
		E = find(strcmpi( names, elecname( indE )));
		ind = [ ind, E ];
	end 
end

