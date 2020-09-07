﻿using System;
using System.Drawing;
using System.Reactive;
using System.Reactive.Linq;
using System.Threading.Tasks;
using DevExpress.EasyTest.Framework;
using Xpand.Extensions.Reactive.Transform;
using Xpand.TestsLib.EasyTest;
using Xpand.TestsLib.EasyTest.Commands;
using Xpand.TestsLib.Win32;

namespace ALL.Tests{
	public static class GoogleService{
        public static async Task TestGoogleService(this ICommandAdapter commandAdapter,Func<IObservable<Unit>> whenConnected) 
            => await commandAdapter.TestCloudService(singInCaption 
                => commandAdapter.Authenticate(singInCaption,"TestAppPass","xpand.testaplication@gmail.com")
                    .Concat(Unit.Default.ReturnObservable().SelectMany(_ => {
                        commandAdapter.Execute(new MoveWindowCommand(0,0,1024,768));
                        commandAdapter.Execute(new FindItemCommand("advance",true));
                        commandAdapter.Execute(new FindItemCommand("Go to TestApplication (unsafe)",true),new WaitCommand(3000));
                        commandAdapter.Execute(new MouseCommand(new Point(619, 497)),new WaitCommand(2000));
                        commandAdapter.Execute(new SendKeysCommand(Win32Constants.VirtualKeys.PageDown),new WaitCommand(2000));
                        commandAdapter.Execute(new SendKeysCommand(Win32Constants.VirtualKeys.PageDown),new WaitCommand(2000));
                        commandAdapter.Execute(new MouseCommand(new Point(652,606)),new WaitCommand(2000));
                        return whenConnected();
                    })), "Google",new CheckDetailViewCommand(("Value","xpand.testaplication@gmail.com")));
    }
}