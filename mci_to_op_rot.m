function rotMat = mci_to_op_rot(t_tdb)

    rot_pa_to_mci = cspice_pxform('MOON_PA','J2000',t_tdb);

    rv_earth = cspice_spkezr('EARTH',t_tdb,'J2000','NONE','MOON');

    r_earth = rv_earth(1:3);
    v_earth = rv_earth(4:6);

    z_pole_pa = [0; 0; 1];
    z_pole_mci = rot_pa_to_mci*z_pole_pa;

    z_hat = cross(r_earth,v_earth)/norm(cross(r_earth,v_earth));

    x_hat = cross(z_pole_mci,z_hat)/norm(cross(z_hat,z_pole_mci));

    y_hat = cross(z_hat,x_hat)/(norm(cross(z_hat,x_hat)));

    rotMat = [x_hat'; y_hat'; z_hat';];

end