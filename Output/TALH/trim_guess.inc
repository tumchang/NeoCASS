$
$ SPEEDS (EAS):
$ - Maneuvering          VA:  121.368 [m/s].
$ - Rough air            VB:  86.6144 [m/s].
$ - Design cruise        VC:  127.5 [m/s].
$ - Design dive          VD:  159.375 [m/s].
$ - Stall clean conf.    VS:  76.7599 [m/s].
$ - Stall landing conf. VFLAND: 57.1178 [m/s].
$      Percentage MTOW used: 79.1%
$ - Flap design          VF:  112.115 [m/s].
$
$ MACH:
$ - Design cruise MMO:  0.696.
$ - Design dive    MD:  0.87.
$
$ LOAD FACTORS:
$ - Max nz: 2.5.
$ - Min nz: -1.
$
$ REFERENCE DATA used:
$ - Design weight: 2.31592e+06 [N]
$ - Reference surface: 366.7 [m^2]
$ - Reference chord: 6.32241 [m]
$ - Reference span: 58 [m]
$ - Max ceiling altitude: 13106 [m]
$ - User-defined reference surface for CLMAX, CLMAXLAND, CLALPHAD: 366.7 [m^2]
$
TRIM=   1
$ Sec. 25.331
$ Maximum load factor at VD, nz = 2.5, z=0m
$ VD: 159.343 m/s
$ Determine pitch control and angle of attack
TRIM    1       1       0.4683080.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.001832YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   24.525  aileronr0       
        flap1r  0       flap2r  0       rudder1 0       
TRIM=   2
$ Sec. 25.331
$ Maximum load factor at VD, nz = 2.5, z=9310m
$ VD: 263.17 m/s
$ Determine pitch control and angle of attack
TRIM    2       1       0.8700879310    SIDES   0.0     ROLL    0.0     
        PITCH   0.000671YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   24.525  aileronr0       
        flap1r  0       flap2r  0       rudder1 0       
TRIM=   3
$ Sec. 25.331
$ Maximum load factor at VC, nz = 2.5, z=0m
$ VC: 127.474 m/s
$ Determine pitch control and angle of attack
TRIM    3       1       0.3746460.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.002862YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   24.525  aileronr0       
        flap1r  0       flap2r  0       rudder1 0       
TRIM=   4
$ Sec. 25.331
$ Maximum load factor at VC, nz = 2.5, z=9310m
$ VC: 210.536 m/s
$ Determine pitch control and angle of attack
TRIM    4       1       0.69607 9310    SIDES   0.0     ROLL    0.0     
        PITCH   0.001049YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   24.525  aileronr0       
        flap1r  0       flap2r  0       rudder1 0       
TRIM=   5
$ Sec. 25.345 a1
$ Cruise at VF = max(1.6 VFTO, 1.8 VFLAND), nz = 2, z=0m
$ Determine pitch control and angle of attack
TRIM    5       1       0.3294590.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.002467YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   19.62   aileronr0       
        flap1r  25      flap2r  25      rudder1 0       
TRIM=   6 
$ Sec. 25.345 a2
$ Gust for Landing conf. at VF = max(1.6 VFTO, 1.8 VFLAND), z=0m
$  VF: 112.115 m/s
$  VFTO: 70.0719 m/s
$ VFLAND: 57.1178 m/s
$ Determine pitch control and angle of attack
TRIM    6       1       0.3294590.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   9.81    VGUST   7.6225  
        aileronr0       flap1r  25      flap2r  25      rudder1 0       
TRIM=   7
$ Sec. 25.331 b1
$ Sudden aft movement of pitch control at VA=sqrt(nmax) * VS , z=0m
$  VA: 121.368 m/s
$  VS: 76.7599 m/s
$ Determine pitch control and angle of attack
$ Check control deflection is between -25 and 25
TRIM    7       1       0.35665 0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     BANK    0.0     URDD6   0.0     CLIMB   0.0     
        HEAD    0.0     URDD3   9.81    URDD5   0.413274aileronr0       
        flap1r  0       flap2r  0       rudder1 0       
