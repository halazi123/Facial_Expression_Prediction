%Kaggle usernames: halazi, Yufeng

% kNN classifier -- predicts the majority vote among the k-nearest neighbors
function [test_prediction] = knnclassifier(tr_images, tr_labels, test_images)

KNN = 5;
% Reshape into vectors
ntr = size(tr_images, 3);
ntest = size(test_images, 3);
h = size(tr_images,1);
w = size(tr_images,2);
tr_images = double(reshape(tr_images, [h*w, ntr]));
test_images = double(reshape(test_images, [h*w, ntest]));

% Subtract mean for each image
tr_mu = mean(tr_images);
test_mu = mean(test_images);
tr_images = bsxfun(@minus, tr_images, tr_mu);
test_images = bsxfun(@minus, test_images, test_mu);

% Normalize variance for each image
tr_sd = var(tr_images);
tr_sd = tr_sd + 0.01; % for extreme cases
tr_sd = sqrt(tr_sd);
tr_images = bsxfun(@rdivide, tr_images, tr_sd);  

test_sd = var(test_images);
test_sd = test_sd + 0.01; % for extreme cases
test_sd = sqrt(test_sd);
test_images = bsxfun(@rdivide, test_images, test_sd);  

tr_images(1:32,:) = 999;
tr_images(993:end,:) = 999;
test_images(1:32,:) = 999;
test_images(993:end,:) = 999;
for n = 0:31
	b = (n < 5) | (n > 26);
	if b
		head = 32 * n + 11;
		tail = head + 21;
		tr_images(head:tail,:) = 999;
		test_images(head:tail,:) = 999;
	end
	b = (n >= 15) & (n <= 19);
	if b
		head = 32 * n + 1;
		tail = head + 11;
		tr_images(head:tail,:) = 999;
		test_images(head:tail,:) = 999;		
	end
	head = 32 * n + 12;
	tail = head + 3;
	tr_images(head:tail,:) = 999;
	test_images(head:tail,:) = 999;	
end
tr_images(any(tr_images' == 999),:) = [];
test_images(any(test_images' == 999),:) = [];


test_prediction = zeros(ntest, 1);

% Compute pairwise distances and sort them
D = distMat(tr_images, test_images);
[sD knn_ids] = sort(D, 1);

% Perform kNN voting
err = 0;
for (i=1:ntest)
  k = KNN;
  while(true)
    l = hist(tr_labels(knn_ids(1:k,i)), double(1:7));
    [s sid] = sort(l, 'descend');
    lbest = sid(1);
    if (s(1) > s(2) || k == ntr)
      break;
    else % break ties by increasing k in kNN
      k = k+1;
    end
  end

  test_prediction(i) = lbest;
end
save('test.mat', 'test_prediction');
