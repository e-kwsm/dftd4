!> @brief test calculation of dispersion related properties
subroutine test_dftd4_properties
   use iso_fortran_env, wp => real64
   use assertion
   use class_molecule
   use dftd4
   implicit none
   type(molecule)       :: mol
   integer              :: ndim
   real(wp) :: molpol,molc6,molc8        ! molecular Polarizibility
   real(wp),allocatable :: gweights(:)   ! gaussian weights
   real(wp),allocatable :: refc6(:,:)    ! reference C6 coeffients
   real(wp),allocatable :: c6ab(:,:)
   real(wp),allocatable :: aw(:,:)

   real(wp),parameter :: thr = 1.0e-10_wp
   integer, parameter :: nat = 3
   integer, parameter :: at(nat) = [8,1,1]
   real(wp),parameter :: xyz(3,nat) = reshape(&
      [ 0.00000000000000_wp, 0.00000000000000_wp,-0.73578586109551_wp, &
      & 1.44183152868459_wp, 0.00000000000000_wp, 0.36789293054775_wp, &
      &-1.44183152868459_wp, 0.00000000000000_wp, 0.36789293054775_wp  &
      & ],shape(xyz))
   real(wp),parameter :: covcn(nat) = &
      [ 1.6105486019977_wp,  0.80527430099886_wp, 0.80527430099886_wp]
   real(wp),parameter :: q(nat) = &
      [-0.59582744708873_wp, 0.29791372354436_wp, 0.29791372354436_wp]
   real(wp),parameter :: g_a = 3.0_wp
   real(wp),parameter :: g_c = 2.0_wp
   real(wp),parameter :: wf  = 6.0_wp
   integer, parameter :: lmbd = p_mbd_approx_atm
   integer, parameter :: refqmode = p_refq_goedecker

   call mol%allocate(nat,.false.)
   mol%at  = at
   mol%xyz = xyz
   mol%chrg = 0.0_wp

   call d4init(mol,g_a,g_c,refqmode,ndim)

   call assert_eq(ndim,8)

   allocate( gweights(ndim),refc6(ndim,ndim),&
             c6ab(mol%nat,mol%nat),aw(23,mol%nat) )

   call d4(mol,ndim,wf,g_a,g_c,covcn,gweights,refc6)
   call mdisp(mol,ndim,q,g_a,g_c,gweights,refc6,molc6,molc8,molpol,aw,c6ab)

   call assert_close(molpol,9.4271529107854_wp,thr)
   call assert_close(molc6, 44.521545727311_wp,thr)
   call assert_close(molc8, 798.69639423703_wp,thr)

   call assert_close(aw(1,1),6.7482856960122_wp,thr)
   call assert_close(aw(4,2),1.1637689328906_wp,thr)
   call assert_close(aw(7,2),aw(7,3),           thr)

   call assert_close(c6ab(1,2),c6ab(2,1),         thr)
   call assert_close(c6ab(1,1),24.900853125836_wp,thr)
   call assert_close(c6ab(1,3),4.1779697881925_wp,thr)
   call assert_close(c6ab(2,2),c6ab(2,3),         thr)

   call assert_close(sum(gweights),3.0_wp,               thr)
   call assert_close(gweights(2),0.18388886232894E-01_wp,thr)
   call assert_close(gweights(7),0.21400765336381E-01_wp,thr)

   call assert_close(refc6(5,1),10.282422024500_wp,thr)
   call assert_close(refc6(8,6),3.0374149102818_wp,thr)

   call mol%deallocate

   ! done: everythings fine
   call terminate(0)
end subroutine test_dftd4_properties

