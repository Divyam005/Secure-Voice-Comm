[x,fs]= audioread('got_s2e1_night_is_dark.wav');

x = mean(x, 2); % mono
x = x/max(abs(x));
%x_hf=filter([1 -0.9375],1,x);
[A,G,Err]= my_encode(x,fs,48);

F=pitchdetect(Err,0.01);
%F = zeros(size(F));
est_x=decode(A,[G F], fs,0/(fs));
f = fcombine(F,fs);
%est_x=filter(1,[1 -0.9375],est_x);
est_x = est_x/max(abs(est_x));
esxf = fft(est_x);
esxf(1) = 0;
xnew = ifft(esxf);
%compression done

%designing filter for encryption
encoded_vector = [A G 0.01*F];


% a_ = 1.2;
% b_ = 0.8;
% x_ = [0.1];
% y_ = [0.1];
% 
% for i = 1:size(encoded_vector, 1)*size(encoded_vector, 2)-1
%     x_ = [x_ (1+a_*b_)*x_(i)-b_*x_(i)*y_(i)];
%     y_ = [y_ (1-b_)*y_(i)+b_*x_(i)*x_(i)];
% end 

%designing filter for encryption
%encoded_vector = [A G F];
z_re = randn(16,1);
Z_re= [z_re;z_re];
z_im = randn(16,1);
Z_im = [z_im ;-1*z_im];
Z = Z_re+ Z_im*1i;
Z= Z./(min(abs(Z)));
H = zpk(Z,[],1, []);
[num,den,Ts]=tfdata(H);
num = cell2mat(num);
den = cell2mat(den);
encrypted_vector = filter(fliplr(num),fliplr(den),encoded_vector,[],2);

a_ = 3.8;
b_ = 0.05;
c_ = 0.35;
d_ = 3.78;
e_ = 0.2;
f_ = 0.1;
g_ = 1.9;
x_ = [0.1];
y_ = [0.1];
z_ = [0];
for i = 1:size(encrypted_vector, 1)*size(encrypted_vector, 2)-1
     x_ = [x_ a_*x_(i)*(1-x_(i))-b_*(z_(i)+c_)*(1-2*y_(i))];
     y_ = [y_ d_*y_(i)*(1-y_(i))+e_*z_(i)];
     z_ = [z_ f_*((z_(i)+c_)*(1-2*y_(i))-1)*(1-g_*(x_(i)))];
end 



x_ = reshape(x_, (size(encoded_vector)));
encrypted_vector = 1e-15*encrypted_vector+100*x_;
%encryption done
temp_enc_vector=encrypted_vector;
Aen= temp_enc_vector(:,1:end-2);
Gen= temp_enc_vector(:,end-1);
Fen= 100*temp_enc_vector(:,end);
encr_x=decode(Aen,[Gen Fen], fs,0/(fs));
%encr_x=filter(1,[1 -0.9375],encr_x);
encr_x = encr_x/max(abs(encr_x));
esxf = fft(encr_x);
esxf(1) = 0;
xencr= ifft(esxf);
%decode encrypted vector

%noisy_encrypted_vector=encrypted_vector+ 0.5*std(encrypted_vector).*randn(size(encrypted_vector));
%decryption and decoding


decrypted_vector=(encrypted_vector - 100*x_)*1e15;

decrypted_vector=filter(fliplr(den./num(end)),fliplr(num./num(end)),decrypted_vector,[],2);
Adec= decrypted_vector(:,1:end-2);
Gdec= decrypted_vector(:,end-1);
Fdec= 100*decrypted_vector(:,end);
decr_x=decode(Adec,[Gdec Fdec], fs,0/(fs));
%decr_x=filter(1,[1 -0.9375],decr_x);
decr_x = decr_x/max(abs(decr_x));
esxf = fft(decr_x);
esxf(1) = 0;
xndr = ifft(esxf);

figure(1);
subplot(1,2,1);
plot(abs(fft(x)));
title('Original FFT');
% subplot(2,2,2);
% plot(abs(fft(xnew)));
% label('Transmitted without encryption');
% subplot(1,3,2);
% plot(abs(fft(xencr)));
% title('Encrypted');
subplot(1,2,2);
plot(abs(fft(xndr)));
title('Decrypted FFT');

figure(2);
subplot(2,1,1);
encodet = encoded_vector';
plot(encodet(:));
title('Encoded vector');
subplot(2,1,2);
encryptt = encrypted_vector';
plot(encryptt(:));
title('Encrypted vector');

%sound(x,fs);
%sound(xnew,fs);
%sound(xencr,fs);
%sound(xndr, fs);



