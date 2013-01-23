#!/usr/bin/python

def lenNwordsFileName(n):
    return 'len%d.dict'%n;

def lenNwordsWithVectorFileName(n):
    return 'veclen%d.dict'%n;

keycordFileName = 'keycord.dat'
lines = [line.strip() for line in open(keycordFileName, 'r')];

cordDict = {}
for i in range(0, len(lines)):
    words = lines[i].split(' ');
    cordDict[words[0]] = (float(words[1]), float(words[2]));

for i in range(1, 25):
    allwords = [line.strip() for line in open(lenNwordsFileName(i))];
    outputFileName = lenNwordsWithVectorFileName(i);
    outputFile = open(outputFileName, 'w');
    print '**** fileNum = %d'%i;
    cnt = 0;
    for word in allwords:
        w = word.lower();
        outputFile.write(w + ' ');
        for j in range(1, len(w)):
            x = cordDict[w[j]][0] - cordDict[w[j-1]][0];
            y = cordDict[w[j]][1] - cordDict[w[j-1]][1];
            outputFile.write(str(x) + ' ' + str(y) + ' ');
        print '====== lineCnt = %d'%cnt;
        cnt = cnt + 1;
        outputFile.write('\n')

