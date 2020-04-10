module PiCalculus {
    use Random;
    use Time;
    config const tasksPerLocale = here.maxTaskPar;
    config const totalNumberOfIterations = 10000000;
    const iterationsPerThread = totalNumberOfIterations / (tasksPerLocale * numLocales);
    
    proc calculatePi() {
        var hits = 0;
        var randomStream1 = new RandomStream(real);
        var randomStream2 = new RandomStream(real);
        var casesRange = {1..iterationsPerThread};
        var min = 1.0, max = 0.0;
        for (x, y) in zip(randomStream1.iterate(casesRange, real), randomStream2.iterate(casesRange, real)) {
            var distance_from_middle = x * x + y * y;
            if(distance_from_middle <= 1) {
                hits += 1;
            }
        }
        writeln("Done!");
        return 4.0*hits/iterationsPerThread;
    }

    proc calculateParallel() {
        var threadsDomain = {0..#tasksPerLocale};
        var tableForResults: [threadsDomain] real;
        forall idx in threadsDomain {
            tableForResults[idx] = calculatePi();
        }
        var sumOfPi: real = 0;
        for i in tableForResults {
            sumOfPi += i;
        }
        return sumOfPi/tasksPerLocale;
    }

    proc runOnLocales() {
        var tableForResults: [LocaleSpace] real;
        forall locNumber in LocaleSpace {
            on Locales[locNumber] {
                write(locNumber, " ");
                tableForResults[locNumber] = calculateParallel();
            }
        }

        var sumOfPi: real = 0;
        for i in tableForResults {
            sumOfPi += i;
        }
        return sumOfPi/numLocales;
    }
    
    proc main() {
        var t: Timer;
        t.start();
        writeln(runOnLocales());
        t.stop();
        writeln("Time: ", t.elapsed());
    }
}