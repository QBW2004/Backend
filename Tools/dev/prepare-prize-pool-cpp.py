from pathlib import Path
import sys
repo = Path(__file__).resolve().parents[2]
server = repo.parent / 'MTH-Server'
sys.path.insert(0, str(server / 'tests'))
from check_total_release_progress import body
out = Path(sys.argv[1])
source = (server / 'ServerCenterNew/Database.cpp').read_text(encoding='utf-8-sig')
methods = ['bool Database::SavePrizeRecord(', 'bool Database::SavePrizeReleaseRecord(',
           'Int32 Database::GetPrizeControlId(', 'bool Database::TakeExhaustedPrizeControls(']
fixture = (server / 'tests/prize_pool_mysql_fixture.h').read_text(encoding='utf-8-sig')
(out / 'prize-pool-cpp.cpp').write_text(fixture.replace('// @PRODUCTION_METHODS@', '\n'.join(body(source,s) for s in methods)), encoding='utf-8')
poco = server / 'third_party/pocolink'
includes = ' '.join(f'/I"{poco / part / "include"}"' for part in ('Foundation', 'Data', 'Data/MySQL', 'JSON', 'Net'))
(out / 'build-prize-pool.bat').write_text(
    '@echo off\ncall "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Auxiliary\\Build\\vcvars64.bat" >nul\n'
    f'cl /nologo /utf-8 /EHsc /MD /std:c++14 {includes} /I"{server}" "{out / "prize-pool-cpp.cpp"}" '
    f'/Fe"{out / "prize-pool-cpp.exe"}" /Fo"{out / "prize-pool-cpp.obj"}" /link /LIBPATH:"{poco / "lib"}" '
    'PocoFoundation.lib PocoData.lib PocoDataMySQL.lib\nexit /b %errorlevel%\n', encoding='ascii')
