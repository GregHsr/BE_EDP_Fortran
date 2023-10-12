!*****************************************************
subroutine creation_A(param,dt,vol,A_base,x,y,xv,yv)
!*****************************************************
    !***************Description*****************
    ! Create the A matrice without boundary condition
    !*******************************************
    !*   
    !*        | a+1  d  <---> b                 *                    *|
    !*        |  e  a+1   d   <---> b                                 |
    !*        |  <                                                    |
    !*        |  -                                                    |
    !*        |  >                                                    |
    !*        |  c                                                    |
    !*        |                                                       |
    !*        |                                                       |
    !*        |                                                       |
    !*        |                                                       |
    !*        |                                                       |
    !*        |  *                                    *       A(LV,LV)|
    
    use m_type
    implicit none
    
    type (donnees), intent(in) ::param
    real, intent(in) :: dt
    real, dimension(param%nx,param%ny), intent(in) :: xv,yv,vol
    real, dimension(param%nx+1,param%ny+1), intent(in) :: x,y

    real :: coef_a1,coef_a2,coef_a3,coef_a4,coef_b,coef_c,coef_d,coef_e
    
    real :: delta_xi  !distance between two center (x<->x+1)
    real :: Gdelta_xi !distance of x side of the cell 
    real :: delta_yj !distance between two center (y<->y+1) 
    real :: Gdelta_yj !distance of y side of the cell
    real :: delta_ximinus1 !distance between two center (x<->x-1)
    real :: delta_yjminus1 !distance between two center (y<->y-1)
    
    real, dimension(param%nx*param%ny,param%nx*param%ny), intent(out) :: A_base
    
    integer :: i,j
    integer :: k 

    ! Initialisation de A_base
    A_base(:,:) = 0.    
    
    ! Calcul des coefficients et remplissage de A_base
    do i=1,param%nx
        do j=1,param%ny
    
            k = (j-1)*param%nx + i

            !Calcul des coef Gdelta
            Gdelta_xi = x(i+1,j)-x(i,j)
            Gdelta_yj = y(i,j+1)-y(i,j)

            ! Calcul de delta_xi
            if (i==param%nx) then 
                delta_xi = Gdelta_xi/2
            else
                delta_xi = xv(i+1,j)-xv(i,j)
            end if
    
            !Calcul de delta_yj
            if (j==param%ny) then
                delta_yj = Gdelta_yj/2
            else
                delta_yj = yv(i,j+1)-yv(i,j)
            end if
    
            ! Calcul of delta_ximinus1
            if (i==1) then
                delta_ximinus1 = Gdelta_xi/2
            else 
                delta_ximinus1 = xv(i,j)-xv(i-1,j)
            end if
    
            ! Calcul of delta_yjminus1
            if (j==1) then
                delta_yjminus1 = Gdelta_yj/2
            else 
                delta_yjminus1 = yv(i,j)-yv(i,j-1)
            end if
           
            ! Calcul des coefficients
            coef_a1 = (param%D*dt*Gdelta_yj)/(vol(i,j)*delta_xi)
            coef_a2 = (param%D*dt*Gdelta_yj)/(vol(i,j)*delta_ximinus1)
            coef_a3 = (param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yj)
            coef_a4 = (param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yjminus1)

            coef_b = -(param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yj)
            coef_c = -(param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yjminus1)
            coef_d = -(param%D*dt*Gdelta_yj)/(vol(i,j)*delta_xi)
            coef_e = -(param%D*dt*Gdelta_yj)/(vol(i,j)*delta_ximinus1)

            ! Condition aux limites
            if (j==1) then 
                coef_c = 0.
                if (i==1) coef_e = 0.
            end if

            if (j==param%Ny) then
                coef_a3 = 0.
                coef_b = 0.
                if (i==param%Nx) then
                    coef_a1 = 0.
                    coef_a2 = 0.
                    coef_d = 0.
                    coef_e = 0.
                end if
            end if

            if (i==1) then
                coef_e = 0.
                if (j==param%Ny) then
                    coef_a3 = 0.
                    coef_b = 0.
                end if
            end if

            if (i==param%Nx) then
                coef_a2 = 0. 
                coef_a1 = 0.
                coef_d = 0.
                coef_e = 0.
                if (j==1) then
                    coef_c = 0.
                end if
            end if

            ! Make A_base
            A_base(k,k)=1+coef_a1+coef_a2+coef_a3+coef_a4
            if ((k-1)>=1) A_base(k,k-1)=coef_e
            if ((k+1)<=param%Nx*param%Ny) A_base(k,k+1)=coef_d            
            if ((k-param%nx)>=1) A_base(k,k-param%nx)=coef_c
            if ((k+param%nx)<=param%Nx*param%Ny) A_base(k,k+param%nx)=coef_b
            
        end do
    end do
    
