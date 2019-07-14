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
        datalassogen = PreliminarySelection.lasso(dataorig)
        previousresult = AllSubsetRegression.ols(datalassogen, ttest=true)

        @show bestmodel = Dict(
            :data => previousresult.bestresult_data,
            :datanames => previousresult.datanames
        )

        info = CrossValidation.kfoldcrossvalidation(dataorig, previousresult, 3)

        #exportar a latex, con info y best model.

        @test 1 == 1
    end
end
