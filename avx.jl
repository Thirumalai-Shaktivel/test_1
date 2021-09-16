using LoopVectorization

function f_avx(N)
    s = 0.0
    @avxt for i in 1:N
        s += sin(i)
    end
    s
end

@time r = f_avx(100000000)
println(r)
