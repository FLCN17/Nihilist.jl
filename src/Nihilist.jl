"""
	Nihilist

Performs encryption, decryption, and chart generation based on the VIC Soviet cipher; 
a straddling checkerboard of the nihilist family of ciphers.
"""

module Nihilist

using DataFrames
using CSV

"""
	chart_maker()

Creates a chart.
EX:
┌───┬┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐
│   ││ 3 │ 4 │ 9 │ 0 │ 7 │ 6 │ 8 │ 2 │ 5 │ 1 │
├───┼┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┤
│ X ││   │ i │ r │ e │ a │ t │ s │ n │ o │   │
│ 1 ││ v │ k │ y │ j │ d │ m │ z │ g │ c │ w │
│ 3 ││ u │ b │ l │ q │ f │ h │ p │ . │ / │ x │
└───┴┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘
The most commonly used letters are placed at the top row, and encoded as a single digit. Two gaps are left 
for the second and third rows to double encode leading with the row digit. The codes 
are placed inline as the output text, and commonly added against a key (modulo 10) of 
some psuedo-random data, pre-selected and shared.

##Returns:
DataFrame of a chart
"""

function chart_maker(; file_loc::String="", file_out::String="")
	if length(file_loc)>0 #load from file
		try
			return CSV.read(file_loc)
		catch
			error("File could not be read:\n$file_loc")
		end

	else #make a chart
		#hardcode the numbers just to grab them randomly easier,
		#and hardcode the alphabets rather then rulefind for "aeinorst"
		number_pool="0123456789"
		top_letters="aeinorst" #most commonly used letters; placed at top to encode as single digits
		bottom_letters="bcdfghjklmpquvwxyz./" #/ is special character to denote numbers
		row_numbers=["X"] #The top row has no 'row' (single digit vs double digit encoding)
		col_numbers=[]

		#build column by filling randomly 0-9, and removing that choice from list (avoid duplicates)
		while length(number_pool) > 0
			rand_spot=1+(rand(UInt8)%length(number_pool))
			push!(col_numbers, Symbol(string(number_pool[rand_spot])))
			number_pool=join(split(number_pool, number_pool[rand_spot]))
		end
		#set row numbers- any two unequal numbers 0-9
		while length(row_numbers)<3
			digit=string(rand(UInt8)%10)
			if !in(digit, row_numbers)
				push!(row_numbers, digit)
			end
		end

		#get avoid POS's - find position in col_nums where row_nums are, and use as mask
		avoid=[]
		for i in row_numbers[2:3]
			push!(avoid, findfirst(col_numbers, Symbol(i)))
		end

		#Get alphabet array ready here; set row/col indexers, and fill alphabet with ""
		row_pos=1; col_pos=1
		chart_alph=fill(" ", 3, 10)
		#just randomly 'pull' letters from list, just like we did the numbers, but dont pull if its an avoid
		#Note on 'avoid': The cipherchart double encodes letters using a leading row digit. To avoid
		#confusion with the single encoded top row when decoding, those two digits are never used alone.
		while length(top_letters) > 0
			if !in(col_pos, avoid)
				rand_spot=1+(rand(UInt8)%length(top_letters))
				chart_alph[row_pos]=string(top_letters[rand_spot])
				top_letters=join(split(top_letters, top_letters[rand_spot]))
			end
			row_pos+=3; col_pos+=1
		end
		#row_pos is shifted for the second row
		row_pos=2
		while length(bottom_letters) > 0
			rand_spot=1+(rand(UInt8)%length(bottom_letters))
			chart_alph[row_pos]=string(bottom_letters[rand_spot])
			bottom_letters=join(split(bottom_letters, bottom_letters[rand_spot]))
			row_pos+=3
			if row_pos>length(chart_alph) #hit limit, move to third row
				row_pos=3
			end
		end

		#Pass alphabet into DataFrame, and rename according to the col/rows generated.
		new_chart=DataFrame(chart_alph)
		rename!(new_chart, f=>t for (f,t)=zip(names(new_chart), col_numbers))
		new_chart[:CODE]=row_numbers

		#Save to file
		if length(file_out)>0
			try
				#Write a df to a file
				CSV.write(file_out, new_chart)
			catch
				error("File could not be read:\n$file_out")
			end
		end

		return new_chart
	end
end


#Simple helper function to check if a given letter is indeed a number
isnumeric(s::AbstractString) = parse(s) isa Number


"""
	encode(message::String, chart::DataFrame; key::Integer=0, spacing_enable::Bool=true, group_length::Integer=5, 
			group_per_line::Integer=8, key_pos::Integer=1, num_repeat::Integer=3, file_out::String="")

Handles encoding of a plaintext message into code according to the provided chart Dataframe. If a key is provided, 
it will be added to the message modulo 10.

##Parameters:
* `message` - The message to be encoded - pass as a filepath to load from a file
* `chart` - The chart Dataframe to use in encoding
* `key` - If a key is passed, added to the message %10
* `spacing_enable` - flag to enable group spacing
* `group_length` - length of each group of codes
* `group_per_line` - how many groups to include on a line
* `key_pos` - position of keygroup in output message
* `num_repeat` - How many times to repeat a number in code
* `file_out` - location to output cipher
* `padding` - Flag to pad message to length or not.

##Returns:
The encoded message, formatted accordingly.
"""

