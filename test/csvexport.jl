module TestCSV
    using GSReg, CSV

    data = CSV.read("5x100.csv")

    @testset "CSV operations" begin
        @test
    end


end