TRIM=   8
$ Sec. 23.331 b1
$ Sudden aft movement of pitch control at VC, z=0m
$  VC: 127.474 m/s
$ Determine pitch control and angle of attack
$ Check control deflection is between -25 and 25
TRIM    8       1       0.3746460.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     BANK    0.0     URDD6   0.0     CLIMB   0.0     
        HEAD    0.0     URDD3   9.81    URDD5   0.393398aileronr0       
        flap1r  0       flap2r  0       rudder1 0       
TRIM=   9
$ Sec. 23.331 b1
$ Sudden aft movement of pitch control at VD, z=0m
$  VD: 159.343 m/s
$ Determine pitch control and angle of attack
$ Check control deflection is between -25 and 25
TRIM    9       1       0.4683080.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     BANK    0.0     URDD6   0.0     CLIMB   0.0     
        HEAD    0.0     URDD3   9.81    URDD5   0.314719aileronr0       
        flap1r  0       flap2r  0       rudder1 0       
TRIM=   10
$ Sec. 25.331 b1
$ Sudden aft movement of pitch control at VA=sqrt(nmax) * VS , z=0m
$  VA: 121.368 m/s
$  VS: 76.7599 m/s
$ Determine pitch control and angle of attack
$ Check control deflection is between -25 and 25
TRIM    10      1       0.35665 0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     BANK    0.0     URDD6   0.0     CLIMB   0.0     
        HEAD    0.0     URDD3   24.525  URDD5   -0.41327aileronr0       
        flap1r  0       flap2r  0       rudder1 0       
TRIM=   11
$ Sec. 23.331 b1
$ Sudden aft movement of pitch control at VC, z=0m
$  VC: 127.474 m/s
$ Determine pitch control and angle of attack
$ Check control deflection is between -25 and 25
TRIM    11      1       0.3746460.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     BANK    0.0     URDD6   0.0     CLIMB   0.0     
        HEAD    0.0     URDD3   24.525  URDD5   -0.39339aileronr0       
        flap1r  0       flap2r  0       rudder1 0       
TRIM=   12
$ Sec. 23.331 b1
$ Sudden aft movement of pitch control at VD, z=0m
$  VD: 159.343 m/s
$ Determine pitch control and angle of attack
$ Check control deflection is between -25 and 25
TRIM    12      1       0.4683080.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     BANK    0.0     URDD6   0.0     CLIMB   0.0     
        HEAD    0.0     URDD3   24.525  URDD5   -0.31471aileronr0       
        flap1r  0       flap2r  0       rudder1 0       
