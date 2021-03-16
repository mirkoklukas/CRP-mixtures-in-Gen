"""

    c::Array{Int} = crp_model(T::Int, α::Float64)

Computes seating assignments `c` for `T` customers, 
following a chinese restaurant process with concentration 
parameter `α`.

The entry `c[t]` encodes the table assigned to customer `t`.
Table identifiers reflect the order of their allocation, i.e. 
the first table is labeled `1`, the second is labeled `2`, and so on. 
That means you cannot sit down at table *two* before 
someone sat down at table *one* first.

"""
@gen function crp_model(T::Int, α::Float64)
    c = Int[] # cluster assignments
    n = Int[] # cluster sizes
    k = 0     # number of clusters
    
    for t=1:T
        pr  = [n; α]./(t - 1 + α)
        c_t = @trace(categorical(pr), (:c, t))
        push!(c,c_t)
        
        if c_t <= k # assign to old cluster
            n[c_t] += 1
        else        # start new cluster
            k += 1
            push!(n, 1)
        end
    end;
    c
end;


"""
    (c, phi, x) = crp_mixture_model(T::Int, 
                                    α::Float64, 
                                    F::Union{Distribution,DynamicDSLFunction}, 
                                    G0::Union{Distribution,DynamicDSLFunction})

Defines a non-parametric mixture model.
Cluster assignments are chosen according to a CRP 
with concentration parameter `α`, cluster parameters
are chosen from a base distribution `G0`, and the data
are generated from a family of distributions `F`.

"""
@gen function crp_mixture_model(
        T::Int, 
        α::Float64, 
        F::Union{Distribution,DynamicDSLFunction}, 
        G0::Union{Distribution,DynamicDSLFunction})
    
    # Cluster assignments     
    c = @trace(crp_model(T, α), :c)

    # Cluster parameters
    phi = Dict()    
    for i in Set(c)
        phi_i  = @trace(G0(), :phi => (:phi, i))
        phi[i] = phi_i
    end
    
    # Data points for each cluster
    x = []
    for t=1:T
        x_t = @trace(F(phi[c[t]]), :x => (:x, t))
        push!(x, x_t)
    end
    
    return (c, phi, x)
end;


"""
    tr = relabel_tables(tr::Gen.Trace)

Relabels the tables according their allocation, i.e. 
it changes `c` and the `phi` as if the were 
constructed by the crp model without changing 
the cluster memberships. 
"""
function relabel_tables(tr::Gen.Trace)
    
    updates = choicemap() 
    labels  = Dict() # stores pairs `old_label => new_label`
    ch = get_choices(tr)
    T, = get_args(tr)
    k  = 1

    for t=1:T
        i = tr[:c => (:c, t)]
        
        if !haskey(labels, i)
            labels[i] = k
            set_submap!(updates, (:phi, k), get_submap(ch, (:phi,i)))
            k += 1                
        end
        
        updates[:c => (:c, t)] = labels[i]
    end

    tr,w, = Gen.update(tr, updates)
    return tr
end;


"""
    G0()

Basedistribution over cluster parameters.
"""
@gen function G0()
    mean = @trace(normal(0.,2.), :mean)
    std  = @trace(inv_gamma(100., 99.),  :std) # Recall: E(inv_gamma) = b/(a-1)
    return [mean; std]
end;


"""
    F(phi)

Family of data distributions conditioned 
on cluster parameters. 
"""
@gen function F(phi)::Float64
    mean, std = phi
    x = @trace(normal(mean, std), :x)
    return x
end;


"""
    set_obs!(upd, x)

Adds data constraints given by `x` to choicemap `upd`.
Depends on the trace structure of the data models. 
"""
function set_obs!(upd, x)
    for t=1:length(x)
       upd[:x => (:x, t) => :x] = x[t]
    end
end


"""
    get_obs(x)

Creates a choicemap with data constraints given by `x`.
Depends on the trace structure of the data models. 
"""
function get_obs(x)
    upd = choicemap()
    set_obs!(upd, x)
    return upd
end