DataFrameOrPath = Union{DataFrame, String}

function encode(message::String, chart::DataFrameOrPath; key::Integer=0, spacing_enable::Bool=true, group_length::Integer=5, 
				group_per_line::Integer=8, key_pos::Integer=1, num_repeat::Integer=3, file_out::String="", padding::Bool=true)
	#file-load; check for a filepath, and throw a catch
	if length(message)<45 && isfile(message)
		try
			message = open(message)
		catch
			error("File could not be read:\n$file_out")
		end
	end
	#message handling - remove special chars and spaces
	plaintext=join(split(lowercase(message)))
	chart = (isequal(typeof(chart), String)?chart_maker(file_loc=chart):chart)
	#take each char of message, find it in the chart- if its a number, put in the 
	#/ char and encode as itself ~3x (so 11 would become /111111/, 12 = /111222/, so on)
	#find the slash in the chart 
	slashcode=""
	for col in eachcol(chart)
		row_pos=1
		for i in col[2]
			if isequal(i, "/")
				if !isequal(chart[:CODE][row_pos], "X")
					slashcode*=string(chart[:CODE][row_pos])
				end
				slashcode*=string(col[1])
			end
			row_pos+=1
		end
	end

	#key handling - BROKEN/NOT IMPLEMENTED
	key_group=""
	if key>0
		for i in 1:5-length(string(key))
			key_group*="0"
		end
		key_group*=string(key)
		key=factorial(key) #too big too fast
	end

	#Generate the actual ciphertext
	ciphertext=""; output=""
	for letter in plaintext
		#check if we got a real, live number
		if isdigit(letter)
			ciphertext*=slashcode
			for i in 1:num_repeat
				ciphertext*=letter
			end
		else
			#set up the codegroup for the given letter
			code=""
			for col in eachcol(chart)
				row_pos=1
				for i in col[2]
					if isequal(i, string(letter))
						#match to a letter
						if !isequal(chart[:CODE][row_pos], "X")
							#row encoding IF in bottom 2 rows
							code*=string(chart[:CODE][row_pos])
						end
						#col encoding
						code*=string(col[1])
					end
					row_pos+=1
				end
			end
			ciphertext*=code
		end
	end

	#Key handling - could handle as you make the output, could handle here(slower) - tbd

	if padding
		#Pad current group
		if length(ciphertext)%group_length>0
			for i in 1:(group_length-(length(ciphertext)%group_length))
				ciphertext*=string(rand(UInt8)%10)
			end
		end
	end

	#Break cipher into char groups, and handle newlines
	group_space=0; group_line=0; group_count=0
	for char in ciphertext
		output*=char
		group_space+=1
		if group_space==group_length
			output*=(spacing_enable?" ":"")
			group_space=0
			group_line+=1
			group_count+=1
		end
		if group_line==group_per_line
			output*="\n"
			group_line=0
		end
	end

	if padding
		#Pad entire cipher to square off
		if group_count%group_per_line>0
			for i in 1:(group_per_line-(group_count%group_per_line))
				for j in 1:group_length
					output*=string(rand(UInt8)%10)
				end
				output*=(spacing_enable?" ":"")
			end
		end
	end

	#if file_out given, try to output to that file
	if length(file_out)>0
		try
			open(file_out, "w") do file
				write(file, output)
			end
		catch
			error("File could not be read:\n$file_out")
		end
	end

	return output
end


"""
	decode(message::String, chart::DataFrame; key_pos::Integer=1, num_repeat::Integer=3, file_out::String="")

Handles decoding of message. If a key is provided, will be subtracted from the message, modulo 10

##Parameters:
* `message` - message to decode
* `chart` - chart to use in decoding
* `key_pos` - position of keygroup - strip off leading 0's
* `num_repeat` - used to interpret numbers with proper formatting
* `file_out` - location to output plaintext message

##Returns:
Decoded message.
"""

function decode(message::String, chart::DataFrameOrPath; key_pos::Integer=1, num_repeat::Integer=3, file_out::String="")
	#check if a file, if so, load as message
	if length(message)<45 && isfile(message)
		try
			message = read(message, String)
		catch
			error("File could not be read:\n$file_loc")
		end
	end
	ciphertext=join(split(message))
	chart = (isequal(typeof(chart),String)?chart_maker(file_loc=chart):chart)

	plaintext=""
	index=1
	while index<length(ciphertext)
		#check if its in a row- if so, use next letter as the col, and move forward
		if in(string(ciphertext[index]), chart[:CODE]) #double encoded
			#use match in ROWCODE to determine which letter
			letter=chart[Symbol(ciphertext[index+1])][findfirst(chart[:CODE],string(ciphertext[index]))]
			index+=2
		else #single encoded
			#grab by the col symbol
			letter=chart[Symbol(ciphertext[index])][1]
			index+=1
		end
		if isequal(letter, "/") && index+1<length(ciphertext)
			#numbers next, handle accordingly
			plaintext*=ciphertext[index+1]
			index+=num_repeat
		else
			plaintext*=letter
		end
	end

	#if file_out given, try to output to that file
	if length(file_out)>0
		try
			open(file_out, "w") do file
				write(file, plaintext)
			end
		catch
			error("File could not be read:\n$file_out")
		end
	end

	return plaintext
end

end