using Plots
using LinearAlgebra

#Параметры генерации точек
ε = 0.05
x_step = 0.04
y_step = 0.04
x_range = -2.6:x_step:2.6
y_range = -2.6:y_step:2.6


#Плотная сетка точек по всей области
all_points = ComplexF64[]
for y in y_range
    for x in x_range
        z = x + y*im
        if !(abs(real(z)) < ε && 0 < imag(z) < 1)
            push!(all_points, z)
        end
    end
end

#Дополнительные точки для лучшей визуализации границ
horizontal_points = ComplexF64[]
for y in -2.6:0.12:2.6
    for x in x_range
        z = x + y*im
        if !(abs(real(z)) < ε && 0 < imag(z) < 1)
            push!(horizontal_points, z)
        end
    end
end

vertical_points = ComplexF64[]
for x in -2.6:0.12:2.6
    for y in y_range
        z = x + y*im
        if !(abs(real(z)) < ε && 0 < imag(z) < 1)
            push!(vertical_points, z)
        end
    end
end


#Поворот на -90 градусов
z1 = -im .* all_points


#Отображение в верхнюю полуплоскость
arg = z1 ./ (1 .- z1)
z2 = sqrt.(arg)

#Фильтрация точек для чистой верхней полуплоскости
z2_upper = filter(z -> imag(z) > 1e-5, z2)


#Отображение в верхний полукруг
z3 = (z2 .- im) ./ (z2 .+ im)

#Фильтрация для области D2
d2_points = filter(w -> abs(w) < 0.99 && imag(w) > 1e-5, z3)


#Генерируем очень плотную сетку внутри единичного полукруга
d2_dense = ComplexF64[]
for r in 0.02:0.03:0.98
    for θ in 0:0.05:π
        w = r * exp(im * θ)
        if imag(w) > 1e-5 && abs(w) < 0.99
            push!(d2_dense, w)
        end
    end
end
d2_points = vcat(d2_points, d2_dense)

#Визуализация всех этапов преобразования


p1 = plot(title="Этап 0: D₁ = ℂ \\ [0, i], Исходная область", aspect_ratio=:equal,
          xlims=(-2.5, 2.5), ylims=(-2.5, 2.5), legend=false,
          xlabel="Re(z)", ylabel="Im(z)", grid=true, gridwidth=1)

scatter!(real.(all_points), imag.(all_points), 
         color=:steelblue, markersize=1.2, alpha=0.5)
plot!([0, 0], [0, 1], linestyle=:solid, linewidth=3, color=:black, label="Вырез [0, i]")
scatter!([0], [0], color=:black, markersize=6, marker=:circle)
scatter!([0], [1], color=:black, markersize=6, marker=:circle)
annotate!(0.15, 0, text("0", :black, :left, 10))
annotate!(0.15, 1, text("i", :black, :left, 10))

#После поворота на -90 градусов
p2 = plot(title="Этап 1: z₁ = -i·z, ℂ \\ [0, 1]", aspect_ratio=:equal,
          xlims=(-2.5, 2.5), ylims=(-2.5, 2.5), legend=false,
          xlabel="Re(z₁)", ylabel="Im(z₁)", grid=true, gridwidth=1)
#Плотная сетка точек - увеличенный размер для полного покрытия
scatter!(real.(z1), imag.(z1), color=:purple, markersize=1.2, alpha=0.5)
plot!([0, 1], [0, 0], linestyle=:solid, linewidth=3, color=:black, label="Вырез [0, 1]")
scatter!([0, 1], [0, 0], color=:black, markersize=6, marker=:circle)
annotate!(0.1, 0.15, text("0", :black, :left, 10))
annotate!(1.1, 0.15, text("1", :black, :left, 10))

#Верхняя полуплоскость
p3 = plot(title="Этап 2: z₂ = √(z₁/(1-z₁))\nВерхняя полуплоскость {z: Im(z) > 0}", 
          aspect_ratio=:equal, xlims=(-3, 3), ylims=(-0.5, 3), legend=false,
          xlabel="Re(z₂)", ylabel="Im(z₂)", grid=true, gridwidth=1)
#Плотная сетка точек в верхней полуплоскости - увеличенный размер для полного покрытия
scatter!(real.(z2_upper), imag.(z2_upper), color=:forestgreen, markersize=1.2, alpha=0.5)
plot!([-3, 3], [0, 0], linestyle=:solid, linewidth=2, color=:black, label="Граница Im(z) = 0")

#Верхний полукруг
p4 = plot(title="Этап 3: w = (z₂-i)/(z₂+i)\nD₂: Верхний полукруг {w: |w| < 1, Im(w) > 0}",
          aspect_ratio=:equal, xlims=(-1.2, 1.2), ylims=(-0.2, 1.2), legend=false,
          xlabel="Re(w)", ylabel="Im(w)", grid=true, gridwidth=1)
#Плотная сетка точек для закрашивания области внутри полукруга - увеличенный размер
scatter!(real.(d2_points), imag.(d2_points), color=:gold, markersize=1.2, alpha=0.6)
#Граница полукруга
θ = range(0, π, length=200)
plot!(cos.(θ), sin.(θ), linewidth=3, color=:black, label="")
plot!([-1, 1], [0, 0], linestyle=:solid, linewidth=2, color=:black, label="")
scatter!([-1, 0, 1], [0, 0, 0], color=:black, markersize=6, marker=:circle)
scatter!([0], [1], color=:black, markersize=6, marker=:circle)
annotate!(-1.1, 0, text("-1", :black, :right, 10))
annotate!(0.1, 0, text("0", :black, :left, 10))
annotate!(1.1, 0, text("1", :black, :left, 10))
annotate!(0.1, 1, text("i", :black, :left, 10))

#Объединение всех графиков
final_plot = plot(p1, p2, p3, p4, layout=(2, 2), size=(1200, 1200))
savefig(final_plot, "conformal_mapping_steps.png")
display(final_plot)