TRIM=   13
$ Sec. 25.351 a
$ Sideslip maneuver at max rudder deflection at VA=sqrt(nmax) * VS, z=0m
$  VA: 121.368 m/s
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    13      0       0.35665 0.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   0.0     THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 30      
TRIM=   14
$ Sec. 25.351 b
$ Sideslip maneuver at overswing sideslip angle 22.5 deg at VA=sqrt(nmax) * VS, z=0m
$  VA: 121.368 m/s
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    14      0       0.35665 0.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   22.5    THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 30      
TRIM=   15
$ Sec. 25.351 c
$ Sideslip maneuver at sideslip angle 15 at VA=sqrt(nmax) * VS, z=0m
$  VA: 121.368 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    15      0       0.35665 0.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   15      THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 0       
TRIM=   16
$ Sec. 25.351 a
$ Sideslip maneuver at max rudder deflection at VS, z=0m
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    16      0       0.2255650.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   0.0     THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 30      
TRIM=   17
$ Sec. 25.351 b
$ Sideslip maneuver at overswing sideslip angle 22.5 deg at VS, z=0m
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    17      0       0.2255650.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   22.5    THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 30      
TRIM=   18
$ Sec. 25.351 c
$ Sideslip maneuver at sideslip angle 15 at VS, z=0m
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    18      0       0.2255650.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   15      THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 0       
TRIM=   19
$ Sec. 25.351 a
$ Sideslip maneuver at max rudder deflection at VA=sqrt(nmax) * VS, z=0m
$  VA: 121.368 m/s
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    19      0       0.35665 0.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   0.0     THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 -30     
TRIM=   20
$ Sec. 25.351 b
$ Sideslip maneuver at overswing sideslip angle -22.5 deg at VA=sqrt(nmax) * VS, z=0m
$  VA: 121.368 m/s
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    20      0       0.35665 0.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   -22.5   THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 -30     
TRIM=   21
$ Sec. 25.351 c
$ Sideslip maneuver at sideslip angle -15 at VA=sqrt(nmax) * VS, z=0m
$  VA: 121.368 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    21      0       0.35665 0.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   -15     THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 0       
TRIM=   22
$ Sec. 25.351 a
$ Sideslip maneuver at max rudder deflection at VS, z=0m
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    22      0       0.2255650.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   0.0     THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 -30     
TRIM=   23
$ Sec. 25.351 b
$ Sideslip maneuver at overswing sideslip angle -22.5 deg at VS, z=0m
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    23      0       0.2255650.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   -22.5   THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 -30     
TRIM=   24
$ Sec. 25.351 c
$ Sideslip maneuver at sideslip angle -15 at VS, z=0m
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    24      0       0.2255650.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   -15     THRUST  0.0     
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr0       flap1r  0       flap2r  0       rudder1 0       
TRIM=   25
$ Sec. 23.349
$ Aileron abrupt maximum deflection at VA=sqrt(nmax) * VS, z=0m
$  VA: 121.368 m/s
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    25      0       0.35665 0.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   0.0     THRUST  0.0
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   9.81    
        aileronr20      flap1r  0       flap2r  0       rudder1 0       
TRIM=   26
$ Sec. 25.349
$ Aileron abrupt deflection + 2/3 max load factor at VA=sqrt(nmax) * VS, z=0m
$  VA: 121.368 m/s
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    26      0       0.35665 0.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.001403YAW     0.0     SIDES   0.0     THRUST  0.0
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   16.35   
        aileronr20      flap1r  0       flap2r  0       rudder1 0       
TRIM=   27
$ Sec. 23.349
$ Aileron abrupt maximum deflection at VA=sqrt(nmax) * VS, z=0m
$  VA: 121.368 m/s
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    27      0       0.35665 0.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     SIDES   0.0     THRUST  0.0
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   16.35   
        aileronr-20     flap1r  0       flap2r  0       rudder1 0       
TRIM=   28
$ Sec. 25.349
$ Aileron abrupt deflection + 2/3 max load factor at VA=sqrt(nmax) * VS, z=0m
$  VA: 121.368 m/s
$  VS: 76.7599 m/s
$ Determine pitch control, angle of attack, lateral acceleration, roll and yaw accelerations
TRIM    28      0       0.35665 0.0     HEAD    0.0     ROLL    0.0     
        PITCH   0.001403YAW     0.0     SIDES   0.0     THRUST  0.0
        BANK    0.0     CLIMB   0.0     URDD5   0.0     URDD3   16.35   
        aileronr20      flap1r  0       flap2r  0       rudder1 0       
$TRIM=  101
$Trim for GUST
$ Determine pitch control and angle of attack
$TRIM    101     1       0.4     0.0     SIDES   0.0     ROLL    0.0     
$        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
$        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
$        BANK    0.0     HEAD    0.0     URDD3   9.81    aileronr0       
$        flap1r  0       flap2r  0       rudder1 0       

ITRIM= 1       
ITRIM= 2       
ITRIM= 3       
ITRIM= 4       
ITRIM= 5       
ITRIM= 5       
ITRIM= 6       
ITRIM= 3       
ITRIM= 1       
ITRIM= 6       
ITRIM= 3       
ITRIM= 1       
ITRIM= 6       
ITRIM= 6       
ITRIM= 6       
ITRIM= 7       
ITRIM= 7       
ITRIM= 7       
ITRIM= 6       
ITRIM= 6       
ITRIM= 6       
ITRIM= 7       
ITRIM= 7       
ITRIM= 7       
ITRIM= 6       
ITRIM= 6       
ITRIM= 6       
ITRIM= 6       