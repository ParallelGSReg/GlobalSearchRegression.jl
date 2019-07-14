using Test, CSV, DelimitedFiles, 
GlobalSearchRegression.CrossValidation,
GlobalSearchRegression.AllSubsetRegression,
GlobalSearchRegression.PreliminarySelection,
GlobalSearchRegression.Preprocessing

data_fat = CSV.read(DATABASE_FAT)

@testset "Kfold cross validation" begin
    @testset "Fat dataset" begin

        #funcgen("y *", data; ttest=true, cross=(k=3))

        dataorig = Preprocessing.input("y *", data_fat)

        datalassogen, vars = PreliminarySelection.lasso(dataorig)

        AllSubsetRegression.ols!(datalassogen, ttest=true)

        @show bestmodel = Dict(
            :data => datalassogen.results[1].bestresult_data,
            :datanames => datalassogen.results[1].datanames
        )

        info = CrossValidation.kfoldcrossvalidation(dataorig, datalassogen, 3, 0.03)

        #exportar a latex, con info y best model.

        @test 1 == 1
    end
end
