clear variables;
close all;


%% Settings
file_name = 'video';
figure_width = 950;
figure_height = 750;


%% Read points from svg file
sig = loadSVG('svg/fender_outline.svg');
s = sig{1}.s;
n = sig{1}.n;
t = sig{1}.t;


%% Compute Fourier series
N = ceil(n/2)-1;
f = -N:1:N;
S = zeros(1,length(f));
for k=1:length(f)
	S(k) = 1/n*sum(s.*exp(-1i*2*pi*f(k).*t));
end


%% Plot reconstructed path
fig = figure();
set(fig, 'Position',  [100, 50, figure_width, figure_height])

Ts = 0.004;
tip = [];
frame = 1;
for k = 1:1/Ts-Ts
    % Clear figure
    clf;
    hold on;
    set(gca,'XLim',[-2,2.5],'YLim',[-1.5,2.5]);

    % Plot reference points
    plot(real(s), imag(s),'*');

    % Simulate rotating vectors
    pos = 0;        % Starting point for each vector
    dir = S(N+1);   % Direction of each vector
    for h = 1:N
        % Positive frequency
        p = pos(end);
        v = dir(end);
        pos = [pos, p+v];
        dir = [dir, S(h+N+1)*exp(1i*2*pi*h*(k*Ts))];

        % Negative frequency
        p = pos(end);
        v = dir(end);
        pos = [pos, p+v];
        dir = [dir, S(N+1-h)*exp(1i*2*pi*-h*(k*Ts))];
    end
    tip = [tip, pos(end) + dir(end)];

    % Plot vectors
    quiver(real(pos),imag(pos),real(dir),imag(dir),0,'LineWidth',2)

    % Plot reconstructed path
    plot(real(tip), imag(tip), 'r','LineWidth',3);

    % Draw text
    text(-1.5,2,['N = ', int2str(N*2+1)],'FontSize',14);

    % Save frame
    video(frame) = getframe(fig, [0,0,figure_width,figure_height]);
    frame = frame + 1;
end

% Render video
writer = VideoWriter(file_name, 'MPEG-4');
writer.FrameRate = 12;
open(writer);
writeVideo(writer, video);
close(writer);
