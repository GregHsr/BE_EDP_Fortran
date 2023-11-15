Module m_type

type donnees

 integer :: nx         ! nb of cells in x-direction
 integer :: ny         ! nb of cells in y-direction
 real :: Lx            ! x-length of the domain
 real :: Ly            ! y-length of the domain
 real :: U0            ! characteristic velocity
 real :: D             ! thermal/mass diffusivity
 real :: Ti            ! Initial temperature in the domain
 real :: Tg            ! Temperature at the left
 real :: Td            ! Temperature at the right
 real :: Tt            ! Temperature at the top
 real :: Tb            ! Temperature at the bottom
 real :: tf            ! final time
 integer :: Nout       ! number of intermediate unsaved time steps 
 real :: CFL           ! Courant's number (advection)
 real :: R             ! Fourier's number (diffusion)
 integer :: Type_mesh  ! Type of mesh (0: uniform, 1: non-uniform) 
 integer :: Type_vel   ! Type of velocity (0: uniform, 1: non-uniform)
 integer :: method     ! Method of resolution (0: Gauss, 1: SOR)
 real :: R0            ! Stop criterion for the SOR method
 real :: W             ! Relaxation parameter for the SOR method

end type donnees


end module m_type
