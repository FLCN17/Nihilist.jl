using Nihilist

@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end


##Simple chart make, message send with upper/lowercase letters, numbers, period and special chars
function run_test1()
	chart = Nihilist.chart_maker()
	cleartext="The Nihilist cipher was used extensively by the Soviets during and after the war in the 40s."
	ciphertext = Nihilist.encode(cleartext, chart)
	plaintext = Nihilist.decode(ciphertext, chart)
	strip_text=join(split(lowercase(cleartext)))
	return isequal(strip_text, plaintext[1:length(strip_text)])
end

function run_test2()
	chart = Nihilist.chart_maker(file_loc="~/gitHub/chart.csv")
	cleartext="The Nihilist cipher was used extensively by the Soviets during and after the war in the 40s."
	ciphertext = Nihilist.encode(cleartext, "~/gitHub/chart.csv", spacing_enable=false, num_repeat=4, file_out="output.txt")
	plaintext = Nihilist.decode("output.txt", "~/gitHub/chart.csv", num_repeat=4, file_out="clearoutput.txt")
	strip_text=join(split(lowercase(cleartext)))
	return isequal(strip_text, plaintext[1:length(strip_text)])
end

function run_test3()
	chart = Nihilist.chart_maker()
	cleartext="The Nihilist cipher was used extensively by the Soviets during and after the war in the 40s."
	ciphertext = Nihilist.encode(cleartext, chart, group_length=3, group_per_line=4, num_repeat=3, file_out="output2.txt")
	plaintext = Nihilist.decode("output2.txt", chart, num_repeat=3, file_out="clearoutput2.txt")
	strip_text=join(split(lowercase(cleartext)))
	return isequal(strip_text, plaintext[1:length(strip_text)])
end

function run_test4()
	chart = chart_maker()
	cleartext="The VIC cipher was a pencil and paper cipher used by the Soviet spy Reino Hayhanen codenamed VICTOR.
				If the cipher were to be given a modern technical name it would be known as a straddling bipartite 
				monoalphabetic substitution superenciphered by modified double transposition.1 However by general 
				classification it is part of the Nihilist family of ciphers. It was arguably the most complex handoperated 
				cipher ever seen when it was first discovered. The initial analysis done by the American National Security 
				Agency NSA in 1953 did not absolutely conclude that it was a hand cipher but its placement in a hollowed 
				out 5c coin implied it could be broken by pencil and paper. The VIC cipher remained unbroken until more 
				information about its structure was available. Although certainly not as complex or secure as modern 
				computer operated stream ciphers or block ciphers in practice messages protected by it resisted all 
				attempts at cryptanalysis by at least the NSA from its discovery in 1953 until Hayhanens defection 
				in 1957."
	ciphertext = encode(cleartext, chart, padding=false)
	plaintext = decode(ciphertext, chart)
	strip_text=join(split(lowercase(cleartext)))
	return isequal(strip_text, plaintext[1:length(strip_text)])
end

@testset "Encode/Decode" begin
	@test run_test1()
	@test run_test2()
	@test run_test3()
	@test run_test4()
end


#= output-

3×11 DataFrames.DataFrame
│ Row │ 1 │ 3 │ 7 │ 6 │ 2 │ 4 │ 5 │ 8 │ 0 │ 9 │ CODE │
├─────┼───┼───┼───┼───┼───┼───┼───┼───┼───┼───┼──────┤
│ 1   │ X │ X │ t │ n │ r │ i │ a │ o │ e │ s │ X    │
│ 2   │ z │ . │ f │ y │ q │ d │ l │ b │ p │ h │ 3    │
│ 3   │ v │ k │ u │ g │ m │ j │ c │ x │ / │ w │ 1    │

The Nihilist cipher was used extensively by the Soviets during and after the war in the 40s.
 => 
73906 43935 49715 43039 02195 91790 34018 70694 
11035 36383 67390 98114 07934 17246 16563 45377 
02739 01952 46739 01044 41000 09337 87615 48565 
 => 
thenihilistcipherwasusedextensivelybythesovietsduringandafterthewarinthe40s.totncioan
=#
