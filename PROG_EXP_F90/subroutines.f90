!**************************
subroutine read_data(param)
!**************************

 use m_type

 implicit none 

 type (donnees), intent(out) :: param
 
 print*,'reading data...'

 open(unit=11,file="../CODE_IMPLICITE_GAUSS/data.txt")
 
 read (11,*) param%nx            ! nb of cells in x-direction
 read (11,*) param%ny            ! nb of cells in y-direction
 read (11,*) param%Lx            ! length of the domain
 read (11,*) param%Ly            ! height of the domain
 read (11,*) param%U0            ! characteristic velocity
 read (11,*) param%D             ! thermal/mass diffusivity
 read (11,*) param%Ti            ! Initial temperature in the domain
 read (11,*) param%Tg            ! Temperature at the left
 read (11,*) param%Tb            ! Temperature at the bottom
 read (11,*) param%tf            ! final time
 read (11,*) param%Nout          ! number of intermediate unsaved time steps 
 read (11,*) param%CFL           ! Courant's number (advection)
 read (11,*) param%R             ! Fourier's number (diffusion)
 read (11,*) param%Type_mesh     ! Type of mesh (0: regular, 1: irregular)
 read (11,*) param%Type_vel      ! Type of velocity (0: uniform, 1: non uniform)

 close (11)

end subroutine read_data
!***********************


!***********************************
subroutine mesh(param,x,y,xv,yv,vol)
!***********************************

 use m_type

 implicit none

 type (donnees), intent(in) :: param
 real, dimension(param%nx+1,param%ny+1), intent(out) :: x,y
 real, dimension(param%nx,param%ny), intent(out) :: xv,yv
 real, dimension(param%nx,param%ny), intent(out) :: vol

 integer ::i,j
 real :: pi

 print*,'creating mesh...'

 do i=1,param%nx+1
   do j=1,param%ny+1
      x(i,j)=param%Lx*real(i-1)/real(param%nx)
      y(i,j)=param%Ly*real(j-1)/real(param%ny)
   end do
 end do

 do i=1,param%nx
   do j=1,param%ny
      xv(i,j)=0.5*(x(i,j)+x(i+1,j))
      yv(i,j)=0.5*(y(i,j)+y(i,j+1))
      vol(i,j)=(x(i+1,j)-x(i,j))*(y(i,j+1)-y(i,j))
   end do
 end do

end subroutine mesh
!****************** 

!***********************************
subroutine ir_mesh(param,x,y,xv,yv,vol)
!***********************************

  use m_type

  implicit none

  type (donnees), intent(in) :: param
  real, dimension(param%nx+1,param%ny+1), intent(inout) :: x,y
  real, dimension(param%nx,param%ny), intent(inout) :: xv,yv
  real, dimension(param%nx,param%ny), intent(inout) :: vol

  real, dimension(param%nx+1,param%ny+1) :: x_irreg,y_irreg
  integer ::i,j
  real :: pi
 
  if (param%Type_mesh==1) then 

    print*,'creating irregular mesh...'
    
    pi = acos(-1.)
  
    do i=1,param%nx+1
      do j=1,param%ny+1
        x_irreg(i,j)=x(i,j)*x(i,j)/param%Lx
        y_irreg(i,j)=param%Ly*(1-cos(pi*y(i,j)/(2*param%Ly)))
      end do
    end do

    do i=1,param%nx+1
      do j=1,param%ny+1
        x(i,j) = x_irreg(i,j)
        y(i,j) = y_irreg(i,j)
      end do
    end do

    do i=1,param%nx
      do j=1,param%ny
         xv(i,j)=0.5*(x(i,j)+x(i+1,j))
         yv(i,j)=0.5*(y(i,j)+y(i,j+1))
         vol(i,j)=(x(i+1,j)-x(i,j))*(y(i,j+1)-y(i,j))
      end do
    end do
  
  end if
end subroutine ir_mesh
!****************** 


!*************************************************
subroutine initial_temperature(param,xv,yv,x,y,T0)
!*************************************************           

 use m_type

 implicit none

 type (donnees), intent(in) ::param
 real, dimension(param%nx,param%ny), intent(in) :: xv
 real, dimension(param%nx,param%ny), intent(in) :: yv
 real, dimension(param%nx+1,param%ny+1), intent(in) :: x
 real, dimension(param%nx+1,param%ny+1), intent(in) :: y
 real, dimension(param%nx,param%ny), intent(out) :: T0

 integer :: i,j

 print*,'initial temperature...'

 do i=1,param%nx
   do j=1,param%ny
     T0(i,j)=param%Ti
   end do
 end do

end subroutine initial_temperature
!*********************************


