% ����γ����������ںϼ��ٶȼƺ������ǵ����ݼ�����̬�ǵ�
% ʹ���ݶ��½������������ݽ���У׼��Ȼ�����ɽ��ٶȼ�����̬��
% ����Ҫ����sensor��������һ��N��6�еľ��󣬷ֱ���gyrox,gyroy,gyroz,accx,accy,accz
% �����ǵĵ�λ��rad/s�����ٶȵĵ�λ��9.8m/s?���������ٶȼ�ˮƽʱ��Z����ٶ�Ϊ9.8m/s?������accz=1��
% ������������ǵ�У��ֵ�����result�е�ǰ����
% �������û�����ݣ������Լ��������ݣ�Ȼ���������
% ˼·��Ϲ�����������ݣ�ʹ����Ԫ��΢�ַ���������Ԫ�����ڴ���Ԫ���ó���ת����ͨ����ת����ֱ������ٶȾͿ�����
IMU_Dt=0.01;  
gradientAngle=zeros(size(sensor,1),3);
gradientQuat=zeros(size(sensor,1),4);
gradientQuat(:,1)=1;
for i = 2:size(sensor,1)
    q0=gradientQuat(i-1,1);
    q1=gradientQuat(i-1,2);
    q2=gradientQuat(i-1,3);
    q3=gradientQuat(i-1,4);

    gx=sensor(i,1);
    gy=sensor(i,2);
    gz=sensor(i,3);
    ax=sensor(i,4);
    ay=sensor(i,5);
    az=sensor(i,6);


    %���ٶ�ģ��
    Gyro_Length=sqrt(gx*gx+gy*gy+gz*gz)*57.3;%��λdeg/s

    %��Ԫ��΢�ַ��̼��㱾�δ�������Ԫ�� 
    qDot1 = 0.5 * (-q1*gx - q2*gy - q3*gz);
    qDot2 = 0.5 * (q0*gx + q2*gz - q3*gy);
    qDot3 = 0.5 * (q0*gy - q1*gz + q3*gx);
    qDot4 = 0.5 * (q0*gz + q1*gy - q2*gx);

    %���ٶȼ������Чʱ,���ü��ٶȼƲ��������� 
    if(ax*ay*az==0)
     return
    end 

    Anorm=sqrt(ax * ax + ay * ay + az * az);
    ax = ax/Anorm;
    ay = ay/Anorm;
    az = az/Anorm;
    % �����ظ����� 
    m2q0 = 2.0 * q0;
    m2q1 = 2.0 * q1;
    m2q2 = 2.0 * q2;
    m2q3 = 2.0 * q3;
    m4q0 = 4.0 * q0;
    m4q1 = 4.0 * q1;
    m4q2 = 4.0 * q2;
    m8q1 = 8.0 * q1;
    m8q2 = 8.0 * q2;
    q0q0 = q0*q0;
    q1q1 = q1*q1 ;
    q2q2 = q2*q2;
    q3q3 = q3*q3;

    %�ݶ��½��㷨,�����������ݶ� 
    s0 = m4q0 * q2q2 + m2q2 * ax + m4q0 * q1q1 - m2q1 * ay;
    s1 = m4q1 * q3q3 - m2q3 * ax + 4.0 * q0q0 *q1 - m2q0 * ay - m4q1 + m8q1 * q1q1 + m8q1 * q2q2 + m4q1 * az;
    s2 = 4.0 * q0q0 * q2 + m2q0 * ax + m4q2 * q3q3 - m2q3 * ay - m4q2 + m8q2 * q1q1 + m8q2 * q2q2 + m4q2 * az;
    s3 = 4.0 * q1q1 * q3 - m2q1 * ax + 4.0 * q2q2 *q3 - m2q2 * ay;

    % �ݶȹ�һ��
    Snorm=sqrt(s0 * s0 + s1 * s1 + s2 * s2 + s3 * s3);
    s0 = s0 /Snorm;
    s1 = s1 /Snorm;
    s2 = s2 /Snorm;
    s3 = s3 / Snorm;

    BETADEF=IMU_Dt+0.01*Gyro_Length*IMU_Dt;
    qDot1 = qDot1 - BETADEF * s0;
    qDot2 = qDot2 - BETADEF * s1;
    qDot3 = qDot3 - BETADEF * s2;
    qDot4 = qDot4 - BETADEF * s3;

    % ��������Ԫ��΢�ַ����������̬��� */
    %����Ԫ����̬��������,�õ���ǰ��Ԫ����̬ */
    %���ױϿ����΢�ַ��� */
    delta = (IMU_Dt * gx) * (IMU_Dt * gx) + (IMU_Dt * gy) * (IMU_Dt * gy) + (IMU_Dt * gz) * (IMU_Dt * gz);
    q_out1 = (1.0 - delta / 8.0) * q0 + qDot1 * IMU_Dt;
    q_out2 = (1.0 - delta / 8.0) * q1 + qDot2 * IMU_Dt;
    q_out3 = (1.0 - delta / 8.0) * q2 + qDot3 * IMU_Dt;
    q_out4 = (1.0 - delta / 8.0) * q3 + qDot4 * IMU_Dt;
    %��λ����Ԫ�� */
    recipNorm=1/sqrt(q_out1 * q_out1 + q_out2 * q_out2 + q_out3 * q_out3 + q_out4 * q_out4);
    q_out1 = q_out1*recipNorm;
    q_out2 = q_out2*recipNorm;
    q_out3 = q_out3*recipNorm;
    q_out4 = q_out4*recipNorm;
    
    gradientQuat(i,1)=q_out1;
    gradientQuat(i,2)=q_out2;
    gradientQuat(i,3)=q_out3;
    gradientQuat(i,4)=q_out4;
end
%����Ԫ��������Ƕ�
for i = 1:size(sensor,1)
    q0=gradientQuat(i,1);
    q1=gradientQuat(i,2);
    q2=gradientQuat(i,3);
    q3=gradientQuat(i,4);
    %roll
    gradientAngle(i,2)= 57.3*atan2(2 * (q2*q3 + q0*q1), q0*q0 - q1*q1 - q2*q2 + q3*q3);
    %pitch
    gradientAngle(i,1)=57.3* asin(-2 * (q1*q3 - q0*q2));
    %yaw
    gradientAngle(i,3) = 57.3*atan2(2 * (q1*q2 + q0*q3), q0*q0 + q1*q1 - q2*q2 - q3*q3);
 end
%ɾ���м���������ֹ����������
clear Anorm ax ay az BETADEF delta gx gy gz Gyro gz i IMU_Dt
clear Gyro_Length m2q0 m2q1  m2q2  m2q3  m4q0 m4q1 m4q2 m4q3 m8q0 m8q1  m8q2
clear q0 q0q0 q1 q1q1 q2 q2q2 q3 q3q3 q_out1 q_out2 q_out3 q_out4
clear qDot1 qDot2 qDot3 qDot4 recipNorm result s0 s1 s2 s3 Snorm

