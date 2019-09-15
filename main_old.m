[x,fs]= audioread('box_of_chocolates_x.wav');

x = mean(x, 2); % mono
x = x/max(abs(x));
%x_hf=filter([1 -0.9375],1,x);
[A,G,Err]= my_encode(x,fs,48);

thresh = 0.03;
F=pitchdetect(Err,thresh);
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
encoded_vector = [A G F];
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
%encryption done
temp_enc_vector=encrypted_vector;
Aen= temp_enc_vector(:,1:end-2);
Gen= temp_enc_vector(:,end-1);
Fen= temp_enc_vector(:,end);
encr_x=decode(Aen,[Gen Fen], fs,0/(fs));
%encr_x=filter(1,[1 -0.9375],encr_x);
encr_x = encr_x/max(abs(encr_x));
esxf = fft(encr_x);
esxf(1) = 0;
xencr= ifft(esxf);%decode encrypted vector

%noisy_encrypted_vector=encrypted_vector+ 0.5*std(encrypted_vector).*randn(size(encrypted_vector));
%decryption and decoding
decrypted_vector=filter(fliplr(den./num(end)),fliplr(num./num(end)),encrypted_vector,[],2);
Adec= decrypted_vector(:,1:end-2);
Gdec= decrypted_vector(:,end-1);
Fdec= decrypted_vector(:,end);
decr_x=decode(Adec,[Gdec Fdec], fs,0/(fs));
%decr_x=filter(1,[1 -0.9375],decr_x);
decr_x = decr_x/max(abs(decr_x));
esxf = fft(decr_x);
esxf(1) = 0;
xndr = ifft(esxf);

figure(1);
subplot(2,2,1);
plot(abs(fft(x)));
title('Original');
% subplot(2,2,2);
% plot(abs(fft(xnew)));
% label('Transmitted without encryption');
subplot(2,2,3);
plot(abs(fft(xencr)));
title('Encrypted');
subplot(2,2,4);
plot(abs(fft(xndr)));
title('Decrypted');

%sound(x,fs);
%sound(xnew,fs);
%sound(xencr,fs);
%sound(xndr, fs);