!> @brief test calculation of dispersion energies
subroutine test_dftd4_energies
   use iso_fortran_env, wp => real64
   use assertion
   use class_molecule
   use class_param
   use dftd4
   implicit none
   type(molecule)       :: mol
   integer  :: idum
   real(wp) :: energy

   real(wp),parameter :: thr = 1.0e-10_wp
   integer, parameter :: nat = 3
   integer, parameter :: at(nat) = [8,1,1]
   real(wp),parameter :: xyz(3,nat) = reshape(&
      [ 0.00000000000000_wp, 0.00000000000000_wp,-0.73578586109551_wp, &
      & 1.44183152868459_wp, 0.00000000000000_wp, 0.36789293054775_wp, &
      &-1.44183152868459_wp, 0.00000000000000_wp, 0.36789293054775_wp  &
      & ],shape(xyz))
   real(wp),parameter :: covcn(nat) = &
      [ 1.6105486019977_wp,  0.80527430099886_wp, 0.80527430099886_wp]
   real(wp),parameter :: q(nat) = &
      [-0.59582744708873_wp, 0.29791372354436_wp, 0.29791372354436_wp]
   real(wp),parameter :: g_a = 3.0_wp
   real(wp),parameter :: g_c = 2.0_wp
   real(wp),parameter :: wf  = 6.0_wp
   integer, parameter :: lmbd = p_mbd_approx_atm
   integer, parameter :: refqmode = p_refq_goedecker
   integer, parameter :: ndim = 8
   real(wp),parameter :: gweights(ndim) = &
      [ 0.15526686926080E-06_wp, 0.18388886232894E-01_wp, 0.89143504504233_wp, &
      & 0.90175913457907E-01_wp, 0.21400765336381E-01_wp, 0.97859923466362_wp, &
      & 0.21400765336381E-01_wp, 0.97859923466362_wp ]
   real(wp),parameter :: refc6(ndim,ndim) = reshape(&
      [ 0.0000000000000_wp,      0.0000000000000_wp,      0.0000000000000_wp,  &
      & 0.0000000000000_wp,      10.282422024500_wp,      6.7431228212696_wp,  &
      & 10.282422024500_wp,      6.7431228212696_wp,      0.0000000000000_wp,  &
      & 0.0000000000000_wp,      0.0000000000000_wp,      0.0000000000000_wp,  &
      & 12.052429296454_wp,      7.8894703511335_wp,      12.052429296454_wp,  &
      & 7.8894703511335_wp,      0.0000000000000_wp,      0.0000000000000_wp,  &
      & 0.0000000000000_wp,      0.0000000000000_wp,      13.246161891965_wp,  &
      & 8.6635841400632_wp,      13.246161891965_wp,      8.6635841400632_wp,  &
      & 0.0000000000000_wp,      0.0000000000000_wp,      0.0000000000000_wp,  &
      & 0.0000000000000_wp,      10.100325850238_wp,      6.6163452797181_wp,  &
      & 10.100325850238_wp,      6.6163452797181_wp,      10.282422024500_wp,  &
      & 12.052429296454_wp,      13.246161891965_wp,      10.100325850238_wp,  &
      & 0.0000000000000_wp,      0.0000000000000_wp,      7.6362416262742_wp,  &
      & 4.7593057612608_wp,      6.7431228212696_wp,      7.8894703511335_wp,  &
      & 8.6635841400632_wp,      6.6163452797181_wp,      0.0000000000000_wp,  &
      & 0.0000000000000_wp,      4.7593057612608_wp,      3.0374149102818_wp,  &
      & 10.282422024500_wp,      12.052429296454_wp,      13.246161891965_wp,  &
      & 10.100325850238_wp,      7.6362416262742_wp,      4.7593057612608_wp,  &
      & 0.0000000000000_wp,      0.0000000000000_wp,      6.7431228212696_wp,  &
      & 7.8894703511335_wp,      8.6635841400632_wp,      6.6163452797181_wp,  &
      & 4.7593057612608_wp,      3.0374149102818_wp,      0.0000000000000_wp,  &
      & 0.0000000000000_wp],     shape(refc6))
   type(dftd_parameter),parameter :: dparam_pwpb95 = dftd_parameter ( &
      &  s6=0.8200_wp, s8=-0.34639127_wp, a1=0.41080636_wp, a2=3.83878274_wp )
   type(dftd_parameter),parameter :: dparam_pbe    = dftd_parameter ( &
      &  s6=1.0000_wp, s8=0.95948085_wp, a1=0.38574991_wp, a2=4.80688534_wp )
   type(dftd_parameter),parameter :: dparam_random = dftd_parameter ( &
      &  s6=0.95_wp, s8=0.45_wp, s10=0.65_wp, s9=1.10_wp, a1=0.43_wp, a2=5.10_wp )

   call mol%allocate(nat,.false.)
   mol%at  = at
   mol%xyz = xyz
   mol%chrg = 0.0_wp

   call d4init(mol,g_a,g_c,refqmode,idum)

   call assert_eq(idum,ndim)

   energy = +1.0_wp ! energy is intent(out)

   call edisp(mol,ndim,q,dparam_pwpb95,g_a,g_c,gweights,refc6,lmbd,energy)
   call assert_close(energy,-0.22526819184723E-03_wp,thr)

   call edisp(mol,ndim,q,dparam_pbe,g_a,g_c,gweights,refc6,lmbd,energy)
   call assert_close(energy,-0.19788865790096E-03_wp,thr)
   !-0.19558245089408E-03

   call edisp(mol,ndim,q,dparam_random,g_a,g_c,gweights,refc6,lmbd,energy)
   call assert_close(energy,-0.11213581758666E-03_wp,thr)

   call mol%deallocate

   ! done: everythings fine
   call terminate(0)
end subroutine test_dftd4_energies

