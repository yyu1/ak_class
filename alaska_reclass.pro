in_file = '/Volumes/Global_250m/alaska_rush/ak_nlcd_2001_landcover.byt'

out_file = '/Volumes/Global_250m/alaska_rush/ak_nlcd_2001_landcover_240m.byt'

xdim = 124236ULL
ydim = 67844ULL

xdim_out = xdim/8
ydim_out = ydim/8

in_line = bytarr(xdim,8)

openr, 1, in_file
openw, 2, out_file

out_line = bytarr(xdim_out)

for j=0ULL, ydim_out-1 do begin
	if (j mod 100 eq 0) then print, j
	readu, 1, in_line
	for i=0ULL, xdim_out-1 do begin
		cur_box = in_line[i*8:(i+1)*8-1,*]
		out_line[i] = majority(cur_box)
	endfor

	writeu, 2, out_line
	out_line[*] = 0
endfor

close, /all

end
