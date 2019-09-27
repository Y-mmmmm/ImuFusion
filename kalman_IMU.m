% ����γ����������ںϼ��ٶȼƺ������ǵ����ݼ�����̬�ǵ�
% ʹ�ÿ������˲������������ݽ���У׼��Ȼ�����ɽ��ٶȼ�����̬��
% ����Ҫ����sensor��������һ��N��6�еľ��󣬷ֱ���gyrox,gyroy,gyroz,accx,accy,accz
% �����ǵĵ�λ��rad/s�����ٶȵĵ�λ��9.8m/s?���������ٶȼ�ˮƽʱ��Z����ٶ�Ϊ9.8m/s?������accz=1��
% ������������ǵ�У��ֵ�����result�е�ǰ����
% �������û�����ݣ������Լ��������ݣ�Ȼ���������
% ˼·��Ϲ�����������ݣ�ʹ����Ԫ��΢�ַ���������Ԫ�����ڴ���Ԫ���ó���ת����ͨ����ת����ֱ������ٶȾͿ�����

%���ɵ�λ����
E=eye(6);
%Э�������
P=[10    0   0   0   0   0
    0    10   0   0   0   0
    0    0   10   0   0   0
    0    0   0   10   0   0
    0    0   0   0   10   0
    0    0   0   0   0   10];
dt=0.01;%100Hz,dtΪ�������ݵ�ʱ����
% XΪ���Ź��ƽ⣬�����������,���ϵ���������wx,wy,wz,ax,ay,az��
% w������ٶȣ���λrad/s��aΪ��λ���ٶȣ���λΪ 9.8m/s?
X=[0;0;0;0;0;1];


%ϵͳת�ƹ�������
Q=[0.01    0    0       0       0       0
   0     0.01   0       0       0       0
   0       0    0.01    0       0       0
   0       0    0       0.01    0       0
   0       0    0       0       0.01    0
   0       0    0       0       0       0.01 ];

%��������
R=[0.1    0    0       0        0       0
   0     0.1   0       0        0       0
   0      0    0.1     0        0       0
   0      0    0       10       0       0
   0      0    0       0        10      0
   0      0    0       0        0       10 ];

%��������
H=[1      0     0       0        0       0
   0      1     0       0        0       0
   0      0     1       0        0       0
   0      0     0       1        0       0
   0      0     0       0        1       0
   0      0     0       0        0       1 ];

%����ֵ
Z=[0;0;0;0;0;1];

%��Ҫ�����ݵ���sensor,1-6�зֱ�Ϊgx,gy,gz,ax,ay,az
n=size(sensor,1);%��sensor���������
result=zeros(n,6);
for i =1:n
    % AΪ״̬ת�ƾ���ʵ�ʵ�ϵͳΪ������
    A=[1            0           0               0               0               0
       0            1           0               0               0               0
       0            0           1               0               0               0
       0           -X(6,1)*dt   X(5,1)*dt       1            X(3,1)*dt       -X(2,1)*dt
      X(6,1)*dt    0            -X(4,1)*dt   -X(3,1)*dt           1            X(1,1)*dt 
      -X(5,1)*dt   X(4,1)*dt    0            X(2,1)*dt        -X(1,1)*dt        1        ];
    %�ѵ�ǰʱ�̵Ĺ۲�ֵ���뵽�۲����Z��
    Z=sensor(i,1:6)';
    %���㵱ǰʱ��X�Ĺ���ֵ
    X_predict=A*X;
    %���㵱ǰʱ��Э�������P�Ĺ���ֵ
    P_predict=A'*P*A+Q;
    %���㿨�������棬����ĳ��������ڳ��Ծ���������
    K=H'*P_predict/(H*P_predict*H'+R);
    %�������Ź��ƽ�
    X=X_predict+K*(Z-H*X_predict); 
    %�������Ź��ƽ��Ӧ��Э�������P
    P=(E-K*H)*P_predict;  
    %�Լ��ٶȽ��е�λ��
    accNorm=X(4,1)^2+X(5,1)^2+X(6,1)^2;
    accNorm=accNorm^0.5;
    X(4,1)=X(4,1)/accNorm;
    X(5,1)=X(5,1)/accNorm;
    X(6,1)=X(6,1)/accNorm;
    %���ƽ����result����
    result(i,:)=X';
