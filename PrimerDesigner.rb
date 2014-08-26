#Ruby

chr = ARGV[0]
snp = ARGV[1]

unless ARGV[1]
	puts "Error: Check Chromosome and SNP Information"
end

snp = snp.to_i

snp_start = snp-1000
snp_end = snp+1000

genomic_interval = "#{chr}:#{snp_start}-#{snp_end}"
base_command = "~/Tools/samtools faidx ~/Genome/hg19.fa "

exec_command =  base_command + genomic_interval

samtools = IO.popen(exec_command)
fasta_lines  = samtools.readlines.each{|r|r.rstrip!}


fasta_head = fasta_lines.shift
seq = fasta_lines.join('')

config = {} 

config["SEQUENCE_ID"] = "p_#{chr}_#{snp}" 
config["SEQUENCE_TEMPLATE"] = seq.upcase
#config["SEQUENCE_TARGET"] = 1000           #what should be the target sequence (target base, length of target)
#config["PRIMER_TASK"] = "discriminative"   #what should the word be


#primer3 = config.each {|k,v| puts "#{k}=#{v}"}
#config.each {|k,v| puts "#{k}=#{v}"}

# $stdout = File.open("p_#{chr}_#{snp}.txt", 'w')
# config.each {|k,v| puts "#{k}=#{v}"}
# puts "=" 
# $stdout.close


out = File.open("p_#{chr}_#{snp}.txt", "w")
config.each do |k,v|
	out.write("#{k}=#{v}\n")
end
out.write("PRIMER_THERMODYNAMIC_PARAMETERS_PATH=/Users/maxgold/Sites/PrimerDesign/bin/primer3-release-2.3.6/primer3_config/\n")
out.write("=\n")
out.close 



p3_command = "./bin/primer3-release-2.3.6/primer3_core p_#{chr}_#{snp}.txt"
primer3 = IO.popen(p3_command)

primer3_output = primer3.readlines
primer3.close

primer3_hash = {}
primer3_output.each do |l|
	l.rstrip!
	k,v = l.split("=")
	primer3_hash[k] = v
end


#puts primer3_hash.keys

primer_array = [">#{chr}_#{snp}_0_F" + " " + "Tm=" + primer3_hash["PRIMER_LEFT_0_TM"], primer3_hash["PRIMER_LEFT_0_SEQUENCE"], 
				">#{chr}_#{snp}_0_R" + " " + "Tm=" + primer3_hash["PRIMER_RIGHT_0_TM"], primer3_hash["PRIMER_RIGHT_0_SEQUENCE"],
				">#{chr}_#{snp}_1_F" + " " + "Tm=" + primer3_hash["PRIMER_LEFT_1_TM"], primer3_hash["PRIMER_LEFT_1_SEQUENCE"],
				">#{chr}_#{snp}_1_R" + " " + "Tm=" + primer3_hash["PRIMER_RIGHT_1_TM"], primer3_hash["PRIMER_RIGHT_1_SEQUENCE"], 
				">#{chr}_#{snp}_2_F" + " " + "Tm=" + primer3_hash["PRIMER_LEFT_2_TM"], primer3_hash["PRIMER_LEFT_2_SEQUENCE"],
				">#{chr}_#{snp}_2_R" + " " + "Tm=" + primer3_hash["PRIMER_RIGHT_2_TM"], primer3_hash["PRIMER_RIGHT_2_SEQUENCE"]
				]
#assuming Primer_LEFT = Forward Primer


puts primer_array


array_ID_0_F=["#{chr}_#{snp}_0_F"]
array_primer_0_F=[primer3_hash["PRIMER_LEFT_0_SEQUENCE"]]
array_ID_0_R=["#{chr}_#{snp}_0_R"]
array_primer_0_R=[primer3_hash["PRIMER_RIGHT_0_SEQUENCE"]]

array_ID_1_F=["#{chr}_#{snp}_1_F"]
array_primer_1_F=[primer3_hash["PRIMER_LEFT_1_SEQUENCE"]]
array_ID_1_R=["#{chr}_#{snp}_1_R"]
array_primer_1_R=[primer3_hash["PRIMER_RIGHT_1_SEQUENCE"]]

array_ID_2_F=["#{chr}_#{snp}_2_F"]
array_primer_2_F=[primer3_hash["PRIMER_LEFT_2_SEQUENCE"]]
array_ID_2_R=["#{chr}_#{snp}_2_R"]
array_primer_2_R=[primer3_hash["PRIMER_RIGHT_2_SEQUENCE"]]

array_scale=["0.025"]
array_purification=["DST"]


sigma_array = [[array_ID_0_F, array_primer_0_F, array_scale, array_purification], 
			   [array_ID_0_R, array_primer_0_R, array_scale, array_purification],
			   [array_ID_1_F, array_primer_1_F, array_scale, array_purification],
			   [array_ID_1_R, array_primer_1_R, array_scale, array_purification],
			   [array_ID_2_F, array_primer_2_F, array_scale, array_purification],
			   [array_ID_2_R, array_primer_2_R, array_scale, array_purification]]

puts sigma_array.map{|a|"#{a.join(",")}\n"}









#primer3_command = "./primer3_core < p_#{chr}_#{snp}.txt"

#output = IO.popen(primer3_command)

#exec /.primer3_core < "p_#{chr}_#{snp}.txt"

#file = File.new('p_#{chr}_#{snp}.txt', 'w')
#file.puts primer3 
#file.close


#{:sequence_id =>  , :sequence_template => , :sequence_target => , :primer_task => }
#key = sequ value is seq

#exec "~/Tools/samtools faidx ~/Genome/hg19.fa #{chr}:#{snp_start}-#{snp_end} >tmp.fa"

#exec base command + custom command


#puts "~Tools/samtools faidx hg19.fa #{chr}:#{snp_start}-#{snp_end} >tmp.fa"

#execute 
