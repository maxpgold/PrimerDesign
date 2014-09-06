# Ruby Useful Examples



#Hash of Hashes
#assigns the JSON_output_hash as a hash of JSON_hash's ...
#which call on primer3_hash to get its data


JSON_ouput_hash = {}
JSON_hash = {}
(0..4).each do |i|
	JSON_hash["forward_primer_sequence"] = primer3_hash["PRIMER_LEFT_#{i}_SEQUENCE"]
	JSON_hash["forward_primer_tm"] = primer3_hash["PRIMER_LEFT_#{i}_TM"]
	JSON_hash["reverse_primer_sequence"] = primer3_hash["PRIMER_RIGHT_#{i}_SEQUENCE"]
	JSON_hash["reverse_primer__tm"] = primer3_hash["PRIMER_RIGHT_#{i}_TM"]
	JSON_hash["amplicon_size"] = primer3_hash["PRIMER_PAIR_#{i}_PRODUCT_SIZE"]
	JSON_ouput_hash["amplicon_#{i}"] = JSON_hash
end
puts JSON_ouput_hash


#Array of Hashes