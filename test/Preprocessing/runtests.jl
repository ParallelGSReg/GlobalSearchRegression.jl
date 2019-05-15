using Test, CSV, DelimitedFiles, GlobalSearchRegression.Preprocessing

"""
Disclaimer:
    - This unit test does NOT test wildcards.
    - This unit test does NOT test certain validations
"""

WITHOUT_MISSING_FILENAME = "data/without_missing_database.csv"
WITH_MISSING_FILENAME = "data/with_missing_database.csv"
TEST_TIME_FILENAME = "data/test_time_database.csv"
TEST_PANEL_FILENAME = "data/test_panel_database.csv"
TEST_TIME_PANEL_FILENAME = "data/test_time_panel_database.csv"
TEST_MISSING_FILENAME = "data/test_missing_database.csv"

without_missing_tuple_data = readdlm(WITHOUT_MISSING_FILENAME, ',', header=true)
without_missing_dataframe_data = CSV.read(WITHOUT_MISSING_FILENAME)

with_missing_tuple_data = readdlm(WITH_MISSING_FILENAME, ',', header=true)
with_missing_dataframe_data = CSV.read(WITH_MISSING_FILENAME)

test_time_data = convert(Array{Float32}, readdlm(TEST_TIME_FILENAME, ','))
test_panel_data = convert(Array{Float32}, readdlm(TEST_PANEL_FILENAME, ','))
test_time_panel_data = convert(Array{Float32}, readdlm(TEST_TIME_PANEL_FILENAME, ','))
test_missing_data = convert(Array{Float32}, readdlm(TEST_MISSING_FILENAME, ','))

@testset "Equations" begin
    @testset "Stata like" begin
        data = Preprocessing.input("y x2 x1", data=without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input("y x2 x1", without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
    end
    
    @testset "R like" begin
        data = Preprocessing.input("y ~ x2 + x1", data=without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input("y ~ x2 + x1", without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
    end

    @testset "A String separated by comma with spaces" begin
        data = Preprocessing.input("y, x2, x1", data=without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input("y, x2, x1", without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
    end

    @testset "A String separated by comma without spaces" begin
        data = Preprocessing.input("y,x2,x1", data=without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input("y,x2,x1", without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
    end

    @testset "Array of String" begin
        data = Preprocessing.input(["y", "x2", "x1"], data=without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input(["y", "x2", "x1"], without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input(["y" "x2" "x1"], data=without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input(["y" "x2" "x1"], without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
    end

    @testset "Array of Symbol" begin
        data = Preprocessing.input([:y, :x2, :x1], data=without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input([:y, :x2, :x1], without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input([:y :x2 :x1], data=without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
        data = Preprocessing.input([:y :x2 :x1], without_missing_dataframe_data)
        @test data.equation == [:y, :x2, :x1]
    end
end

@testset "Options" begin
    @testset "Intercept" begin
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data)
        @test data.intercept == true
        @test findfirst(isequal(:_cons), data.expvars) != nothing
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, intercept=true)
        @test data.intercept == true
        @test findfirst(isequal(:_cons), data.expvars) != nothing
        data = Preprocessing.input("y, x2, x1", without_missing_tuple_data, intercept=false)
        @test data.intercept == false
        @test findfirst(isequal(:_cons), data.expvars) == nothing
    end

    @testset "Method" begin
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data)
        @test data.datatype == Float32
        @test isa(data.depvar_data, Array{Float32})
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, method="fast")
        @test data.datatype == Float32
        @test isa(data.depvar_data, Array{Float32})
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, method="FAST")
        @test data.datatype == Float32
        @test isa(data.depvar_data, Array{Float32})
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, method=:fast)
        @test data.datatype == Float32
        @test isa(data.depvar_data, Array{Float32})
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, method=:FAST)
        @test data.datatype == Float32
        @test isa(data.depvar_data, Array{Float32})
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, method="precise")
        @test data.datatype == Float64
        @test isa(data.depvar_data, Array{Float64})
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, method="PRECISE")
        @test data.datatype == Float64
        @test isa(data.depvar_data, Array{Float64})
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, method=:precise)
        @test data.datatype == Float64
        @test isa(data.depvar_data, Array{Float64})
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, method=:PRECISE)
        @test data.datatype == Float64
        @test isa(data.depvar_data, Array{Float64})
    end

    @testset "Time" begin
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, time=:time)
        @test data.time == :time
        @test data.depvar_data == test_time_data[:,1]
        @test data.expvars_data == test_time_data[:,2:end]

        data = Preprocessing.input("y, x2, x1", without_missing_tuple_data, time="time")
        @test data.time == :time
        @test data.depvar_data == test_time_data[:,1]
        @test data.expvars_data == test_time_data[:,2:end]    
    end

    @testset "Panel" begin
        data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, panel=:panel)
        @test data.panel == :panel
        @test data.depvar_data == test_panel_data[:,1]
        @test data.expvars_data == test_panel_data[:,2:end]  
        data = Preprocessing.input("y, x2, x1", without_missing_tuple_data, panel="panel")
        @test data.panel == :panel
        @test data.depvar_data == test_panel_data[:,1]
        @test data.expvars_data == test_panel_data[:,2:end]    
    end    
end

@testset "Data" begin
    """
    @testset "With missings" begin
        @testset "DataFrame" begin
            data = Preprocessing.input("y x2 x1", data=with_missing_dataframe_data, time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 15

            data = Preprocessing.input("y x2 x1", with_missing_dataframe_data, time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 15
        end

        @testset "Array" begin
            data = Preprocessing.input("y x2 x1", data=with_missing_tuple_data[1], datanames=with_missing_tuple_data[2], time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 15
            
            data = Preprocessing.input("y x2 x1", with_missing_tuple_data[1], datanames=with_missing_tuple_data[2], time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data [:,2:end]
            @test data.nobs == 15
        end

        @testset "Tuple" begin
            data = Preprocessing.input("y, x2, x1", data=with_missing_tuple_data, time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 15
            
            data = Preprocessing.input("y, x2, x1", with_missing_tuple_data, time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 15
        end
    end
    """
    
    @testset "Without missings" begin
        @testset "DataFrame" begin
            data = Preprocessing.input("y x2 x1", data=without_missing_dataframe_data, time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 20

            data = Preprocessing.input("y x2 x1", without_missing_dataframe_data, time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 20
        end

        @testset "Array" begin
            data = Preprocessing.input("y x2 x1", data=without_missing_tuple_data[1], datanames=without_missing_tuple_data[2], time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 20
            
            data = Preprocessing.input("y x2 x1", without_missing_tuple_data[1], datanames=without_missing_tuple_data[2], time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 20
        end

        @testset "Tuple" begin
            data = Preprocessing.input("y, x2, x1", data=without_missing_tuple_data, time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 20
            
            data = Preprocessing.input("y, x2, x1", without_missing_tuple_data, time=:time, panel=:panel)
            @test data.depvar == :y
            @test data.expvars == [:x2, :x1, :_cons]
            @test data.depvar_data == test_missing_data[:,1]
            @test data.expvars_data == test_missing_data[:,2:end]
            @test data.nobs == 20
        end
    end
end