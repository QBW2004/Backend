using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace YYT.Common
{
    public static class ObjectHelper
    {
        /// <summary>
        /// 获取属性值
        /// </summary>
        public static T GetPropertyVal<T>(this object obj, string fieldName)
        {
            try
            {
                Type tp = obj.GetType();
                object val = tp.GetProperty(fieldName).GetValue(obj, null);

                if (typeof(T) == typeof(string))
                {
                    return (T)Convert.ChangeType(val, typeof(T));
                }
                else if (!string.IsNullOrEmpty(val.ToString()))
                {
                    return (T)Convert.ChangeType(val, typeof(T));
                }
                return typeof(T) == typeof(string) ? (T)Convert.ChangeType("", typeof(T)) : default(T);
            }
            catch
            {
                return default(T);
            }
        }

        /// <summary>
        /// 设置类中的属性值
        /// </summary>
        public static bool SetPropertyVal(this object obj, string fieldName, object val)
        {
            try
            {
                if (obj == null)
                {
                    LogHelper.WriteLog(typeof(ObjectHelper), $"SetPropertyVal 失败: obj 为 null");
                    return false;
                }
                
                Type tp = obj.GetType();
                PropertyInfo propInfo = tp.GetProperty(fieldName);
                
                // 属性不存在
                if (propInfo == null)
                {
                    LogHelper.WriteLog(typeof(ObjectHelper), 
                        $"SetPropertyVal 警告: 属性 {fieldName} 在类型 {tp.Name} 中不存在");
                    return true; // 属性不存在时返回 true，避免中断流程
                }
                
                // 如果值为 null
                if (val == null)
                {
                    // 如果目标属性是值类型（如int），不能设置null，跳过
                    if (propInfo.PropertyType.IsValueType && 
                        Nullable.GetUnderlyingType(propInfo.PropertyType) == null)
                    {
                        LogHelper.WriteLog(typeof(ObjectHelper), 
                            $"SetPropertyVal 跳过: 属性 {fieldName} 是值类型，值为 null");
                        return true; // 跳过，不算错误
                    }
                    // 引用类型或可空类型可以设置null
                    propInfo.SetValue(obj, null, null);
                    return true;
                }
                
                // 如果值是空字符串
                if (val is string && string.IsNullOrWhiteSpace((string)val))
                {
                    if (propInfo.PropertyType == typeof(string))
                    {
                        // 对于 BetScores 字段，空字符串设置为默认值
                        if (fieldName == "BetScores")
                        {
                            propInfo.SetValue(obj, "1,5,10,50,100", null);
                            LogHelper.WriteLog(typeof(ObjectHelper), 
                                $"SetPropertyVal: BetScores 为空，设置默认值 '1,5,10,50,100'");
                        }
                        else
                        {
                            propInfo.SetValue(obj, val, null);
                        }
                        return true;
                    }
                    // 目标属性不是string，跳过空字符串
                    LogHelper.WriteLog(typeof(ObjectHelper), 
                        $"SetPropertyVal 跳过: 属性 {fieldName} 不是 string，值为空字符串");
                    return true;
                }
                
                // 类型转换
                object convertedValue = val;
                if (propInfo.PropertyType != val.GetType())
                {
                    Type targetType = Nullable.GetUnderlyingType(propInfo.PropertyType) ?? propInfo.PropertyType;
                    convertedValue = Convert.ChangeType(val, targetType);
                }
                
                // 正常设置值
                propInfo.SetValue(obj, convertedValue, null);
                return true;
            }
            catch (Exception ex)
            {
                // 记录错误日志
                LogHelper.WriteLog(typeof(ObjectHelper), 
                    $"SetPropertyVal 失败: fieldName={fieldName}, val={val}, valType={val?.GetType().Name}, error={ex.Message}\n{ex.StackTrace}");
                return false;
            }
        }

    }
}
