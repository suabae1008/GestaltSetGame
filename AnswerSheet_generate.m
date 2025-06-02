function AnswerSheet = AnswerSheet_generate()
%{
정답 위치가 어느 그룹의 시각 군집 내에 있나요?
prob1,2 = group 1
prob3,4 = group 2
prob5,6 = group 3
prob7,8 = non

-------

prob9,10 = exeptional
%}
%17
AnswerSheet.prob1 = { ...
    'triangle','red','empty','three';
    'square','red','empty','three';
    'square','blue','filled','two';
    'triangle','red','shade','one';
    'triangle','blue','filled','two';
    'circle','blue','empty','three';
    'triangle','red','shade','three';
    'circle','red','empty','one';
    'square','red','empty','one';
    'square','yellow','empty','three';
    'circle','blue','shade','one';
    'square','red','filled','three'};

AnswerSheet.ans1 = [1, 6, 10];

%15
AnswerSheet.prob2 = { ...
    'circle','red','filled','three';
    'triangle','blue','filled','three';
    'square','red','shade','two';
    'square','red','empty','three';
    'circle','red','shade','one';
    'square','blue','empty','two';
    'circle','blue','filled','two';
    'square','yellow','shade','one';
    'square','blue','shade','one';
    'circle','yellow','shade','one';
    'square','blue','shade','two';
    'square','red','filled','one'};

AnswerSheet.ans2 = [3, 4, 12];

%9
AnswerSheet.prob3 = { ...
    'circle','red','empty','one';
    'triangle','yellow','shade','one';
    'square','blue','shade','three';
    'triangle','red','empty','one';
    'circle','yellow','shade','two';
    'circle','red','filled','two';
    'triangle','blue','empty','three';
    'circle','blue','empty','two';
    'square','blue','shade','one';
    'triangle','red','empty','three';
    'triangle','blue','shade','one';
    'circle','red','empty','two'};

AnswerSheet.ans3 = [5, 6, 8];

%12
AnswerSheet.prob4 = { ...
    'triangle','yellow','filled','two';
    'circle','blue','filled','three';
    'triangle','red','shade','two';
    'circle','blue','filled','one';
    'circle','blue','empty','three';
    'triangle','yellow','empty','two';
    'circle','red','empty','two';
    'triangle','red','shade','one';
    'triangle','blue','shade','three'
    'circle','red','empty','one';
    'square','yellow','shade','three';
    'circle','red','shade','three'};
AnswerSheet.ans4 = [9, 11, 12];

%6
AnswerSheet.prob5 = { ...
    'square','blue','empty','three';
    'square','blue','filled','two';
    'circle','red','filled','two';
    'circle','yellow','empty','one';
    'square','blue','shade','one';
    'triangle','blue','shade','three';
    'circle','yellow','empty','two';
    'circle','red','filled','one';
    'triangle','blue','empty','two';
    'square','red','shade','one';
    'circle','red','shade','one';
    'square','red','shade','two'};

AnswerSheet.ans5 = [1, 2, 5];

%4
AnswerSheet.prob6 = { ...
    'circle','blue','empty','two';
    'square','blue','empty','one';
    'circle','blue','empty','one';
    'square','blue','empty','two';
    'triangle','blue','filled','one';
    'square','red','shade','one';
    'square','red','empty','two';
    'circle','yellow','filled','three';
    'square','red','empty','three';
    'triangle','yellow','shade','one';
    'square','blue','filled','three';
    'triangle','red','filled','three'};

AnswerSheet.ans6 = [8, 11, 12];

%2
AnswerSheet.prob7 = { ...
    'triangle','red','empty','two';
    'circle','yellow','empty','one';
    'triangle','red','shade','one';
    'square','yellow','shade','one';
    'square','blue','shade','one';
    'circle','red','empty','two';
    'square','yellow','filled','one';
    'square','blue','shade','two';
    'circle','red','filled','three';
    'triangle','yellow','shade','one';
    'circle','red','empty','one';
    'square','yellow','shade','two'};

AnswerSheet.ans7 = [2, 7, 10];

%3
AnswerSheet.prob8 = { ...
    'circle','yellow','filled','three';
    'square','red','shade','one';
    'circle','blue','shade','one';
    'square','blue','shade','one';
    'circle','yellow','empty','two';
    'square','red','shade','two';
    'square','yellow','filled','one';
    'circle','yellow','empty','one';
    'square','blue','filled','one';
    'square','blue','filled','three';
    'circle','red','shade','one';
    'triangle','yellow','filled','two'};

AnswerSheet.ans8 = [1, 7, 12];

AnswerSheet.prob9 = { ...
    'triangle','red','empty','three';
    'circle','red','shade','three';
    'circle','red','empty','one';
    'triangle','red','shade','three';
    'square','blue','empty','three';
    'square','yellow','empty','two';
    'triangle','red','shade','two';
    'square','blue','shade','one';
    'triangle','yellow','shade','two';
    'triangle','red','empty','one';
    'circle','blue','shade','one';
    'square','yellow','shade','one'};

AnswerSheet.ans9 = [2, 8, 9];

AnswerSheet.prob10 = { ...
    'triangle','red','filled','three';
    'circle','blue','filled','one';
    'triangle','blue','shade','two';
    'circle','blue','filled','two';
    'triangle','blue','shade','one';
    'square','yellow','shade','three';
    'triangle','red','shade','one';
    'circle','yellow','filled','two';
    'square','red','filled','one';
    'circle','yellow','filled','three';
    'triangle','blue','shade','three';
    'square','blue','shade','two'};

AnswerSheet.ans10 = [3, 5, 11];

%8
AnswerSheet.Prac1 = { ...
    'square','red','shade','one' 
    'triangle','red','shade','one'
    'square','blue','empty','one'
    'triangle','yellow','filled','one'
    'circle','red','empty','three'
    'square','yellow','shade','one'
    'triangle','red','shade','three'
    'triangle','red','empty','two'
    'circle','yellow','shade','three'
    'square','red','empty','one'
    'circle','yellow','shade','one'
    'square','red','shade','two'};

AnswerSheet.PracAns1 = [5, 8, 10];

AnswerSheet.Prac2 = { ...
    'triangle','yellow','filled','three';
    'triangle','blue','shade','one';
    'circle','yellow','shade','one';
    'triangle','red','filled','three';
    'square','red','shade','three';
    'circle','yellow','shade','three';
    'triangle','red','empty','three';
    'square','blue','shade','one';
    'triangle','red','empty','one';
    'circle','blue','empty','three';
    'circle','red','shade','one';
    'triangle','red','filled','two'};


AnswerSheet.PracAns1 = [1, 5, 10];