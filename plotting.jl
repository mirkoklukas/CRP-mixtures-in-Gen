import PyPlot
plt = PyPlot;


function render_crp_trace(tr)
    
    function cluster_sizes(c::Array{Int})
	    labels = Dict()
	    k = 1
	    n = Int[]
	    for i in c
	        if !haskey(labels, i)
	            labels[i] = k
	            push!(n, 1)
	            k += 1            
	        else
	            n[labels[i]] += 1
	        end
	    end
	    n
	end

    T, α = get_args(tr)
    c = get_retval(tr)
    n = cluster_sizes(c)
    

    fig, axs = plt.subplots(1,3, figsize=(10,1), sharey=true);
    
    axs[1].scatter(1:T, c, s=1, marker=".", color="C0");
    axs[1].plot(1:T, α*log.(1:T), color="C1", linewidth=1., linestyle=":");
    axs[1].set_xlabel("time (\$t\$)"); axs[1].set_ylabel("cluster (\$c_t\$)");

    axs[2].scatter(1:T, c, s=1, marker=".", color="C0");
    axs[2].plot(1:T, α*log.(1:T), color="C1", linewidth=1., linestyle=":");
    axs[2].set_xlabel("time (\$t\$)"); axs[1].set_ylabel("cluster (\$c_t\$)");
    axs[2].set_xscale("log")
    
    axs[3].barh(1:maximum(c), n[1:maximum(c)], color="green");
    axs[3].set_xlabel("cluster size (\$n_t\$)"); 

end


function render_crp_mixture_tr(tr; bins=50)

    fig, axs = plt.subplots(1,3, figsize=(10,0.5), sharex="col", gridspec_kw=Dict("width_ratios" => [3,3, 1]));

    c, phi, x = get_retval(tr)
    phi_vals  = collect(values(phi))
    k         = length(phi)
    n = zeros(k)

    for i in c
        n[i] += 1
    end

    perm = sortperm(n, rev=true)
    
    axs[1].hist(x, bins=200)
    for j=1:k
        i = perm[j]
        axs[2].scatter(x[c .== i], ones(sum(c .== i)).*i, alpha=1.,s=5, marker="o", zorder=1);
    end
    axs[3].hist(c, edgecolor="w");

end


