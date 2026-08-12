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
$ ============================== Pull-up ===============================
TRIM=   1
$ Max EAS at sea level
TRIM    1       1       0.380   0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   24.525  aileronr0       
        rudder1 0       
$ ============================= Push-Down ==============================
TRIM=   2
$ Max EAS at sea level
TRIM    2       1       0.380   0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   -9.81   aileronr0       
        rudder1 0       
$ ======================== Abrupt Aileron Deflection ===================
TRIM=   3
$ VA
TRIM    3       1       0.385   0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   16.35   aileronr-20     
        rudder1 0       
TRIM=   4
$ VA
TRIM    4       1       0.385   0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   16.35   aileronr20      
        rudder1 0       
$ ======================= Abrupt Rudder Deflection =====================
TRIM=   5
$ VA
TRIM    5       1       0.385   0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   9.81    aileronr0     
        rudder1 -30     
TRIM=   6
$ VA
TRIM    6       1       0.385   0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   9.81    aileronr0     
        rudder1 30      
$ =============================== SideSlip =============================
TRIM=   7
$ VA
TRIM    7       1       0.385   0.0     SIDES   15      ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   9.81    aileronr0     
        rudder1 0       
TRIM=   8
$ VA
TRIM    8       1       0.385   0.0     SIDES   -15     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   9.81    aileronr0     
        rudder1 0       
$ ================================= SWING ===============================
TRIM=   9
$ VA
TRIM    9       1       0.385   0.0     SIDES   22.5    ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   9.81    aileronr0     
        rudder1 30      
TRIM=   10
$ VA
TRIM    10      1       0.244   0.0     SIDES   22.5    ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     URDD5   0.0     URDD6   0.0     CLIMB   0.0     
        BANK    0.0     HEAD    0.0     URDD3   9.81    aileronr0     
        rudder1 30      
$ ========================= Sudden Pitch Control =======================
TRIM=   11
TRIM    11      1       0.380   0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     BANK    0.0     URDD6   0.0     CLIMB   0.0     
        HEAD    0.0     URDD3   24.525  URDD5   -0.31471aileronr0       
        rudder1 0       
TRIM=   12
TRIM    12      1       0.380   0.0     SIDES   0.0     ROLL    0.0     
        PITCH   0.0     YAW     0.0     URDD2   0.0     THRUST  0.0     
        URDD4   0.0     BANK    0.0     URDD6   0.0     CLIMB   0.0     
        HEAD    0.0     URDD3   9.81    URDD5   0.314719aileronr0       
        rudder1 0       
ITRIM= 1       
ITRIM= 2       
ITRIM= 3       
ITRIM= 4       
ITRIM= 5       
ITRIM= 6       
ITRIM= 7       
ITRIM= 8       
ITRIM= 9       
ITRIM= 10      
ITRIM= 11      
ITRIM= 12      