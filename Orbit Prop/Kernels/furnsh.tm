         KPL/MK

         File name: furnsh.tm

         Here are the SPICE kernels required for my application
         program.

         Note that kernels are loaded in the order listed. Thus
         we need to list the highest priority kernel last.


		\begindata

		KERNELS_TO_LOAD = (
			'Kernels/naif0012.tls',
			'Kernels/gm_de440.tpc',
			'Kernels/moon_de440_250416.tf',
			'Kernels/de440s.bsp',
			'Kernels/moon_pa_de440_200625.bpc',
			'Kernels/pck00011.tpc',
			'Kernels/earth_1962_250826_2125_combined.bpc'
		)

		\begintext

         End of meta-kernel