end subroutine creation_A
!**************************
    

!***********************************************************
subroutine creation_B(param,B_base,Fadv,T0,dt,xv,yv,vol,x,y)
!***********************************************************
!Création du vecteur B_base
!B_base est un vecteur de taille Nx*Ny
!***********************************************************
    use m_type
    implicit none

    type (donnees), intent(in) :: param
    real, dimension(param%nx,param%ny), intent(in) :: Fadv,T0
    real, dimension(param%nx,param%ny), intent(in) :: xv,yv,vol
    real, dimension(param%nx+1,param%ny+1), intent(in) :: x,y
    real, intent(in) :: dt

    real, dimension(param%Nx*param%Ny), intent(out) :: B_base

    integer :: i,j,k

    real :: delta_xi  !distance between two center (x)
    real :: Gdelta_xi !distance of x side of the cell 
    real :: delta_yj !distance between two center (y) 
    real :: Gdelta_yj !distance of y side of the cell
    real :: delta_ximinus1 !distance between two center (x<->x-1)
    real :: delta_yjminus1 !distance between two center (y<->y-1)
    real :: coef_b,coef_c,coef_d,coef_e 

    do i = 1,param%Nx
        do j =1,param%Ny

            k = (j-1)*param%Nx+i

            !Pré-remplissage de la matrice B_base
            B_base(k)=T0(i,j)+dt*Fadv(i,j)/vol(i,j) 
            
            !Calcul des coef Gdelta
            Gdelta_xi = x(i+1,j)-x(i,j)
            Gdelta_yj = y(i,j+1)-y(i,j)
    
            ! Calcul de delta_xi
            if (i==param%nx) then 
                delta_xi = Gdelta_xi/2
            else
                delta_xi = xv(i+1,j)-xv(i,j)
            end if
    
            !Calcul de delta_yj
            if (j==param%ny) then
                delta_yj = Gdelta_yj/2
            else
                delta_yj = yv(i,j+1)-yv(i,j)
            end if
    
            ! Calcul of delta_ximinus1
            if (i==1) then
                delta_ximinus1 = Gdelta_xi/2
            else 
                delta_ximinus1 = xv(i,j)-xv(i-1,j)
            end if
    
            ! Calcul of delta_yjminus1
            if (j==1) then
                delta_yjminus1 = Gdelta_yj/2
            else 
                delta_yjminus1 = yv(i,j)-yv(i,j-1)
            end if

            !Condition aux limites
            if (j==1) then
                coef_c = -(param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yjminus1)
                B_base(k)=B_base(k)-coef_c*param%Tb
            end if
            
            if (i==1) then
                coef_e = -(param%D*dt*Gdelta_yj)/(vol(i,j)*delta_ximinus1)
                B_base(k)=B_base(k)-coef_e*param%Tg
!                if (j==1) then
!                    coef_c = -(param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yjminus1)
!                   B_base(k)=B_base(k)-coef_e*param%Tg
!                end if
            end if

        end do
    end do
end subroutine creation_B
!*********************************



!*********************************
subroutine miseajour_T(param, B_gauss, T_fut)
!*********************************
! Transformation du vecteur B_gauss sur k avec (Nx*Ny) paramètres en un matrice sur (i,j)
    use m_type
    implicit none 
    
    type (donnees), intent(in) :: param
    real, dimension(param%Nx,param%Ny), intent(out) :: T_fut
    real, dimension(param%Nx*param%Ny), intent(in) :: B_gauss

    integer :: i,j 
    integer :: k
    
    do j=1,param%Ny
        do i=1,param%Nx
            k = (j-1)*param%Nx+i
            T_fut(i,j) = B_gauss(k)
        end do
    end do

end subroutine miseajour_T
!*********************************


