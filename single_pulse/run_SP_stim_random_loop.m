
function run_SP_stim_random_loop(num_cycles)

a = [1 2 3];

for x = 1:num_cycles

    curr_order = a(randperm(numel(a)));

for xx = 1: numel(curr_order)

    if curr_order(xx)==1

        run_1hz_SP;

        

    elseif curr_order(xx)==2

        run_10hz_SP;

    elseif curr_order(xx)==3

        run_100hz_SP;

    end

end

end