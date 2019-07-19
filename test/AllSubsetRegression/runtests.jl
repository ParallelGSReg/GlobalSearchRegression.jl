using Test, CSV, DelimitedFiles, GlobalSearchRegression

data_small = CSV.read(DATABASE_SMALL)

@testset "AllSubsetRegression" begin
    @testset "With T-test" begin
        res = gsr("y x*", data_small, ttest=true)

        @show res.results[1]

        @test 1 == 1
    end
end
