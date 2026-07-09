using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using NPOI.XSSF.UserModel;
using System;
using System.Data;
using System.IO;
using System.Web;


namespace YYT.Common
{
    public class ExcelHelper
    {
        private static int ExcelMaxRow = 65535;
        /// <summary>
        /// 由DataSet导出Excel
        /// </summary>
        /// <param name="sourceTable">要导出数据的DataTable</param>    
        /// <param name="sheetName">工作表名称</param>
        /// <returns>Excel工作表</returns>    
        private static Stream ExportDataSetToExcel(DataSet sourceDs)
        {
            HSSFWorkbook workbook = new HSSFWorkbook();
            MemoryStream ms = new MemoryStream();

            for (int i = 0; i < sourceDs.Tables.Count; i++)
            {
                HSSFSheet sheet = (HSSFSheet)workbook.CreateSheet(sourceDs.Tables[i].TableName);
                HSSFRow headerRow = (HSSFRow)sheet.CreateRow(0);

                foreach (DataColumn column in sourceDs.Tables[i].Columns)
                    headerRow.CreateCell(column.Ordinal).SetCellValue(column.ColumnName);

                int rowIndex = 1;
                foreach (DataRow row in sourceDs.Tables[i].Rows)
                {
                    HSSFRow dataRow = (HSSFRow)sheet.CreateRow(rowIndex);
                    foreach (DataColumn column in sourceDs.Tables[i].Columns)
                    {
                        dataRow.CreateCell(column.Ordinal).SetCellValue(row[column].ToString());
                    }
                    rowIndex++;
                }
            }
            workbook.Write(ms);
            ms.Flush();
            ms.Position = 0;
            workbook = null;
            return ms;
        }
        /// <summary>
        /// 由DataSet导出Excel
        /// </summary>   
        /// <param name="sourceTable">要导出数据的DataTable</param>
        /// <param name="fileName">指定Excel工作表名称</param>
        /// <returns>Excel工作表</returns>    
        public static void ExportDataSetToExcel(DataSet sourceDs, string fileName)
        {
            //检查是否有Table数量超过65325
            for (int t = 0; t < sourceDs.Tables.Count; t++)
            {
                if (sourceDs.Tables[t].Rows.Count > ExcelMaxRow)
                {
                    DataSet ds = GetdtGroup(sourceDs.Tables[t].Copy());
                    sourceDs.Tables.RemoveAt(t);
                    //将得到的ds插入 sourceDs中
                    for (int g = 0; g < ds.Tables.Count; g++)
                    {
                        DataTable dt = ds.Tables[g].Copy();
                        sourceDs.Tables.Add(dt);
                    }
                    t--;
                }
            }

            MemoryStream ms = ExportDataSetToExcel(sourceDs) as MemoryStream;
            HttpContext.Current.Response.AppendHeader("Content-Disposition", "attachment;filename=" + fileName);
            HttpContext.Current.Response.BinaryWrite(ms.ToArray());
            HttpContext.Current.ApplicationInstance.CompleteRequest();
            HttpContext.Current.Response.End();
            ms.Close();
            ms = null;
        }
        /// <summary>
        /// 由DataTable导出Excel
        /// </summary>
        /// <param name="sourceTable">要导出数据的DataTable</param> 
        /// <returns>Excel工作表</returns>    
        public static Stream ExportDataTableToExcel(DataTable sourceTable)
        {
            HSSFWorkbook workbook = new HSSFWorkbook();
            MemoryStream ms = new MemoryStream();
            HSSFSheet sheet = (HSSFSheet)workbook.CreateSheet(sourceTable.TableName);
            HSSFRow headerRow = (HSSFRow)sheet.CreateRow(0);
            // handling header.      
            foreach (DataColumn column in sourceTable.Columns)
                headerRow.CreateCell(column.Ordinal).SetCellValue(column.ColumnName);
            // handling value.      
            int rowIndex = 1;
            foreach (DataRow row in sourceTable.Rows)
            {
                HSSFRow dataRow = (HSSFRow)sheet.CreateRow(rowIndex);
                foreach (DataColumn column in sourceTable.Columns)
                {
                    dataRow.CreateCell(column.Ordinal).SetCellValue(row[column].ToString());
                }
                rowIndex++;
            }
            workbook.Write(ms);
            ms.Flush();
            ms.Position = 0;
            sheet = null;
            headerRow = null;
            workbook = null;
            return ms;
        }
        /// <summary>
        /// 由DataTable导出Excel
        /// </summary>
        /// <param name="sourceTable">要导出数据的DataTable</param>
        /// <param name="fileName">指定Excel工作表名称</param>
        /// <returns>Excel工作表</returns>
        public static void ExportDataTableToExcel(DataTable sourceTable, string fileName)
        {
            //如数据超过65325则分成多个Table导出
            if (sourceTable.Rows.Count > ExcelMaxRow)
            {
                DataSet ds = GetdtGroup(sourceTable);
                //导出DataSet
                ExportDataSetToExcel(ds, fileName);
            }
            else
            {
                MemoryStream ms = ExportDataTableToExcel(sourceTable) as MemoryStream;
                HttpContext.Current.Response.AppendHeader("Content-Disposition", "attachment;filename=" + fileName);
                HttpContext.Current.Response.BinaryWrite(ms.ToArray());
                HttpContext.Current.ApplicationInstance.CompleteRequest();
                HttpContext.Current.Response.End();
                ms.Close();
                ms = null;
            }
        }
        /// <summary>
        /// 传入行数超过65325的Table，返回DataSet
        /// </summary>
        /// <param name="dt"></param>
        /// <returns></returns>
        public static DataSet GetdtGroup(DataTable dt)
        {
            string tablename = dt.TableName;

            DataSet ds = new DataSet();
            ds.Tables.Add(dt);

            double n = dt.Rows.Count / Convert.ToDouble(ExcelMaxRow);

            //创建表
            for (int i = 1; i < n; i++)
            {
                DataTable dtAdd = dt.Clone();
                dtAdd.TableName = tablename + "_" + i.ToString();
                ds.Tables.Add(dtAdd);
            }

            //分解数据
            for (int i = 1; i < ds.Tables.Count; i++)
            {
                //新表行数达到最大 或 基表数量不足
                while (ds.Tables[i].Rows.Count != ExcelMaxRow && ds.Tables[0].Rows.Count != ExcelMaxRow)
                {
                    ds.Tables[i].Rows.Add(ds.Tables[0].Rows[ExcelMaxRow].ItemArray);
                    ds.Tables[0].Rows.RemoveAt(ExcelMaxRow);

                }
            }

            return ds;
        }
        /// <summary>
        /// 由DataTable导出Excel
        /// </summary>
        /// <param name="sourceTable">要导出数据的DataTable</param>
        /// <param name="fileName">指定Excel工作表名称</param>
        /// <returns>Excel工作表</returns>
        public static void ExportDataTableToExcelModel(DataTable sourceTable, string modelpath, string modelName, string fileName, string sheetName)
        {
            int rowIndex = 2;//从第二行开始，因为前两行是模板里面的内容 
            int colIndex = 0;
            FileStream file = new FileStream(modelpath + modelName + ".xls", FileMode.Open, FileAccess.Read);//读入excel模板
            HSSFWorkbook hssfworkbook = new HSSFWorkbook(file);
            HSSFSheet sheet1 = (HSSFSheet)hssfworkbook.GetSheet("Sheet1");
            sheet1.GetRow(0).GetCell(0).SetCellValue("excelTitle");      //设置表头
            foreach (DataRow row in sourceTable.Rows)
            {   //双循环写入sourceTable中的数据
                rowIndex++;
                colIndex = 0;
                HSSFRow xlsrow = (HSSFRow)sheet1.CreateRow(rowIndex);
                foreach (DataColumn col in sourceTable.Columns)
                {
                    xlsrow.CreateCell(colIndex).SetCellValue(row[col.ColumnName].ToString());
                    colIndex++;
                }
            }
            sheet1.ForceFormulaRecalculation = true;
            FileStream fileS = new FileStream(modelpath + fileName + ".xls", FileMode.Create);//保存
            hssfworkbook.Write(fileS);
            fileS.Close();
            file.Close();
        }
        /// <summary>
        /// Excel To  DataTable
        /// </summary>
        /// <param name="path">文件路径</param>
        /// <param name="colArr">数据表的列</param>
        /// <param name="startCol">开始列</param>
        /// <param name="cutCol">从最后一列倒数,要排除的多少列数</param>
        /// <param name="startRow">开始行</param>
        /// <param name="cutRow">从最后一行倒数,要排除的多少行数</param>
        /// <returns></returns>
        public static DataTable ConvertToDataTable(string path, DataColumn[] colArr, int startCol, int cutCol, int startRow, int cutRow)
        {
            using (FileStream file = new FileStream(path, FileMode.Open, FileAccess.Read))
            {
                IWorkbook _wookbook = WorkbookFactory.Create(file);
                bool IsXSSFVer = path.ToLower().EndsWith(".xlsx");
                ISheet sheet = _wookbook.GetSheetAt(0);
                System.Collections.IEnumerator rows = sheet.GetRowEnumerator();

                DataTable dt = new DataTable();
                dt.Columns.AddRange(colArr);

                while (rows.MoveNext())
                {
                    IRow row;
                    if (IsXSSFVer)
                        row = (XSSFRow)rows.Current;
                    else
                        row = (HSSFRow)rows.Current;
                    DataRow dr = dt.NewRow();
                    if (row.RowNum < startRow) continue;
                    if (row.RowNum > (sheet.LastRowNum - cutRow)) break;

                    int _colIndex = 0;

                    for (int i = startCol; i < row.LastCellNum - cutCol; i++, _colIndex++)
                    {
                        ICell cell = row.GetCell(i);
                        if (cell == null)
                        {
                            dr[_colIndex] = DBNull.Value;
                            continue;
                        }
                        if (i == dt.Columns.Count) break;//Out Of Dt Columns Range
                        switch (cell.CellType)
                        {
                            case CellType.Blank:
                                if (dt.Columns[_colIndex].DataType.Name.Equals("Int32") || dt.Columns[_colIndex].DataType.Name.Equals("Int64"))
                                    dr[_colIndex] = 0;
                                //else if (dt.Columns[_colIndex].DataType.Name.Equals("String"))
                                //    dr[_colIndex] = "";
                                else
                                    dr[_colIndex] = DBNull.Value;//"[null]";
                                break;
                            case CellType.Boolean:
                                dr[_colIndex] = cell.BooleanCellValue;
                                break;
                            case CellType.Numeric:
                                dr[_colIndex] = cell.ToString();
                                break;
                            case CellType.String:
                                dr[_colIndex] = cell.StringCellValue;
                                break;
                            case CellType.Error:
                                dr[_colIndex] = cell.ErrorCellValue;
                                break;
                            case CellType.Formula:
                            default:
                                dr[_colIndex] = "=" + cell.CellFormula;
                                break;
                        }
                    }
                    dt.Rows.Add(dr);
                }
                return dt;
            }
        }

    }
}