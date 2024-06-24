"""
Converts a multiformat equation string to a list of variables and/or wildcards.
# Arguments
- `equation::String`: a multiformat (Stata, R, Julia, etc) equation string.
"""
function equation_str_to_strarr(equation::String)
	if occursin("~", equation)
		equation = replace(equation, r"\s+|\s+$/g" => " ")
		dep_indep = split(equation, "~")
		equation = [String(strip(ss)) for ss in vcat(dep_indep[1], split(dep_indep[2], "+"))]
	else
		equation = [String(strip(ss)) for ss in split(replace(equation, r"\s+|\s+$/g" => ","), ",")]
	end
	return equation
end

"""
Gets datanames from data structure and returns as a Vector.
# Arguments
- `data::Union{DataFrames.DataFrame, Array, Tuple}`: a DataFrame or an Array or a Tuple of a DataFrame or an Array.
- `datanames::Union{Nothing, Vector{String}, Vector{Symbol}}: an optional array of datanames.
"""
function get_datanames(data::Union{DataFrames.DataFrame, Array, Tuple}, datanames::Union{Nothing, Vector{String}, Vector{Symbol}})
	if isa(data, DataFrames.DataFrame)
		datanames = names(data)
	elseif isa(data, Tuple)
		datanames = data[2]
	elseif (datanames === nothing)
		error(DATANAMES_REQUIRED)
	end
	return datanames
end

"""
Converts a multiformat equation string array to a symbol array based on datanames.
# Arguments
- `equation::Vector{String}`: a DataFrame or a Tuple of a DataFrame.
- `datanames::Union{Vector{String}, Vector{Symbol}}`: a vector of stings and/or symbols.
"""
function equation_strarr_to_symarr(equation::Vector{String}, datanames::Union{Vector{String}, Vector{Symbol}})
	n_equation = []
	for e in equation
		e = replace(e, "." => "*")
		if e[end] == '*'
			datanames_arr = vec([String(key)[1:length(e[1:end-1])] == e[1:end-1] ? String(key) : nothing for key in datanames])
			append!(n_equation, filter!(x -> x !== nothing, datanames_arr))
		else
			append!(n_equation, [e])
		end
	end
	return map(Symbol, unique(n_equation))
end

"""
Converts string and/or symbol datanames array to symbol datanames set array.
# Arguments
- `datanames::Union{Vector{String}, Vector{Symbol}}`: an array of stings and/or symbols.
"""
function datanames_strarr_to_symarr!(datanames::Union{Vector{String}, Vector{Symbol}})
	dn = datanames
	datanames::Vector{Symbol} = []
	for name in dn
		push!(datanames, Symbol(name))
	end
	return datanames
end

"""
Gets DataFrame or Array from Tuple if is needed.
# Arguments
- `data::Union{DataFrames.DataFrame, Array, Tuple}`: a DataFrame or an Array or a Tuple of a DataFrame or an Array.
"""
function convert_if_is_tuple_to_array(data::Union{DataFrames.DataFrame, Array, Tuple})
	if isa(data, Tuple)
		data = data[1]
	end
	return data
end

"""
Sorts data based on time variable.
# Arguments
- `data::Union{DataFrames.DataFrame, Array}`: a DataFrame or an Array.
- `time`: a time variable.
- `datanames::Vector{Symbol}`: an array of stings and/or symbols.
"""
function sort_data_by_time(data::Union{DataFrames.DataFrame, Array}, time::Symbol, datanames::Vector{Symbol})
	if isa(data, DataFrames.DataFrame)
		sort!(data, time)
	elseif isa(data, Array)
		pos = findfirst(isequal(time), datanames)
		data = gsregsortrows(data, [pos])
	end
	return data
end

