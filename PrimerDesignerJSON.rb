#Primer Designer for JSON

chr = ARGV[0]
snp = ARGV[1]
unless ARGV[1]
	puts "Error: Check Chromosome and SNP Information"
end

#set region for fasta extraction
padding = 1000 
snp = snp.to_i
snp_start = snp-padding
snp_end = snp+padding

#use samtools faidx to extract region around snp
samtools_base_command = "~/tools/samtools faidx ~/Genome/hg19.fa "
genomic_interval = "#{chr}:#{snp_start}-#{snp_end}"
samtools_exec_command =  samtools_base_command + genomic_interval
samtools = IO.popen(samtools_exec_command)
fasta_lines  = samtools.readlines.each{|r|r.rstrip!}
samtools.close

#process multi-line fasta file
fasta_head = fasta_lines.shift
template_seq = fasta_lines.join('')

#build input parameters for primer3_core
config = {} 
config["SEQUENCE_ID"] = "p_#{chr}_#{snp}" 
config["SEQUENCE_TEMPLATE"] = template_seq.upcase
config["PRIMER_THERMODYNAMIC_PARAMETERS_PATH"] = File.expand_path('~') + "/tools/primer3-release-2.3.6/primer3_config/"
# config["SEQUENCE_TARGET"] = 1000           #what should be the target sequence (target base, length of target)
# config["PRIMER_TASK"] = "pick_discriminative_primers"   #what should the word be

#write primer3_core inputs to tmp file
primer3_input_file_handle = "p_#{chr}_#{snp}.txt"
primer3_input_file = File.open(primer3_input_file_handle, "w")
config.each do |k,v|
	primer3_input_file.write("#{k}=#{v}\n")
end
primer3_input_file.write("=\n")
primer3_input_file.close 

#execute primer3_core with input file
p3_command = "~/tools/primer3-release-2.3.6/primer3_core #{primer3_input_file_handle}"
primer3 = IO.popen(p3_command)
primer3_output = primer3.readlines
primer3.close

#process primer3 output to build primer3_hash
primer3_hash = {}
primer3_output.each do |l|
	l.rstrip!
	k,v = l.split("=")
	primer3_hash[k] = v
end

#puts primer3_hash

#parse primer3_hash to primer_hash (which stores only 'name => sequence' at this point) 
primer_hash = {}
(0..4).each do |i|
	primer_hash["#{chr}_#{snp}_#{i}_F"] = primer3_hash["PRIMER_LEFT_#{i}_SEQUENCE"] 
	primer_hash["#{chr}_#{snp}_#{i}_R"] = primer3_hash["PRIMER_RIGHT_#{i}_SEQUENCE"]
end

#check primer_hash composition
puts "Primer Hash: \n"
puts primer_hash 

#print fasta format: 
puts "\nFasta Format: \n\n"
primer_hash.each do |header,sequence|
	puts ">"+header
	puts sequence
end

#print sigma ordering format: 
puts "\nSigma Bulk Order Format: \n\n"
synthesis_scale=["0.025"]
synthesis_purification=["DST"]
primer_hash.each do |header,sequence|
	puts [header,sequence,synthesis_scale,synthesis_purification].join(",")+"\n"
end

# JSON_array = []
# (0..4).each do |i|
# 	JSON_hash = {}
# 	JSON_hash["Forward_primer_#{i}"] = primer3_hash["PRIMER_LEFT_#{i}_SEQUENCE"]
# 	JSON_hash["Forward_primer_#{i}_TM"] = primer3_hash["PRIMER_LEFT_#{i}_TM"]
# 	JSON_hash["Reverse_primer_#{i}"] = primer3_hash["PRIMER_RIGHT_#{i}_SEQUENCE"]
# 	JSON_hash["Reverse_primer_#{i}_TM"] = primer3_hash["PRIMER_RIGHT_#{i}_TM"]
# 	JSON_array.push(JSON_hash)
# end
# puts JSON_array


JSON_ouput_hash = {}
(0..4).each do |i|
	JSON_hash = {}
	JSON_hash["forward_primer_sequence"] = primer3_hash["PRIMER_LEFT_#{i}_SEQUENCE"]
	JSON_hash["forward_primer_tm"] = primer3_hash["PRIMER_LEFT_#{i}_TM"]
	JSON_hash["reverse_primer_sequence"] = primer3_hash["PRIMER_RIGHT_#{i}_SEQUENCE"]
	JSON_hash["reverse_primer__tm"] = primer3_hash["PRIMER_RIGHT_#{i}_TM"]
	JSON_hash["amplicon_size"] = primer3_hash["PRIMER_PAIR_#{i}_PRODUCT_SIZE"]
	JSON_ouput_hash["amplicon_#{i}"] = JSON_hash
end
puts JSON_ouput_hash




# JSON_hash = {}
# (0..4).each do |i|
# 	JSON_hash["Primer_#{i}_hash" = ["Forward_primer_#{i}"] = primer3_hash["PRIMER_LEFT_#{i}_SEQUENCE"]
# 								   ["Forward_primer_#{i}_TM"] = primer3_hash["PRIMER_LEFT_#{i}_TM"]
# 								   ["Reverse_primer_#{i}"] = primer3_hash["PRIMER_RIGHT_#{i}_SEQUENCE"]
# 	                               ["Reverse_primer_#{i}_TM"] = primer3_hash["PRIMER_RIGHT_#{i}_TM"]]
# end
# puts "JSON Hash: \n"
# puts JSON_hash

	

# JSON_array = []
# (0..4).each do |i|


# JSON_array = []
# 	(0..4).each do |i|



#give out all primer pairs
#build hash, fp, rp, tm, amplicon length (outside edge of fp to outside edge of rp) (#Primer_pair_product_size)
#keep track of genomic length 
#build array of those 5
