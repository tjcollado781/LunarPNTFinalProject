function coeTableNew = coeOPtocoeMCI(coeTable,t0_ET,mu)

coeTableNew = zeros(height(coeTable), 6);

%Convert the coe from OP to MCI
rot_mci_to_op = mci_to_op_rot(t0_ET);

for idx = 1:height(coeTable)
    %Convert COE to Cartesian
    [r_op, v_op] = cartEl(coeTable(idx,1),coeTable(idx,2),deg2rad(coeTable(idx,3)),deg2rad(coeTable(idx,4)),deg2rad(coeTable(idx,5)),deg2rad(coeTable(idx,6)), mu);

    %Rotate to MCI
    r_mci = rot_mci_to_op' * r_op;
    v_mci = rot_mci_to_op' * v_op;

    state_mci = [r_mci;v_mci];

    %Convert MCI Cartesian back to MCI Osculating COE (Requires rv2coe)
    [a_new, e_new, i_new, LAAN_new, w_new, nu_new] = orbitEl(state_mci, mu);
    coeTableNew(idx,:) = [a_new, e_new, rad2deg(i_new), rad2deg(LAAN_new), rad2deg(w_new), rad2deg(nu_new)];

end

end