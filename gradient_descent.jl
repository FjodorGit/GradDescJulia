using Symbolics;
using ArgParse;
using Plots;



@variables x

function parse_input_function()
    settings = ArgParseSettings()
    @add_arg_table settings begin
        "function"
        help = "the function to apply gradient descent to"
        required = true
        arg_type = String
        "--steps"
        help = "how many iterations of the gradient descent to take"
        arg_type = Int
        default = 10
        "--step-size"
        help = "how many iterations of the gradient descent to take"
        arg_type = Float32
        default = 0.1
    end

    parsed_args = parse_args(settings)
    parsed_args["func_string"] = parsed_args["function"]
    parsed_args["function"] = eval(Meta.parse(parsed_args["function"]))
    parsed_args["julia_function"] = build_function(parsed_args["function"], x, expression=Val{false})
    return parsed_args
end

function gradient_descent(args)
    func = args["function"]
    f = args["julia_function"]
    Dx = Symbolics.Differential(x)
    dx_expr = expand_derivatives(Dx(func))
    derivative = build_function(dx_expr, x, expression=Val{false})


    println(dx_expr)
    start_x = 9.0f0
    walk_x, walk_y = Float32[], Float32[]
    for i in 1:args["steps"]
        push!(walk_x, start_x)
        push!(walk_y, f(start_x))
        next_x = start_x - args["step-size"] * derivative(start_x)
        start_x = Float32(next_x)
    end
    return walk_x, walk_y
end

function plot_descent(args, walk)
    f = args["julia_function"]
    X = range(-10, 10, length=200)
    y = f.(X)
    plot(X, y, label=args["func_string"])
    plot!(walk[1], walk[2], seriestype=:scatter, label="walk")
    savefig("test_img.svg")
end


function main()
    gradient_descent_args = parse_input_function()
    walk = gradient_descent(gradient_descent_args)
    plot_descent(gradient_descent_args, walk)
end

main()


