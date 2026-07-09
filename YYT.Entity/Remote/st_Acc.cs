using System.Runtime.InteropServices;

namespace YYT.Entity
{
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto, Pack = 1)]
    public struct st_FishAcc
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
        public byte[] HeadBytes;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
        public st_FishBetAccBody[] Body;
    }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto, Pack = 1)]
    public struct st_BetAcc
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
        public byte[] HeadBytes;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
        public st_FishBetAccBody[] Body;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Undefine;
    }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto, Pack = 1)]
    public struct st_FishBetAccBody
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Small_In;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Small_Out;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Medium_In;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Medium_Out;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Large_In;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Large_Out;
    }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto, Pack = 1)]
    public struct st_CardAcc
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
        public byte[] HeadBytes;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
        public st_CardAccBody[] Body;
    }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto, Pack = 1)]
    public struct st_CardAccBody
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
        public byte[] PlayRound;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Pok_In;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Pok_Out;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 13)]
        public st_CardTypeData[] CardTypeDatas;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Dou_In;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
        public byte[] Dou_Out;
    }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto, Pack = 1)]
    public struct st_CardTypeData
    {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
        public byte[] CardTypeData;
    }
}