"""
Sorts array data.
# Arguments
- TODO: Set arguments
"""
function gsregsortrows(B::AbstractMatrix, cols::Array; kws...)
	for i in 1:length(cols) # TODO: Refactor
		if i == 1
			p = sortperm(B[:, cols[i]]; kws...)
			B = B[p, :]
		else
			i0_old = 0
			i1_old = 0
			i0_new = 0
			i1_new = 0
			for j in 1:size(B, 1)-1
				if B[j, cols[1:i-1]] == B[j+1, cols[1:i-1]] && i0_old == i0_new
					i0_new = j
				elseif B[j, cols[1:i-1]] != B[j+1, cols[1:i-1]] && i0_old != i0_new && i1_new == i1_old
					i1_new = j
				elseif i0_old != i0_new && j == size(B, 1) - 1
					i1_new = j + 1
				end
				if i0_new != i0_old && i1_new != i1_old
					p = sortperm(B[i0_new:i1_new, cols[i]]; kws...)
					B[i0_new:i1_new, :] = B[i0_new:i1_new, :][p, :]
					i0_old = i0_new
					i1_old = i1_new
				end
			end
		end
	end
	return B
end

"""
Removes columns and keeps only selected variables ones.
# Arguments
- `data::Union{DataFrames.DataFrame, Array}`: a DataFrame or an Array.
- `depvar::Symbol`: the dependent variable.
- `expvars::Vector{Symbol}`: the explanatory variables.
- `datanames::Vector{Symbol}`: an array of stings and/or symbols.
"""
function filter_data_valid_columns(data::Union{DataFrames.DataFrame, Array}, depvar::Symbol, expvars::Vector{Symbol}, datanames::Vector{Symbol})
	vars = vcat([depvar], expvars)
	if isa(data, DataFrames.DataFrame)
		data = data[:, vars]
	elseif isa(data, Array)
		columns = []
		for var in vars
			append!(columns, get_data_column_pos(var, datanames))
		end
		data = data[:, columns]
	end
	return data
end

"""
Removes rows that has empty values.
# Arguments
- `data::Union{DataFrames.DataFrame, Array}`: a DataFrame or an Array.
"""
function filter_rows_with_empty_values(data::Union{DataFrames.DataFrame, Array})
	if isa(data, DataFrames.DataFrame)
		data = data[completecases(data), :]
	elseif isa(data, Array{Union{Missing, Float64}, 2})
		for i in axes(data, 2)
			data = data[map(b -> !b, ismissing.(data[:, i])), :]
		end
	elseif isa(data, Array)
		for i in in
			axes(data, 2)
			data = data[data[:, i].!="", :]
		end
	end
	return data
end

"""
Converts DataFrame data to Matrix if is needed.
# Arguments
- `data::Union{DataFrames.DataFrame, Array}`: a DataFrame or an Array.
"""
function convert_if_is_dataframe_to_array(data::Union{DataFrames.DataFrame, Array})
	if isa(data, DataFrames.DataFrame)
		data = Matrix{Float64}(data)
	end
	return data
end

"""
Gets the position of a variable in datanames.
# Arguments
- `name::Symbol`: the variable name.
- `datanames::Union{Vector{String}, Vector{Symbol}}`: an array of stings and/or symbols.
"""
function get_data_column_pos(name::Symbol, datanames)
	return findfirst(x -> name == x, datanames)
end

"""
TODO: No tested or refactored
"""

