;Use majority rule to aggregate classification.
;Takes an array of byte values as input
;returns 1 byte as output

;Does some special rules on top of majority rule for forest types


;NLCD 2001 Alaska class types
;        Enumerated_Domain_Value: 1
;        Enumerated_Domain_Value_Definition: No data value, Alaska zones only
;
;        Enumerated_Domain_Value: 11
;        Enumerated_Domain_Value_Definition:
;            Open Water - All areas of open water, generally with less than 25% cover or vegetation or soil 
;
;        Enumerated_Domain_Value: 12
;        Enumerated_Domain_Value_Definition:
;            Perennial Ice/Snow - All areas characterized by a perennial cover of ice and/or snow, generally greater than 25% of total cover. 
;
;        Enumerated_Domain_Value: 21
;        Enumerated_Domain_Value_Definition:
;            Developed, Open Space - Includes areas with a mixture of some constructed materials, but mostly vegetation in the form of lawn grasses. Impervious surfaces account for less than 20 percent of total cover. These areas most commonly include large-lot single-family housing units, parks, golf courses, and vegetation planted in developed settings for recreation, erosion control, or aesthetic purposes 
;
;        Enumerated_Domain_Value: 22
;        Enumerated_Domain_Value_Definition:
;            Developed, Low Intensity -Includes areas with a mixture of constructed materials and vegetation. Impervious surfaces account for 20-49 percent of total cover. These areas most commonly include single-family housing units. 
;        Enumerated_Domain_Value_Definition_Source: NLCD 2001 land cover class descriptions
;
;        Enumerated_Domain_Value: 23
;        Enumerated_Domain_Value_Definition:
;            Developed, Medium Intensity - Includes areas with a mixture of constructed materials and vegetation. Impervious surfaces account for 50-79 percent of the total cover. These areas most commonly include single-family housing units. 
;
;        Enumerated_Domain_Value: 24
;        Enumerated_Domain_Value_Definition:
;            Developed, High Intensity - Includes highly developed areas where people reside or work in high numbers. Examples include apartment complexes, row houses and commercial/industrial. Impervious surfaces account for 80 to 100 percent of the total cover. 
;        Enumerated_Domain_Value_Definition_Source: NLCD 2001 land cover class descriptions
;
;        Enumerated_Domain_Value: 31
;        Enumerated_Domain_Value_Definition:
;            Barren Land (Rock/Sand/Clay) - Barren areas of bedrock, desert pavement, scarps, talus, slides, volcanic material, glacial debris, sand dunes, strip mines, gravel pits and other accumulations of earthen material. Generally, vegetation accounts for less than 15% of total cover. 
;
;        Enumerated_Domain_Value: 41
;        Enumerated_Domain_Value_Definition:
;            Deciduous Forest - Areas dominated by trees generally greater than 5 meters tall, and greater than 20% of total vegetation cover. More than 75 percent of the tree species shed foliage simultaneously in response to seasonal change. 
;
;        Enumerated_Domain_Value: 42
;        Enumerated_Domain_Value_Definition:
;            Evergreen Forest - Areas dominated by trees generally greater than 5 meters tall, and greater than 20% of total vegetation cover. More than 75 percent of the tree species maintain their leaves all year. Canopy is never without green foliage. 
;
;        Enumerated_Domain_Value: 43
;        Enumerated_Domain_Value_Definition:
;            Mixed Forest - Areas dominated by trees generally greater than 5 meters tall, and greater than 20% of total vegetation cover. Neither deciduous nor evergreen species are greater than 75 percent of total tree cover. 
;
;        Enumerated_Domain_Value: 51
;        Enumerated_Domain_Value_Definition:
;            Dwarf Scrub - Alaska only areas dominated by shrubs less than 20 centimeters tall with shrub canopy typically greater than 20% of total vegetation. This type is often co-associated with grasses, sedges, herbs, and non-vascular vegetation tundra and may be periodically or seasonally wet and/or saturated with wate. This type commonly occurs in alpine or tundra areas and may contain permafrost. 
;
;        Enumerated_Domain_Value: 52
;        Enumerated_Domain_Value_Definition:
;            Shrub/Scrub - Areas dominated by shrubs less than 5 meters tall with shrub canopy typically greater than 20% of total vegetation. This class includes true shrubs, young trees in an early successional stage or trees stunted from environmental conditions. 
;
;        Enumerated_Domain_Value: 71
;        Enumerated_Domain_Value_Definition:
;            Grassland/Herbaceous - Areas dominated by grammanoid or herbaceous vegetation, generally greater than 80% of total vegetation. These areas are not subject to intensive management such as tilling, but can be utilized for grazing. 
;
;        Enumerated_Domain_Value: 72
;        Enumerated_Domain_Value_Definition:
;            Sedge/Herbaceous - Alaska only areas dominated by sedges and forbs, generally greater than 80% of total vegetation. This type can occur with significant other grasses or other grass like plants, and includes sedge tundra, and sedge tussock tundra and may be periodically or seasonally wet and/or saturated. This type may contain permafrost. 
;
;        Enumerated_Domain_Value: 74
;        Enumerated_Domain_Value_Definition:
;            Moss- Alaska only areas dominated by mosses generally greater than 80% of total vegetation. 
;
;        Enumerated_Domain_Value: 81
;        Enumerated_Domain_Value_Definition:
;            Pasture/Hay - Areas of grasses, legumes, or grass-legume mixtures planted for livestock grazing or the production of seed or hay crops, typically on a perennial cycle. Pasture/hay vegetation accounts for greater than 20 percent of total vegetation. 
;
;        Enumerated_Domain_Value: 82
;        Enumerated_Domain_Value_Definition:
;            Cultivated Crops - Areas used for the production of annual crops, such as corn, soybeans, vegetables, tobacco, and cotton, and also perennial woody crops such as orchards and vineyards. Crop vegetation accounts for greater than 20 percent of total vegetation. This class also includes all land being actively tilled. 
;
;        Enumerated_Domain_Value: 90
;        Enumerated_Domain_Value_Definition:
;            Woody Wetlands - Areas where forest or shrub land vegetation accounts for greater than 20 percent of vegetative cover and the soil or substrate is persistently saturated with or covered with water. 
;
;        Enumerated_Domain_Value: 95
;        Enumerated_Domain_Value_Definition:
;            Emergent Herbaceous Wetlands - Areas where perennial herbaceous vegetation accounts for greater than 80 percent of vegetative cover and the soil or substrate is persistently saturated with or covered with water. 

;return 101 for mixed non-forest


Function majority, class_arr
	n_pixels = n_elements(class_arr)

	hist = histogram(class_arr)
	hist_max = max(hist,max_i)

	if (hist_max gt n_pixels/2) then return, byte(max_i)  ; One class is > 50% so return this class

	;check is forested/non-forested
	total_for_pix = hist[41]+hist[42]+hist[43]+hist[90]
	total_srb_pix = hist[51]+hist[52]

	if (total_for_pix gt (0.3*n_pixels)) then begin
		;is forest, check for dominant forest type
		if hist[41] gt 0.5*total_for_pix then return, 41B
		if hist[42] gt 0.5*total_for_pix then return, 42B
		if hist[43] gt 0.5*total_for_pix then return, 43B
		if hist[90] gt 0.5*total_for_pix then return, 90B
		return, 43B   ;mixed
	endif else begin
		;non-forest, is it shrub
		if (total_srb_pix gt (0.3*n_pixels)) then begin
			if hist[51] gt 0.5*total_srb_pix then return, 51B
			return, 52B
		endif

		;non-shrub, return 101 as mixed non-forest
		return, 101B
	endelse

End
