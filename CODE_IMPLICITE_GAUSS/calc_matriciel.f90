!*****************************************************
subroutine init_A(param,dt,vol,A_base,coef_a1,coef_a2,coef_a3,coef_a4,coef_b,coef_c,coef_d,coef_e,x,y,xv,yv)
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

    real,intent(out) :: coef_a1,coef_a2,coef_a3,coef_a4,coef_b,coef_c,coef_d,coef_e
    
    real :: delta_xi  !distance between two center (x)
    real :: Gdelta_xi !distance of x side of the cell 
    real :: delta_yj !distance between two center (y) 
    real :: Gdelta_yj !distance of y side of the cell
    real :: delta_ximinus1
    real :: delta_yjminus1
    
    real, dimension(param%nx*param%ny,param%nx*param%ny), intent(out) :: A_base
    
    integer :: i,j
    integer :: k 
    
    A_base(:,:) = 0.
    
    do i=1,param%nx
        do j=1,param%ny
    
            k = (j-1)*param%nx + i
    
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
            if (i==1) then
                delta_yjminus1 = Gdelta_yj/2
            else 
                delta_yjminus1 = yv(i,j)-yv(i,j-1)
            end if
            
            ! Calcul des coefficients a1,a2,a3,a4
            coef_a1 = (param%D*dt*Gdelta_yj)/(vol(i,j)*delta_xi)
            coef_a2 = (param%D*dt*Gdelta_yj)/(vol(i,j)*delta_ximinus1)
            coef_a3 = (param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yj)
            coef_a4 = (param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yjminus1)
    
            A_base(k,k)=1+coef_a1+coef_a2+coef_a3+coef_a4
    
            if (k>1) then
                coef_e = -(param%D*dt*Gdelta_yj)/(vol(i,j)*delta_ximinus1)
                A_base(k,k-1) = coef_e
            end if
            if (k<param%ny-1) then 
                coef_d = -(param%D*dt*Gdelta_yj)/(vol(i,j)*delta_xi)
                A_base(k,k+1)= coef_d
            end if
            if (k>param%nx) then
                coef_c = -(param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yjminus1)
                coef_c = -(param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yjminus1)
                A_base(k,k-param%nx)= coef_c
            end if
            if (k<param%nx) then
                coef_b = -(param%D*dt*Gdelta_xi)/(vol(i,j)*delta_yj)
                A_base(k,k+param%nx)= coef_b
            end if
        end do
    end do
    
    end subroutine init_A
    !**************************
    
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