"""
Returns the position of the header value based on this structure.
	- Index
	- Covariates
		* b
		* bstd
		* T-test
	- Equation general information merged with criteria user-defined options.
	- Order from user combined criteria
	- Weight
"""
function get_data_position(name, expvars, intercept, ttest, residualtest, time, criteria)
	data_cols_num = length(expvars)
	mult_col = (ttest == true) ? 3 : 1

	# INDEX
	if name == INDEX
		return 1
	end
	displacement = 1
	displacement += mult_col * (data_cols_num) + 1

	# EQUATION_GENERAL_INFORMATION
	testfields = (residualtest != nothing && residualtest) ? ((time != nothing) ? RESIDUAL_TESTS_TIME : RESIDUAL_TESTS_CROSS) : []
	equation_general_information_and_criteria = unique([EQUATION_GENERAL_INFORMATION; criteria; testfields])
	if name in equation_general_information_and_criteria
		return displacement + findfirst(isequal(name), equation_general_information_and_criteria) - 1
	end
	displacement += length(equation_general_information_and_criteria)

	if name == ORDER
		return displacement
	end
	displacement += 1

	if name == WEIGHT
		return displacement
	end
	displacement = 1

	# Covariates
	string_name = string(name)
	base_name = Symbol(replace(replace(replace(string_name, "_bstd" => ""), "_t" => ""), "_b" => ""))
	if base_name in expvars
		displacement = displacement + (findfirst(isequal(base_name), expvars) - 1) * mult_col
		if occursin("_bstd", string_name)
			return displacement + 2
		end
		if occursin("_b", string_name)
			return displacement + 1
		end
		if occursin("_t", string_name)
			return displacement + 3
		end
	end
end

"""
Constructs the header for results based in get_data_position orders.
"""
function get_result_header(expvars, intercept, ttest, residualtest, time, criteria, modelavg)
	header = Dict{Symbol, Int64}()
	header[:index] = get_data_position(:index, expvars, intercept, ttest, residualtest, time, criteria)
	for expvar in expvars
		header[Symbol(string(expvar, "_b"))] = get_data_position(Symbol(string(expvar, "_b")), expvars, intercept, ttest, residualtest, time, criteria)
		if ttest
			header[Symbol(string(expvar, "_bstd"))] = get_data_position(Symbol(string(expvar, "_bstd")), expvars, intercept, ttest, residualtest, time, criteria)
			header[Symbol(string(expvar, "_t"))] = get_data_position(Symbol(string(expvar, "_t")), expvars, intercept, ttest, residualtest, time, criteria)
		end
	end

	keys = unique([EQUATION_GENERAL_INFORMATION; criteria])

	if residualtest != nothing && residualtest
		keys = unique([keys; (time != nothing) ? RESIDUAL_TESTS_TIME : RESIDUAL_TESTS_CROSS])
	end

	for key in keys
		header[key] = get_data_position(key, expvars, intercept, ttest, residualtest, time, criteria)
	end

	header[:order] = get_data_position(:order, expvars, intercept, ttest, residualtest, time, criteria)
	if modelavg
		header[:weight] = get_data_position(:weight, expvars, intercept, ttest, residualtest, time, criteria)
	end
	return header
end

function in_vector(sub_vector, vector)
	for sv in sub_vector
		if !in(sv, vector)
			return false
		end
	end
	return true
end

"""
Returns selected appropiate covariates for each iteration
"""
function get_selected_cols(i)
	cols = zeros(Int64, 0)
	binary = string(i, base = 2)
	k = 2
	for i in 1:length(binary)
		if binary[length(binary)-i+1] == '1'
			append!(cols, k)
		end
		k = k + 1
	end
	return cols
end

function export_csv(io::IO, obm_io::IO, result::GSRegResult)
    head = []
    for elem in sort(collect(Dict(value => key for (key, value) in result.header)))
        push!(head, elem[2])
    end
    
    # Write the full results to the original file
    writedlm(io, [head], ',')
    writedlm(io, result.results, ',')
    
    # Write the header and the first row of data to the OBM file
    writedlm(obm_io, [head], ',')
    if size(result.results, 1) > 0
        writedlm(obm_io, result.results[1:1, :], ',')
    end
end

"""
Exports main results with headers to file and also creates a second file with _OBM suffix
"""
function export_csv(output::String, result::GSRegResult)
    file = open(output, "w")
    
    # Create the second CSV file name with _OBM suffix
    obm_output = replace(output, ".csv" => "_OBM.csv")
    obm_file = open(obm_output, "w")
    
    export_csv(file, obm_file, result)
    
    close(file)
    close(obm_file)
end