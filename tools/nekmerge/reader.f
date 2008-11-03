c-----------------------------------------------------------------------
      subroutine rw_param(nelt,nelv,ndim,nelt_all,nelv_all,ifile)
c
c     Read .rea parameters etc. and write out result iff ifile=1
c

      character*80 string
      integer e,f


      if (ifile.eq.1) then
         call scanout(string,'MESH DATA',9,10,11)  ! output to 11
         call lineout(11,string,80)
      else
         call scanout(string,'MESH DATA',9,10, 0)  ! 0 = no output
      endif

      read (10,*)  nelt, ndim, nelv

      nelt_all = nelt_all + nelt
      nelv_all = nelv_all + nelv

      return
      end
c-----------------------------------------------------------------------
      subroutine rd_xyz (x,y,z,nel,ndim)
c
      real x(8,nel),y(8,nel),z(8,nel)
      integer e
      character*80 string

      if (ndim.eq.3) then
         do e=1,nel
            read (10,80) string
            read (10,*)   (x(k,e),k=1,4)
            read (10,*)   (y(k,e),k=1,4)
            read (10,*)   (z(k,e),k=1,4)
            read (10,*)   (x(k,e),k=5,8)
            read (10,*)   (y(k,e),k=5,8)
            read (10,*)   (z(k,e),k=5,8)
         enddo
      else
         do e=1,nel
            read (10,80) string
            read (10,*)   (x(k,e),k=1,4)
            read (10,*)   (y(k,e),k=1,4)
         enddo
      endif
   80 format(a80)

      return
      end
c-----------------------------------------------------------------------
      subroutine rd_curve(ncurve,ccurve,curve,nel,nelo,ndim)

      character*1 ccurve  (12,1),cc
      real         curve(6,12,1)
      integer e,f

      real buf(6)

      buf(6) = 0

      read(10,*)
      read(10,*) ncurve
      if (ncurve.gt.0) then
         do icurve=1,ncurve
            if (nel.lt.1000) then
               read(10,60) f,e,(buf(k),k=1,5),cc
            elseif (nel.lt.1000000) then
               read(10,61) f,e,(buf(k),k=1,5),cc
            else
               read(10,62) f,e,(buf(k),k=1,5),cc
            endif
            e = e+nelo
            ccurve(f,e) = cc
            call copy(curve(1,f,e),buf,6)
         enddo
   60    format(i3,i3,5g14.6,1x,a1)
   61    format(i2,i6,5g14.6,1x,a1)
   62    format(i1,i7,5g14.6,1x,a1)
      endif
         
      return
      end
c-----------------------------------------------------------------------
      subroutine rd_bdry(cbc,bc,string,nel,nelo,ndim,nfld,lelt)

      character*3  cbc (6,lelt,nfld) ! note: lelt reqd
      real         bc(5,6,lelt,nfld) ! for memory reasons
      character*80 string
      integer e,f

      call blank(string,80)
      read (10,80) string ! ***** BOUNDARY CONDITIONS *****

      nface = 2*ndim
      do j = 1,nfld
         read (10,80) string
         if (indx1(string,'BOUN',4).ne.0) then ! we might have bcs
            if (indx1(string,'NO ',3).eq.0)  then ! we have bcs, read and count
               do e=1,nel
               do f=1,nface

                  if (nel.lt.1000) then
                     read(10,20) cbc(f,e,j),(bc(k,f,e,j),k=1,5)
                  elseif (nel.lt.100000) then
                     read(10,21) cbc(f,e,j),(bc(k,f,e,j),k=1,5)
                  else
                     read(10,22) cbc(f,e,j),(bc(k,f,e,j),k=1,5)
                  endif
   20             format(1x,a3,6x,5g14.7)
   21             format(1x,a3,6x,5g14.7)
   22             format(1x,a3,7x,5g14.7)


c                 Update E-E and P-P pointers:
c
c                    .Assumes that P-P pointer boundaries are not
c                     eliminated during mesh merge
c
                  if (cbc(f,e,j).eq.'P  '.or.cbc(f,e,j).eq.'E  ')
     $               bc(1,f,e,j) = bc(1,f,e,j) + nelo

               enddo
               enddo

            endif
         else
            goto 51
         endif

      enddo
   51 continue
   80 format(a80)
         
      return
      end
c-----------------------------------------------------------------------