!*****************************************
subroutine initial_velocity(param,x,y,U,V)
!*****************************************            

 use m_type

 implicit none

 type (donnees), intent(in) ::param
 real, dimension(param%nx+1,param%ny+1), intent(in) :: x
 real, dimension(param%nx+1,param%ny+1), intent(in) :: y
 real, dimension(param%nx+1,param%ny), intent(out) :: U
 real, dimension(param%nx,param%ny+1), intent(out) :: V

 integer :: i,j
 real :: x_loc,y_loc
 real :: pi

 print*,'initial velocity...'

 
   do i=1,param%nx+1
     do j=1,param%ny
       U(i,j) = param%U0
     end do
   end do
   do i=1,param%nx
     do j=1,param%ny+1
       V(i,j) = 0. 
     end do
   end do

end subroutine initial_velocity
!******************************


!*****************************************
subroutine ir_velocity(param,x,y,U,V)
!*****************************************            
  
   use m_type
  
   implicit none
  
   type (donnees), intent(in) ::param
   real, dimension(param%nx+1,param%ny+1), intent(in) :: x
   real, dimension(param%nx+1,param%ny+1), intent(in) :: y
   real, dimension(param%nx+1,param%ny), intent(out) :: U
   real, dimension(param%nx,param%ny+1), intent(out) :: V
  
   integer :: i,j
   real :: x_loc,y_loc
   real :: pi
  
  print*, 'is velocity uniform'
  if (param%Type_vel==1) then 
    print*,'non unifrom velocity...'
    do i=1,param%nx+1
      do j=1,param%ny
        U(i,j) = 6*param%U0*y(i,j)*(1-y(i,j)/(2*param%Ly))/(2*param%Ly)
      end do
    end do
    do i=1,param%nx
      do j=1,param%ny+1
        V(i,j) = 0. 
      end do
    end do
  end if 
  end subroutine ir_velocity
!******************************


!***********************************
subroutine calc_dt(param,x,y,U,V,dt)
!***********************************

 use m_type

 implicit none

 type (donnees), intent(in) :: param
 real, dimension(param%nx+1,param%ny+1), intent(in) :: x,y
 real, dimension(param%nx+1,param%ny), intent(in) :: U
 real, dimension(param%nx,param%ny+1), intent(in) :: V
 real, intent(out) :: dt

 real :: dt_loc, dx, dy

 integer :: i,j

 print*,'computing dt...'

 dt = 1.e8
 do j=1,param%ny
   do i=1,param%nx
     dx = x(i+1,j)-x(i,j)
     dy = y(i,j+1)-y(i,j)
     dt_loc = 1. / ( abs(U(i,j))/(param%CFL*dx) + abs(V(i,j))/(param%CFL*dy)  &
                     + param%D*(1./(dx*dx)+1./(dy*dy))/param%R )
     dt = min(dt,dt_loc)
   end do
 end do

 print*,'dt = ',dt

end subroutine calc_dt
!*********************


!****************************************************
subroutine calc_flux_adv(param,x,y,xv,yv,U,V,T0,Fadv)
!****************************************************

 use m_type

 implicit none

 type (donnees), intent(in) ::param
 real, dimension(param%nx+1,param%ny+1), intent(in) :: x,y
 real, dimension(param%nx,param%ny), intent(in) :: xv,yv
 real, dimension(param%nx+1,param%ny), intent(in) :: U
 real, dimension(param%nx,param%ny+1), intent(in) :: V
 real, dimension(param%nx,param%ny), intent(in) :: T0
 real, dimension(param%nx,param%ny), intent(inout) :: Fadv

 real, dimension(param%nx,param%ny) :: Fadv_o,Fadv_e,Fadv_s,Fadv_n
 real :: T_amont
 integer :: i,j,k

 ! Advection term

   ! East flux
   ! In the domain
   do i=1,param%nx-1
     do j=1,param%ny
       if (U(i+1,j)>=0.) then
          T_amont = T0(i,j)
       else
          T_amont = T0(i+1,j)
       end if
       Fadv_e(i,j) = -1.*U(i+1,j)*T_amont*(y(i+1,j+1)-y(i+1,j))
     end do
   end do
   ! BC
   i=param%nx
     do j=1,param%ny
       if (U(i+1,j)>=0.) then
          T_amont = T0(i,j)
       else
          print*,"BC not implemented 01"
          stop
       end if
       Fadv_e(i,j) = -1.*U(i+1,j)*T_amont*(y(i+1,j+1)-y(i+1,j))
     end do

   ! West flux
   ! In the domain
   do i=2,param%nx
     do j=1,param%ny
       Fadv_o(i,j) = -1.*Fadv_e(i-1,j)
     end do
   end do
   ! BC
   i=1
     do j=1,param%ny
       if (U(i,j)<=0.) then
          T_amont = T0(i,j)
       else
          T_amont = param%Tg
       end if
       Fadv_o(i,j) = U(i,j)*T_amont*(y(i,j+1)-y(i,j))
     end do

   ! North flux
   ! In the domain
   do i=1,param%nx
     do j=1,param%ny-1
       if (V(i,j+1)>=0.) then
          T_amont = T0(i,j)
       else
          T_amont = T0(i,j+1)
       end if
       Fadv_n(i,j) = -1.*V(i,j+1)*T_amont*(x(i+1,j+1)-x(i,j+1))
     end do
   end do
   ! BC
   j=param%ny
     do i=1,param%nx
       if (V(i,j+1)>=0.) then
          T_amont = T0(i,j)
       else
          T_amont = 0.
       end if
       Fadv_n(i,j) = -1.*V(i,j+1)*T_amont*(x(i+1,j+1)-x(i,j+1))
     end do

   ! South flux
   ! In the domain
   do i=1,param%nx
     do j=2,param%ny
       Fadv_s(i,j) = -1.*Fadv_n(i,j-1)
     end do
   end do
   ! BC
   j=1
     do i=1,param%nx
       if (V(i,j)<=0.) then
          T_amont = T0(i,j)
       else
          T_amont = param%Tb
       end if
       Fadv_s(i,j) = V(i,j)*T_amont*(x(i+1,j)-x(i,j))
     end do

   ! c) Total summation

   do i=1,param%nx
     do j=1,param%ny
       Fadv(i,j) = Fadv_o(i,j) + Fadv_e(i,j) + Fadv_s(i,j) + Fadv_n(i,j)
     end do
   end do

