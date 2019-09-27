% ����γ����������ںϼ��ٶȼƺ������ǵ����ݼ�����̬�ǵ�
% ʹ�û����˲������������ݽ���У׼��Ȼ�����ɽ��ٶȼ�����̬��
% ����Ҫ����sensor��������һ��N��6�еľ��󣬷ֱ���gyrox,gyroy,gyroz,accx,accy,accz
% �����ǵĵ�λ��rad/s�����ٶȵĵ�λ��9.8m/s?���������ٶȼ�ˮƽʱ��Z����ٶ�Ϊ9.8m/s?������accz=1��
% ������������ǵ�У��ֵ�����result�е�ǰ����
% �������û�����ݣ������Լ��������ݣ�Ȼ���������
% ˼·��Ϲ�����������ݣ�ʹ����Ԫ��΢�ַ���������Ԫ�����ڴ���Ԫ���ó���ת����ͨ����ת����ֱ������ٶȾͿ�����
dt=0.01;  
Kp=1;
Ki=0;
halfT=0.5*dt;
mahonyAngle=zeros(size(sensor,1),3);
mahonyQuat=zeros(size(sensor,1),4);
mahonyQuat(:,1)=1;
exInt=0;
eyInt=0;
ezInt=0;
for i = 2:size(sensor,1)
    q0=mahonyQuat(i-1,1);
    q1=mahonyQuat(i-1,2);
    q2=mahonyQuat(i-1,3);
    q3=mahonyQuat(i-1,4);

    gx=sensor(i,1);
    gy=sensor(i,2);
    gz=sensor(i,3);
    ax=sensor(i,4);
    ay=sensor(i,5);
    az=sensor(i,6);
    norm = sqrt(ax*ax + ay*ay + az*az);      
    ax = ax /norm;
    ay = ay / norm;
    az = az / norm;	

    vx = 2*(q1*q3 - q0*q2);											
    vy = 2*(q0*q1 + q2*q3);
    vz = q0*q0 - q1*q1 - q2*q2 + q3*q3 ;

    ex = (ay*vz - az*vy) ;                           				
    ey = (az*vx - ax*vz) ;
    ez = (ax*vy - ay*vx) ;
    
    exInt = exInt + ex * Ki;							
    eyInt = eyInt + ey * Ki;
    ezInt = ezInt + ez * Ki;

    gx = gx + Kp*ex + exInt;					   						
    gy = gy + Kp*ey + eyInt;
    gz = gz + Kp*ez + ezInt;				   						

    q_out1 = q0 + (-q1*gx - q2*gy - q3*gz)*halfT;
    q_out2 = q1 + (q0*gx + q2*gz - q3*gy)*halfT;
    q_out3 = q2 + (q0*gy - q1*gz + q3*gx)*halfT;
    q_out4 = q3 + (q0*gz + q1*gy - q2*gx)*halfT;

    norm = sqrt(q_out1*q_out1 + q_out2*q_out2 + q_out3*q_out3 + q_out4*q_out4);

    q_out1 = q_out1 / norm;
    q_out2 = q_out2 / norm;
    q_out3 = q_out3 / norm;
    q_out4 = q_out4 / norm;
    mahonyQuat(i,1)=q_out1;
    mahonyQuat(i,2)=q_out2;
    mahonyQuat(i,3)=q_out3;
    mahonyQuat(i,4)=q_out4;
end
%����Ԫ��������Ƕ�
for i = 1:size(sensor,1)
    q0=mahonyQuat(i,1);
    q1=mahonyQuat(i,2);
    q2=mahonyQuat(i,3);
    q3=mahonyQuat(i,4);
    %roll
    mahonyAngle(i,2)= 57.3*atan2(2 * (q2*q3 + q0*q1), q0*q0 - q1*q1 - q2*q2 + q3*q3);
    %pitch
    mahonyAngle(i,1)=57.3* asin(-2 * (q1*q3 - q0*q2));
    %yaw
    mahonyAngle(i,3) = 57.3*atan2(2 * (q1*q2 + q0*q3), q0*q0 + q1*q1 - q2*q2 - q3*q3);
end
%ɾ���м���������ֹ����������
clear  ax ay az dt ex exInt ey eyInt ez ezInt gx gy gz halfT i Ki Kp norm
clear q0 q1 q2 q3  q_out1 q_out2 q_out3 q_out4 qDot1 qDot2 qDot3 qDot4
clear vx vy vz

