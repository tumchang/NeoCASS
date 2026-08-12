$
$ SPEEDS (EAS):
$ - Maneuvering          VA:  119.526 [m/s].
$ - Rough air            VB:  96.4563 [m/s].
$ - Design cruise        VC:  231.301 [m/s].
$ - Design dive          VD:  289.126 [m/s].
$ - Stall clean conf.    VS:  75.5947 [m/s].
$ - Stall landing conf. VFLAND: 55.5689 [m/s].
$      Percentage MTOW used (equals MLW): 84.615%
$ - Flap design          VF:  109.179 [m/s].
$
$ MACH:
$ - Design cruise MMO:  0.78.
$ - Design dive    MD:  0.89.
$
$ LOAD FACTORS:
$ - Max nz: 2.5.
$ - Min nz: -1.
$
$ REFERENCE DATA used:
$ - Reference surface: 122.4 [m^2]
$ - Reference chord: 3.60927 [m]
$ - Reference span: 33.9127 [m]
$ - Max ceiling altitude: 10668 [m]
$ - User-defined reference surface for CLMAX, CLMAXLAND, CLALPHAD: 122.4 [m^2]
$
$
TRIM=   1
$ CRUISE design conditions 
$nz = 1, z = 10668m
$V:231.301200m/s
$ Determine pitch control and angle of attack
TRIM    1       1       0.78    10668   SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   9.81    aileronr0       
        rudder1 0       
TRIM=   2
$ Sec. 25.331
$ Maximum load factor at VD, nz = 2.5, z=0m
$ VD: 289.01 m/s
$ Determine pitch control and angle of attack
TRIM    2       1       0.5000  0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   24.525  aileronr0       
        rudder1 0       
TRIM=   3
$ Sec. 25.331
$ Maximum load factor at VD, nz = 2.5, z=10668m
$ VD: 300.131 m/s
$ Determine pitch control and angle of attack
TRIM    3       1       0.89    10668   SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   24.525  aileronr0       
        rudder1 0       
TRIM=   4
$ Sec. 25.331
$ Maximum load factor at VC, nz = 2.5, z=0m
$ VC: 231.292 m/s
$ Determine pitch control and angle of attack
TRIM    4       1       0.50    0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   24.525  aileronr0       
        rudder1 0       
TRIM=   5
$ Sec. 25.331
$ Maximum load factor at VC, nz = 2.5, z=2260m (28900 ft)
$ VC: 258.529 m/s
$ Determine pitch control and angle of attack
TRIM    5       1       0.50    2260    SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   24.525  aileronr0       
        rudder1 0       
$
TRIM=   6
$ negative Maneuver, M-, Push down 
$nz = -9.81, z = 10668m
$V_mo:231.301200m/s
$ Determine pitch control and angle of attack
TRIM    6       1       0.78    10668   SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   -9.81   aileronr0       
        rudder1 0       
$
TRIM=   7
$ Sec. 25.331
$ Maximum load factor at VD, nz = -9.81, z=10668m
$ VD: 300.131 m/s
$ Determine pitch control and angle of attack
TRIM    7       1       0.89    10668   SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   -9.81   aileronr0       
        rudder1 0       
TRIM=   8
$ Sec. 25.331
$ Maximum load factor at VC, nz = -9.81, z=0m
$ VC: 231.292 m/s
$ Determine pitch control and angle of attack
TRIM    8       1       0.50    0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   -9.81   aileronr0       
        rudder1 0       
TRIM=   9
$ Sec. 25.331
$ Maximum load factor at VC, nz = -9.81, z=2260m
$ VC: 258.529 m/s
$ Determine pitch control and angle of attack
TRIM    9       1       0.50    2260    SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   -9.81   aileronr0       
        rudder1 0     		
ITRIM= 1       
ITRIM= 2       
ITRIM= 3       
ITRIM= 4       
ITRIM= 5       
ITRIM= 1       
ITRIM= 3       
ITRIM= 4       
ITRIM= 5       