end

kalmanQuat=zeros(n,4);
kalmanQuat(:,1)=1;
kalmanAngles=zeros(n,3);
%ͨ����Ԫ��΢�ַ��̽�����̬
for i =1:n-1
          qDot1 =  kalmanQuat(i,1)+0.5 * dt*(-kalmanQuat(i,2)*result(i,1) - kalmanQuat(i,3)*result(i,2) - kalmanQuat(i,4)*result(i,3));
          qDot2 =  kalmanQuat(i,2)+0.5 * dt*(kalmanQuat(i,1)*result(i,1) + kalmanQuat(i,3)*result(i,3) - kalmanQuat(i,4)*result(i,2));
          qDot3 =  kalmanQuat(i,3)+0.5 * dt*(kalmanQuat(i,1)*result(i,2) - kalmanQuat(i,2)*result(i,3) + kalmanQuat(i,4)*result(i,1));
          qDot4 =  kalmanQuat(i,4)+0.5 * dt*(kalmanQuat(i,1)*result(i,3) + kalmanQuat(i,2)*result(i,2) - kalmanQuat(i,3)*result(i,1));
          
          quatNorm=qDot1^2+qDot2^2+qDot3^2+qDot4^2;
          qDot1=qDot1/quatNorm;
          qDot2=qDot2/quatNorm;
          qDot3=qDot3/quatNorm;
          qDot4=qDot4/quatNorm;
          kalmanQuat(i+1,1)=qDot1;
          kalmanQuat(i+1,2)=qDot2;
          kalmanQuat(i+1,3)=qDot3;
          kalmanQuat(i+1,4)=qDot4;
          
          sinr_cosp = (+2.0 * (kalmanQuat(i+1,1) * kalmanQuat(i+1,2) + kalmanQuat(i+1,3) * kalmanQuat(i+1,4)));
          cosr_cosp = (+1.0 - 2.0 * (kalmanQuat(i+1,2) * kalmanQuat(i+1,2) + kalmanQuat(i+1,3) * kalmanQuat(i+1,3)));
          kalmanAngles(i,2) = atan2(sinr_cosp, cosr_cosp);

          sinp = +2.0 * (kalmanQuat(i+1,1) * kalmanQuat(i+1,3) - kalmanQuat(i+1,4)* kalmanQuat(i+1,2));
        if (abs(sinp) >= 1)
            kalmanAngles(i,1) = copysign(3.1415926 / 2, sinp); % ����Ϊ90��
        else
            kalmanAngles(i,1) = asin(sinp);
        end

        % ������
        siny_cosp = +2.0 * (kalmanQuat(i+1,1) * kalmanQuat(i+1,4) + kalmanQuat(i+1,2) * kalmanQuat(i+1,3));
        cosy_cosp = +1.0 - 2.0 * (kalmanQuat(i+1,3) * kalmanQuat(i+1,3) + kalmanQuat(i+1,4) * kalmanQuat(i+1,4)); 
        kalmanAngles(i,1) = kalmanAngles(i,1)*57.3;
        kalmanAngles(i,2) = kalmanAngles(i,2)*57.3;
        kalmanAngles(i,3) = atan2(siny_cosp, cosy_cosp)*57.3;
end
%ɾ���м���������ֹ����������
clear A accNorm c cosr_cosp cosy_cosp dt E H i K n P P_predict
clear Q qDot1 qDot2 qDot3  qDot4 quatNorm R sinp sinr_cosp siny_cosp X X_predict Z



