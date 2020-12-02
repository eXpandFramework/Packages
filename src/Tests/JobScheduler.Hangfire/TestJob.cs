﻿using System;
using System.Reactive.Subjects;
using DevExpress.ExpressApp.Blazor;
using Hangfire;

namespace Xpand.XAF.Modules.JobScheduler.Hangfire.Tests {
    public class TestJobDI:TestJob {
        public TestJobDI(BlazorApplication provider):base(provider) {
        }

        public TestJobDI() { }
    }

    public class TestJob {
        public static Subject<TestJob> Jobs=new Subject<TestJob>();    
        public TestJob() { }
        public BlazorApplication Application { get; }

        protected TestJob(BlazorApplication application) {
            Application = application;
        }

        [AutomaticRetry(Attempts = 0)]
        public void FailMethodNoRetry() {
            throw new NotImplementedException();
        }
        
        [AutomaticRetry(Attempts = 1,DelaysInSeconds = new[] {1,1})]
        public void FailMethodRetry() {
            throw new NotImplementedException();
        }

        public void Test() {
            Jobs.OnNext(this);
        }
    }
}