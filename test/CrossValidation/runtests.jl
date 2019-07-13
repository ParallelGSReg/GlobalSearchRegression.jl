using Test, CSV, DelimitedFiles, GlobalSearchRegression.CrossValidation, GlobalSearchRegression.Preprocessing

data_fat = CSV.read(DATABASE_FAT)

@testset "Kfold cross validation" begin
    @testset "Fat dataset" begin
        data = Preprocessing.input("y *", data_fat)
        data = CrossValidation.kfoldcrossvalidation(data, 3)
        @test 1 == 1
    end
end
