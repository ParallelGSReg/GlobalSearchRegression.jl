using Test, CSV, DelimitedFiles, GlobalSearchRegression.Preprocessing

function replace_string_to_nothing(data)
    for n=1:size(data[1],1)
        for m=1:size(data[1], 2)
            if isa(data[1][n,m], String) || isa(data[1][n,m], SubString)
                data[1][n,m] = missing
            end
        end
    end
    return data
end

data_paneltime_without_missings_dataframe = CSV.read(DATABASE_PANELTIME_WITHOUT_MISSINGS_FILENAME)
data_paneltime_without_missings_tuple = readdlm(DATABASE_PANELTIME_WITHOUT_MISSINGS_FILENAME, ',', header=true)
data_time_without_missings_tuple = readdlm(DATABASE_TIME_WITHOUT_MISSINGS_FILENAME, ',', header=true)
data_paneltime_with_missings_tuple = readdlm(DATABASE_PANELTIME_WITH_MISSINGS_FILENAME, ',', header=true)
data_paneltime_as_missings = readdlm(DATABASE_PANELTIME_AS_MISSINGS_FILENAME, ',', header=true)

data_paneltime_without_missings_tuple = replace_string_to_nothing(data_paneltime_without_missings_tuple)
data_time_without_missings_tuple = replace_string_to_nothing(data_time_without_missings_tuple)
data_paneltime_with_missings_tuple = replace_string_to_nothing(data_paneltime_with_missings_tuple)
data_paneltime_as_missings = replace_string_to_nothing(data_paneltime_as_missings)

test_time_data = convert(Array{Float32}, readdlm(TEST_TIME_FILENAME, ','))
test_panel_data = convert(Array{Float32}, readdlm(TEST_PANEL_FILENAME, ','))
test_paneltime_data = convert(Array{Float32}, readdlm(TEST_PANELTIME_FILENAME, ','))
test_missing_data = convert(Array{Float32}, readdlm(TEST_MISSING_FILENAME, ','))


@testset "Equations" begin
    @testset "Stata like" begin
        data = Preprocessing.input("y x2 x1", data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x2, :x1]
    end
    
    @testset "R like" begin
        data = Preprocessing.input("y ~ x2 + x1", data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input("y ~ x.", data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9, :x10]
    end

    @testset "A String separated by comma with spaces" begin
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input("y, x*", data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9, :x10]
    end

    @testset "A String separated by comma without spaces" begin
        data = Preprocessing.input("y,x2,x1", data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input("y,x*", data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9, :x10]
    end

    @testset "Array of String" begin
        data = Preprocessing.input(["y", "x2", "x1"], data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input(["y" "x2" "x1"], data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input(["y" "x*"], data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x1, :x2, :x3, :x4, :x5, :x6, :x7, :x8, :x9, :x10]
    end

    @testset "Array of Symbol" begin
        data = Preprocessing.input([:y, :x2, :x1], data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input([:y :x2 :x1], data_paneltime_without_missings_tuple)
        @test data.equation == [:y, :x2, :x1]
    end

    @testset "Variables errors" begin
        data = nothing
        try
            data = Preprocessing.input("a b c", data_paneltime_without_missings_tuple[1])
        catch e
        end
        @test data == nothing

        data = nothing
        try
            data = Preprocessing.input("",  data_paneltime_without_missings_tuple[1])
        catch e
        end
        @test data == nothing

        data = nothing
        try
            data = Preprocessing.input([:a, :b, :c],  data_paneltime_without_missings_tuple)
        catch e
        end
        @test data == nothing
    end
end

@testset "Options" begin
    @testset "Intercept" begin
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple)
        @test data.intercept == true
        @test findfirst(isequal(:_cons), data.expvars) != nothing
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, intercept=true)
        @test data.intercept == true
        @test findfirst(isequal(:_cons), data.expvars) != nothing
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, intercept=false)
        @test data.intercept == false
        @test findfirst(isequal(:_cons), data.expvars) == nothing
    end

    @testset "Method" begin
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple)
        @test data.datatype == Float32
        @test isa(data.depvar_data, Array{Float32})
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, method="fast")
        @test data.datatype == Float32
        @test isa(data.depvar_data, Array{Float32})
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, method="FAST")
        @test data.datatype == Float32
        @test isa(data.depvar_data, Array{Float32})
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, method=:fast)
        @test data.datatype == Float32
        @test isa(data.depvar_data, Array{Float32})
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, method=:FAST)
        @test data.datatype == Float32
        @test isa(data.depvar_data, Array{Float32})
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, method="precise")
        @test data.datatype == Float64
        @test isa(data.depvar_data, Array{Float64})
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, method="PRECISE")
        @test data.datatype == Float64
        @test isa(data.depvar_data, Array{Float64})
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, method=:precise)
        @test data.datatype == Float64
        @test isa(data.depvar_data, Array{Float64})
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, method=:PRECISE)
        @test data.datatype == Float64
        @test isa(data.depvar_data, Array{Float64})

        data = nothing
        try
            data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, method="invalid")
        catch e
        end
        @test data == nothing
    end

    @testset "Time" begin
        data = Preprocessing.input("y, x2, x1", data_time_without_missings_tuple, time=:time)
        @test data.time == :time
        @test data.depvar_data == test_time_data[:,1]
        @test data.expvars_data == test_time_data[:,2:end]

        data = Preprocessing.input("y, x2, x1", data_time_without_missings_tuple, time="time")
        @test data.time == :time
        @test data.depvar_data == test_time_data[:,1]
        @test data.expvars_data == test_time_data[:,2:end]

        data = nothing
        try
            data = Preprocessing.input("y, x2, x1", data_time_without_missings_tuple, time="invalid")
        catch e
        end
        @test data == nothing

        data = nothing
        try
            data = Preprocessing.input("y, x2, x1", data_paneltime_as_missings, time=:time)
        catch e
        end
        @test data == nothing
    end

    @testset "Panel" begin
        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, panel=:panel)
        @test data.panel == :panel
        @test data.depvar_data == test_panel_data[:,1]
        @test data.expvars_data == test_panel_data[:,2:end]

        data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, panel="panel")
        @test data.panel == :panel
        @test data.depvar_data == test_panel_data[:,1]
        @test data.expvars_data == test_panel_data[:,2:end]
        println(data)
        data = nothing
        try
            data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, panel="invalid")
        catch e
        end
        @test data == nothing

        data = nothing
        try
            data = Preprocessing.input("y, x2, x1", data_paneltime_as_missings, panel=:panel)
        catch e
        end
        @test data == nothing
    end

    @testset "Panel Time" begin
        #data = Preprocessing.input("y, x2, x1", data_paneltime_without_missings_tuple, time=:time, panel=:panel)
        #@test data.time == :time
        #@test data.panel == :panel
        #@test data.depvar_data == test_paneltime_data[:,1]
        #@test data.expvars_data == test_paneltime_data[:,2:end]

        data = nothing
        try
            #data = Preprocessing.input("y, x2, x1", data_paneltime_with_missings_tuple, time="invalid", panel="invalid")
        catch e
        end
        @test data == nothing

        data = nothing
        try
            #data = Preprocessing.input("y, x2, x1", data_paneltime_as_missings, time=:time, panel=:panel)
        catch e
        end
        @test data == nothing

    end
end