!*******************************
SUBROUTINE GAUSSIJ(LV,A,B)
!*******************************
!*
!C             RESOLUTION D'UN SYSTEME LINEAIRE
!*
!C  METHODE : Methode de Gauss.
!*
!C  LANGAGE : FORTRAN
!*
!C  MODE D'UTILISATION : CALL GAUSSIJ (LV,A,B)
!*
!C  Donnees : A  Coefficients de la matrice, variable a deux dimensions
!*               dont les valeurs numeriques doivent etre fournies
!*               conformement au schema ci-dessous.
!*            B  Termes du 2eme membre, variable a un indice.
!*               A la sortie de GAUSS, la solution se trouve dans B.
!*            LV Ordre de la matrice A.
!*
!*        |                                                       |
!*        | A(1,1)       *                  *                    *|
!*        |  *                                                    |
!*        |                                                       |
!*        |                                                       |
!*        |                                                       |
!*        |                                                       |
!*        |                                                       |
!*        |                                                       |
!*        |                                                       |
!*        |                                                       |
!*        |                                                       |
!*        |  *                                    *       A(LV,LV)|
!*

INTEGER, INTENT(IN) :: LV
REAL, DIMENSION(LV,LV), INTENT(inout) :: A
REAL, DIMENSION(LV), INTENT(inout) :: B

REAL, DIMENSION(LV,LV) :: ATEMP

INTEGER :: I, J, K
REAL :: DIVB, BI, AKI

DO I=1,LV
    DO J=1,LV
    ATEMP(I,J)=A(I,J)
    ENDDO
ENDDO

DO I=1,LV
    DIVB=1./ATEMP(I,I)
    B(I)=B(I)*DIVB
    BI=B(I)
    DO J=LV,I,-1
        ATEMP(I,J)=ATEMP(I,J)*DIVB
    ENDDO
    DO K=1,I-1
        AKI=ATEMP(K,I)
        B(K)=B(K)-AKI*BI
        DO J=LV,I,-1
    ATEMP(K,J)=ATEMP(K,J)-AKI*ATEMP(I,J)
        ENDDO
    ENDDO
    DO K=I+1,LV
        AKI=ATEMP(K,I)
        B(K)=B(K)-AKI*BI
        DO J=LV,I,-1
    ATEMP(K,J)=ATEMP(K,J)-AKI*ATEMP(I,J)
        ENDDO
    ENDDO
ENDDO

RETURN

END SUBROUTINE GAUSSIJ

!**************************

!***********************************
subroutine create_A_band(MX,NA,A,AB)
!***********************************
!*
!C            PASSAGE D'UNE MATRICE PLEINE A UNE MATRICE BANDE
!*
!C  LANGAGE : FORTRAN
!*
!C  Donnees : Cette routine cree une matrice bande AB de dimension (NA,LB)
!*            a partir d'une matrice pleine A de dimension (NA,NA) telle que:
!*            NA  Ordre de la matrice A
!*            LB Largeur de la bande = 2 MX + 1;
!*            MX est appelee "demi largeur de bande"
!*
!*             La matrice A est de la forme:
!*           
!*             | A(1,1)       *                  *                    *|
!*             |  *                                                    |
!*             |                                                       |
!*             |                                                       |
!*             |                                                       |
!*             |                                                       |
!*             |                                                       |
!*             |                                                       |
!*             |                                                       |
!*             |                                                       |
!*             |                                                       |
!*             |  *                                    *       A(NA,NA)|
!*
!*
!*             Les coefficients de la matrice AB correspondent a:
!* 
!* AB(1,1) ... | AB(1,MX+1)   ...    AB(1,LB)                            |
!*             |                                                         |
!*             | AB(2,MX)      .....    AB(2,LB)                         |
!*             |                                                         |
!*             |           *       .....       *                         |
!*             |                                                         |
!*             |               *       .....       *                     |
!*             |                                                         |
!*             |                   AB(I,1) ... AB(I,MX+1) ... AB(I,LB)   |
!*             |                                                         |
!*             |                         *       .....       *           |
!*             |                                                         |
!*             |                             *       .....       *       |
!*             |                                                         |
!*             |                               AB(NA,1)  ...  AB(NA,MX+1)| ...  AB(NA,LB)

 implicit none

 integer, intent(in) :: MX, NA 
 real, dimension(NA,NA), intent(in) :: A
 real, dimension(NA,2*MX+1), intent(out) :: AB

 integer :: i,j

  do i=1,NA
   do j=1,2*MX+1
     AB(i,j) = 0.
   end do
 end do

  do i=1,MX+1
   do j=1,NA-(i-1)
     AB(j,(MX+1)+(i-1)) = A(j,j+(i-1))
     AB(NA+1-j,(MX+1)-(i-1)) = A(NA+1-j,NA+1-j-(i-1))
   end do
 end do

 return