!> @brief test the general wrapper for DFT-D4 calculations
subroutine test_dftd4_api
   use iso_fortran_env, wp => real64, istdout => output_unit
   use assertion
   use class_molecule
   use class_set
   use class_param
   use dftd4
   implicit none
   type(molecule)       :: mol

   real(wp),parameter :: thr = 1.0e-10_wp
   integer, parameter :: nat = 3
   integer, parameter :: at(nat) = [8,1,1]
   real(wp),parameter :: xyz(3,nat) = reshape(&
      [ 0.00000000000000_wp,  0.00000000000000_wp, -0.73578586109551_wp, &
      & 1.44183152868459_wp,  0.00000000000000_wp,  0.36789293054775_wp, &
      &-1.44183152868459_wp,  0.00000000000000_wp,  0.36789293054775_wp  &
      & ],shape(xyz))
   type(dftd_parameter),parameter :: dparam_b2plyp = dftd_parameter ( &
      &  s6=0.6400_wp, s8=1.16888646_wp, a1=0.44154604_wp, a2=4.73114642_wp )
   type(dftd_parameter),parameter :: dparam_tpss   = dftd_parameter ( &
      &  s6=1.0000_wp, s8=1.76596355_wp, a1=0.42822303_wp, a2=4.54257102_wp )
   type(dftd_options),  parameter :: opt_1 = dftd_options ( &
      &  lmbd = p_mbd_approx_atm, refq = p_refq_goedecker, &
      &  wf = 6.0_wp, g_a = 3.0_wp, g_c = 2.0_wp, &
      &  lmolpol=.false., lenergy=.true., lgradient=.false., lhessian=.true., &
      &  verbose = .false., veryverbose = .false., silent = .false. )
   type(dftd_options),  parameter :: opt_2 = dftd_options ( &
      &  lmbd = p_mbd_approx_atm, refq = p_refq_goedecker, &
      &  wf = 6.0_wp, g_a = 3.0_wp, g_c = 2.0_wp, &
      &  lmolpol=.false., lenergy=.false., lgradient=.true., lhessian=.false., &
      &  verbose = .false., veryverbose = .false., silent = .true. )

   real(wp) :: energy
   real(wp),allocatable :: gradient(:,:),hessian(:,:)

   allocate( gradient(3,nat), hessian(3*nat,3*nat) )
   energy   = 0.0_wp
   gradient = 0.0_wp
   hessian  = 0.0_wp

   call mol%allocate(nat,.false.)
   mol%at  = at
   mol%xyz = xyz
   mol%chrg = 0.0_wp
   
   call d4_calculation(istdout,opt_1,mol,dparam_tpss,energy,gradient,hessian)
   call assert_close(energy,-0.26682682254336E-03_wp,thr)

   call assert_close(hessian(3,1), 7.9334628241320_wp,thr)
   call assert_close(hessian(4,8),-3.2756224894310_wp,thr)
   call assert_close(hessian(5,3), 0.0000000000000_wp,thr)

   call d4_calculation(istdout,opt_2,mol,dparam_b2plyp,energy,gradient,hessian)
   call assert_close(energy,-0.13368190339570E-03_wp,thr)

   call assert_close(gradient(1,1), 0.00000000000000E+00_wp,thr)
   call assert_close(gradient(3,1), 0.39778648945254E-04_wp,thr)
   call assert_close(gradient(3,2),-0.19889324472627E-04_wp,thr)
   call assert_close(gradient(1,2),-gradient(1,3),          thr)

   call mol%deallocate

   ! done: everythings fine
   call terminate(0)
end subroutine test_dftd4_api

