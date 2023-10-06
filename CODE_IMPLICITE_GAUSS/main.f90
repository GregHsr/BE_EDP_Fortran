program main

 use m_type

 implicit none

 type (donnees) :: param                                             ! Fortran strucutre containing the initial numerical and physical parameters
 real,dimension(:,:),allocatable :: x,y                              ! Coordinates of the bottom-left corner of the temperature cell (in meter)
 real,dimension(:,:),allocatable :: xv,yv                            ! Coordinates of the temperature cell center (in meter)    
 real,dimension(:,:),allocatable :: vol                              ! Volume of the temperature cell center (in meter^2 since the code is 2D)
 real,dimension(:,:),allocatable :: T0,T1                            ! Arrays for the temerature at times n and n+1 
 real,dimension(:,:),allocatable :: U                                ! Horizontal component of velocity defined at the center of the 'west' surface at location (x,yv)
 real,dimension(:,:),allocatable :: V                                ! Vertical component of velocity defined at the center of the 'south' surface at location (xv,y)
 real,dimension(:,:),allocatable :: Fadv                             ! Sum of the advective fluxes
 real,dimension(:,:),allocatable :: A_base
 real,dimension(:),allocatable :: B_base
 real,dimension(:,:),allocatable :: T_fut
 real :: dt                                                          ! Time step (in second)
 integer :: l                                                        ! Increment for the temporal loop
 integer :: N                                                        ! Total number of time steps                                                    
 integer :: i,j
 print*,'simulation started'

 call read_data(param)

 allocate(x(param%nx+1,param%ny+1),y(param%nx+1,param%ny+1))
 allocate(xv(param%nx,param%ny),yv(param%nx,param%ny),vol(param%nx,param%ny))
 allocate(T0(param%nx,param%ny),T1(param%nx,param%ny))
 allocate(U(param%nx+1,param%ny),V(param%nx,param%ny+1))
 allocate(Fadv(param%nx,param%ny))
 allocate(A_base(param%nx*param%ny,param%nx*param%ny))
 allocate(B_base(param%nx*param%ny))

 call mesh(param,x,y,xv,yv,vol)
 call ir_mesh(param,x,y,xv,yv,vol)

 call initial_temperature(param,xv,yv,x,y,T0)

 call initial_velocity(param,x,y,U,V)
 call ir_velocity(param,x,y,U,V)
 
 call VTSWriter(0.0,0,param%nx,param%ny,x,y,T0,U,V,'ini')

 call calc_dt(param,x,y,U,V,dt)
 call creation_A(param,dt,vol,A_base,x,y,xv,yv)
 print*, "A=", A_base
 N=int(param%tf/dt)
 print*,"N=",N

   print*,"Simulation with the explicit solver..."
   print*,'time advancing...'

   do l=1,N
      call calc_flux_adv(param,x,y,xv,yv,U,V,T0,Fadv)
      call creation_B(param,B_base,Fadv,dt,xv,yv,vol,x,y)
      print*, "B=", B_base
      
      call GAUSSIJ(param%Nx*param%Ny,A_base,B_base)
      call miseajour_T(param,B_base,T0)

      if(mod(l,param%Nout)==0) then
        call VTSWriter(float(l)*dt,l,param%nx,param%ny,x,y,T0,U,V,'int')
      end if

   end do
   
  call VTSWriter(float(N)*dt,N,param%nx,param%ny,x,y,T0,U,V,'end')

 deallocate(x,y)
 deallocate(xv,yv,vol)
 deallocate(T0,T1)
 deallocate(U,V)
 deallocate(Fadv)
 deallocate(A_base)
 deallocate(B_base)

 print*,'simulation done'

end program main