end subroutine calc_flux_adv
!***************************


!**************************************************
subroutine calc_flux_diff(param,x,y,xv,yv,T0,Fdiff)
!**************************************************

 use m_type

 implicit none

 type (donnees), intent(in) ::param
 real, dimension(param%nx+1,param%ny+1), intent(in) :: x,y
 real, dimension(param%nx,param%ny), intent(in) :: xv,yv
 real, dimension(param%nx,param%ny), intent(in) :: T0
 real, dimension(param%nx,param%ny), intent(inout) :: Fdiff

 real, dimension(param%nx,param%ny) :: Fdiff_o,Fdiff_e,Fdiff_s,Fdiff_n
 integer :: i,j,k

 ! Diffusive term

   ! West flux
   ! In the domain
   do i=2,param%nx
     do j=1,param%ny
       Fdiff_o(i,j) = -1.*param%D*(T0(i,j)-T0(i-1,j))/(xv(i,j)-xv(i-1,j))*(y(i,j+1)-y(i,j))
     end do
   end do
   ! BC
   i=1
     do j=1,param%ny
       Fdiff_o(i,j) = -1.*param%D*(T0(i,j)-param%Tg)/(2.*(xv(i,j)-x(i,j)))*(y(i,j+1)-y(i,j))
     end do
  
   ! East flux
   ! In the domain
   do i=1,param%nx-1
     do j=1,param%ny
       Fdiff_e(i,j) = -1.*Fdiff_o(i+1,j)
     end do
   end do
   ! BC
   i=param%nx
     do j=1,param%ny
       Fdiff_e(i,j) = -1.*Fdiff_o(i,j)
     end do

   ! South flux
   ! In the domain
   do i=1,param%nx
     do j=2,param%ny
       Fdiff_s(i,j) = -1.*param%D*(T0(i,j)-T0(i,j-1))/(yv(i,j)-yv(i,j-1))*(x(i+1,j)-x(i,j))
     end do
   end do
   ! BC
   j=1
     do i=1,param%nx
       Fdiff_s(i,j) = -1.*param%D*(T0(i,j)-param%Tb)/(2.*(yv(i,j)-y(i,j)))*(x(i+1,j)-x(i,j))
     end do

   ! North flux
   ! In the domain
   do i=1,param%nx
     do j=1,param%ny-1
       Fdiff_n(i,j) = -1.*Fdiff_s(i,j+1)
     end do
   end do
   ! BC
   j=param%ny
     do i=1,param%nx
       Fdiff_n(i,j) = 0. 
     end do


   ! c) Total summation

   do i=1,param%nx
     do j=1,param%ny
       Fdiff(i,j) = Fdiff_o(i,j) + Fdiff_e(i,j) + Fdiff_s(i,j) + Fdiff_n(i,j)
     end do
   end do

end subroutine calc_flux_diff
!****************************


!*****************************************************
subroutine advance_time(param,dt,vol,Fadv,Fdiff,T0,T1)
!*****************************************************

 use m_type

 implicit none

 type (donnees), intent(in) ::param
 real, intent(in) :: dt
 real, dimension(param%nx,param%ny), intent(in) :: vol
 real, dimension(param%nx,param%ny), intent(in) :: Fadv,Fdiff
 real, dimension(param%nx,param%ny), intent(inout) :: T0,T1

 integer :: i,j

 do i=1,param%nx
   do j=1,param%ny
     T1(i,j) = T0(i,j) + dt/vol(i,j) * (Fadv(i,j) + Fdiff(i,j))
   end do
 end do

 do i=1,param%nx
   do j=1,param%ny
     T0(i,j)=T1(i,j)
   end do
 end do

end subroutine advance_time
!**************************