subroutine test_dftd4_pbc
   use iso_fortran_env, wp => real64, istdout => output_unit
   use assertion
   use class_molecule
   use class_param
   use dftd4
   use eeq_model
   use coordination_number
   use pbc_tools
   implicit none
   real(wp),parameter :: thr = 1.0e-10_wp
   integer, parameter :: nat = 6
   integer, parameter :: at(nat) = [14,14,8,8,8,8]
   real(wp),parameter :: abc(3,nat) = reshape(&
      &[.095985472469032_wp, .049722204206931_wp, 0.10160624337938_wp, &
      & 0.54722204206931_wp, 0.52863628207623_wp, 0.38664208660311_wp, &
      & 0.29843937068984_wp, 0.39572194413818_wp, 0.20321248675876_wp, &
      & 0.23364982659922_wp, 0.85647058758674_wp, 0.31884968761485_wp, &
      & 0.72250232459952_wp, 0.65548544066844_wp, .056207709103487_wp, &
      & 0.70514214000043_wp, 0.28321754549582_wp, 0.36424822189074_wp],&
      & shape(abc))
   real(wp),parameter :: lattice(3,3) = reshape(&
      &[ 8.7413053236641_wp,  0.0000000000000_wp,  0.0000000000000_wp,   &
      &  0.0000000000000_wp,  8.7413053236641_wp,  0.0000000000000_wp,   &
      &  0.0000000000000_wp,  0.0000000000000_wp,  8.7413053236641_wp],  &
      & shape(lattice))
   integer, parameter :: wsc_rep(3) = [1,1,1]
   real(wp),parameter :: g_a = 3.0_wp
   real(wp),parameter :: g_c = 2.0_wp
   real(wp),parameter :: wf  = 6.0_wp
   integer, parameter :: lmbd = p_mbd_approx_atm
   integer, parameter :: refqmode = p_refq_goedecker
   real(wp),parameter :: rthr_cn  = 1600.0_wp
   real(wp),parameter :: rthr_vdw = 4000.0_wp
   integer, parameter :: vdw_rep(3) = [8,8,8]
   integer, parameter :: cn_rep(3)  = [5,5,5]
   type(dftd_parameter),parameter :: dparam_pbe    = dftd_parameter ( &
   &  s6=1.0000_wp, s8=0.95948085_wp, a1=0.38574991_wp, a2=4.80688534_wp )

   type(molecule)       :: mol
   integer              :: ndim
   real(wp) :: molpol,molc6,molc8        ! molecular Polarizibility
   real(wp),allocatable :: gweights(:)   ! gaussian weights
   real(wp),allocatable :: refc6(:,:)    ! reference C6 coeffients
   real(wp),allocatable :: c6ab(:,:)
   real(wp),allocatable :: aw(:,:)
   type(chrg_parameter) :: chrgeq
   real(wp)             :: energy
   real(wp),allocatable :: cn(:)
   real(wp),allocatable :: dcndr(:,:,:)
   real(wp),allocatable :: q(:)
   real(wp),allocatable :: dqdr(:,:,:)
   real(wp),allocatable :: gradient(:,:)


   allocate( cn(nat), dcndr(3,nat,nat), q(nat), dqdr(3,nat,nat+1), &
      &      gradient(3,nat), source = 0.0_wp )

   call mol%allocate(nat,.true.)
   mol%at   = at
   mol%abc  = abc
   mol%npbc = 3
   mol%pbc  = .true.
   mol%lattice = lattice
   mol%volume = dlat_to_dvol(mol%lattice)
   call dlat_to_cell(mol%lattice,mol%cellpar)
   call dlat_to_rlat(mol%lattice,mol%rec_lat)
   call coord_trafo(nat,lattice,abc,mol%xyz)
   call mol%wrap_back

   call generate_wsc(mol,mol%wsc,wsc_rep)
   call d4init(mol,g_a,g_c,refqmode,ndim)

   allocate( gweights(ndim),refc6(ndim,ndim) )

   call print_pbcsum(istdout,mol)

   call pbc_derfcoord(mol,cn,dcndr,900.0d0)
   print'(a)',"CN"
   print'(3g21.14)',cn
   print*
   print'(a)',"dCN/dR"
   print'(3g21.14)',dcndr
   print*

   call new_charge_model_2019(chrgeq,mol)

   call eeq_chrgeq(chrgeq,mol,cn,dcndr,q,dqdr,energy,gradient,&
      &            .false.,.true.,.true.)
   energy = 0.0_wp
   gradient = 0.0_wp
   print'(a)',"q"
   print'(3g21.14)',q
   print*
   print'(a)',"dq/dR"
   print'(3g21.14)',dqdr
   print*

   call pbc_dncoord_d4(mol,cn,dcndr,cn_rep,rthr_cn)
   print'(a)',"covCN"
   print'(3g21.14)',cn
   print*
   print'(a)',"dcovCN/dR"
   print'(3g21.14)',dcndr
   print*

   call d4(mol,ndim,wf,g_a,g_c,cn,gweights,refc6)
   print'(a)',"gweights"
   print'(3g21.14)',gweights
   print*
   print'(a)',"refC6"
   print'(3g21.14)',refc6
   print*

   call dispgrad(mol,ndim,q,dqdr,cn,dcndr,dparam_pbe,wf,g_a,g_c, &
      &        refc6,lmbd,gradient,energy)
   print'(a)',"energy"
   print'(3g21.14)',energy
   print*
   print'(a)',"gradient"
   print'(3g21.14)',gradient
   print*

   energy = 0.0_wp
   gradient = 0.0_wp

   call dispgrad_3d(mol,ndim,q,cn,dcndr,vdw_rep,cn_rep,dparam_pbe, &
      &             wf,g_a,g_c,refc6,lmbd,gradient,energy,dqdr)
   print'(a)',"energy"
   print'(3g21.14)',energy
   print*
   print'(a)',"gradient"
   print'(3g21.14)',gradient
   print*

   stop 1

end subroutine test_dftd4_pbc