end subroutine create_A_band
!***************************

!************************************
SUBROUTINE SOR(MX,N,A,B,R0,W,X)
!************************************
!*
!C             RESOLUTION D'UN SYSTEME LINEAIRE
!*
!C  METHODE : Methode de Sur-Relaxation Successive SOR.
!*
!C  LANGAGE : FORTRAN
!*
!C  Donnees : A  Coefficients de la matrice bande, variable a deux dimensions 
!*               dont les valeurs numeriques doivent etre fournies conformement 
!*               au schema ci-dessous.
!*               (Les points exterieurs a la bande ne sont pas pris en compte
!*               lors du calcul).
!*            B  Termes du 2eme membre, variable a un indice.
!*               A la sortie de SOR, la solution se trouve dans X.
!*            N  Dimension de la matrice A.
!*            LB Largeur de la bande = 2 MX + 1;
!*            MX est appelee "demi largeur de bande"
!*            W facteur de relaxation
!*
!*            |                                                       |
!* A(1,1) ... | A(1,MX+1)   ...    A(1,LB)                            |
!*            |                                                       |
!*            | A(2,MX)      .....    A(2,LB)                         |
!*            |                                                       |
!*            |           *       .....       *                       |
!*            |                                                       |
!*            |               *       .....       *                   |
!*            |                                                       |
!*            |                   A(I,1) ... A(I,MX+1) ... A(I,LB)    |
!*            |                                                       |
!*            |                         *       .....       *         |
!*            |                                                       |
!*            |                             *       .....       *     |
!*            |                                                       |
!*            |                                 A(N,1)  ...  A(N,MX+1)| ...  A(N,LB)

IMPLICIT NONE

INTEGER, INTENT(IN) :: MX, N
REAL, DIMENSION(N,2*MX+1), INTENT(inout) :: A
REAL, DIMENSION(N), INTENT(inout) :: B
REAL, INTENT(in) :: R0, W
REAL, DIMENSION(N), INTENT(out) :: X

INTEGER :: i, cc, dd, compteur 
REAL, DIMENSION(2*MX+N) :: Y, Y0
REAL :: ECART, C, D, Z, Z0

DO i=1,2*MX+N
 	Y(i)=0.
 	Y0(i)=0.
ENDDO
ECART=1.

compteur = 0
DO WHILE(ECART>R0 .and. compteur<=10000)
  compteur = compteur + 1
  DO i=MX+1,MX+N
    ! -------> calcul de la somme inférieure appelée C
    C=0
    DO cc=1,MX
      C=C+Y(i-cc)*A(i-MX,MX+1-cc)
    ENDDO
    ! -------> calcul de la somme supérieure appelée D
    D=0
    DO dd=1,MX
      D=D+Y0(i+dd)*A(i-MX,MX+1+dd)
    ENDDO
    ! -------> calcul de X,k+1
    Y(i)=(1.-W)*Y0(i)+(W/A(i-MX,MX+1))*(B(i-MX)-C-D)
  ENDDO

  ! -------> critère d'arrêt
  Z0=0.
  Z=0.
  DO i=MX+1,MX+N
    Z=Z+Y(i)*Y(i)
    Z0=Z0+Y0(i)*Y0(i)
  ENDDO
 
  ECART=ABS((Z)**(0.5)-(Z0)**(0.5))
  
  DO i=MX+1,MX+N
   Y0(i)=Y(i)
  ENDDO

END DO

if(compteur>=10000)then
  print*,"Probleme de convergence du solveur SOR"
  print*,"(arret apres plus de 10000 iter)"
  stop
end if
! -----> écriture dans X

  DO i=MX+1,MX+N
    X(i-MX)=Y(i)
  ENDDO

END SUBROUTINE SOR
!***************************