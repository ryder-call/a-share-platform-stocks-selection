"""
Data Fetcher module for retrieving stock data from Baostock.
Implements robust connection handling and retry logic.
"""
import baostock as bs
import pandas as pd
import time
import threading
from typing import List, Dict, Any, Optional
from colorama import Fore, Style
import traceback

# Thread-local storage for Baostock connections
_thread_local = threading.local()

def baostock_login() -> None:
    """
    Login to Baostock API with thread-local connection.
    Each thread/process will have its own connection.
    """
    # Check if already logged in
    if hasattr(_thread_local, 'logged_in') and _thread_local.logged_in:
        return
    
    # Login
    lg = bs.login()
    if lg.error_code != '0':
        print(f"{Fore.RED}Baostock login failed: {lg.error_msg}{Style.RESET_ALL}")
        raise ConnectionError(f"Baostock login failed: {lg.error_msg}")
    
    _thread_local.logged_in = True
    print(f"{Fore.GREEN}Baostock login successful in thread {threading.current_thread().name}{Style.RESET_ALL}")

def baostock_logout() -> None:
    """
    Logout from Baostock API and clean up thread-local connection.
    """
    if hasattr(_thread_local, 'logged_in') and _thread_local.logged_in:
        bs.logout()
        _thread_local.logged_in = False
        print(f"{Fore.GREEN}Baostock logout successful in thread {threading.current_thread().name}{Style.RESET_ALL}")

def baostock_relogin() -> None:
    """
    Re-login to Baostock API (logout first, then login again).
    """
    baostock_logout()
    baostock_login()

class BaostockConnectionManager:
    """
    Context manager for Baostock connections.
    Ensures proper login/logout handling.
    """
    def __enter__(self):
        baostock_login()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        baostock_logout()
        return False  # Don't suppress exceptions

def fetch_stock_basics() -> pd.DataFrame:
    """
    Fetch basic information for all stocks.
    
    Returns:
        pd.DataFrame: DataFrame containing stock basic information
    
    Raises:
        ConnectionError: If Baostock connection fails
        ValueError: If no data is returned
    """
    with BaostockConnectionManager():
        print(f"{Fore.CYAN}Fetching stock basic information...{Style.RESET_ALL}")
        try:
            print(f"{Fore.CYAN}正在调用bs.query_stock_basic()...{Style.RESET_ALL}")
            rs = bs.query_stock_basic()
            
            print(f"{Fore.CYAN}API响应状态码: {rs.error_code}, 消息: {rs.error_msg}{Style.RESET_ALL}")
            
            if rs.error_code != '0':
                print(f"{Fore.RED}查询股票基本信息失败, 错误码: {rs.error_code}, 错误信息: {rs.error_msg}{Style.RESET_ALL}")
                raise ConnectionError(f"Failed to query stock basics: {rs.error_msg}")
            
            print(f"{Fore.CYAN}正在处理返回数据...{Style.RESET_ALL}")
            stock_basics_list = []
            row_count = 0
            
            while rs.next():
                stock_basics_list.append(rs.get_row_data())
                row_count += 1
                if row_count % 1000 == 0:
                    print(f"{Fore.GREEN}已处理 {row_count} 条股票数据记录{Style.RESET_ALL}")
            
            if not stock_basics_list:
                print(f"{Fore.RED}没有获取到任何股票基本信息数据{Style.RESET_ALL}")
                raise ValueError("No stock basic information retrieved")
            
            print(f"{Fore.GREEN}成功获取到 {len(stock_basics_list)} 条股票基本信息数据{Style.RESET_ALL}")
            df = pd.DataFrame(stock_basics_list, columns=rs.fields)
            print(f"{Fore.CYAN}数据字段: {', '.join(rs.fields)}{Style.RESET_ALL}")
            
            return df
        except Exception as e:
            print(f"{Fore.RED}获取股票基本信息时发生异常: {e}{Style.RESET_ALL}")
            print(f"{Fore.RED}详细错误信息: {traceback.format_exc()}{Style.RESET_ALL}")
            raise

def fetch_industry_data() -> pd.DataFrame:
    """
    Fetch industry classification data for all stocks.
    
    Returns:
        pd.DataFrame: DataFrame containing industry classification
    
    Raises:
        ConnectionError: If Baostock connection fails
        ValueError: If no data is returned
    """
    with BaostockConnectionManager():
        print(f"{Fore.CYAN}Fetching industry classification data...{Style.RESET_ALL}")
        try:
            print(f"{Fore.CYAN}正在调用bs.query_stock_industry()...{Style.RESET_ALL}")
            rs = bs.query_stock_industry()
            
            print(f"{Fore.CYAN}行业数据API响应状态码: {rs.error_code}, 消息: {rs.error_msg}{Style.RESET_ALL}")
            
            if rs.error_code != '0':
                print(f"{Fore.RED}查询行业数据失败, 错误码: {rs.error_code}, 错误信息: {rs.error_msg}{Style.RESET_ALL}")
                raise ConnectionError(f"Failed to query industry data: {rs.error_msg}")
            
            print(f"{Fore.CYAN}正在处理行业数据返回结果...{Style.RESET_ALL}")
            industry_list = []
            row_count = 0
            
            while rs.next():
                industry_list.append(rs.get_row_data())
                row_count += 1
                if row_count % 500 == 0:
                    print(f"{Fore.GREEN}已处理 {row_count} 条行业数据记录{Style.RESET_ALL}")
            
            if not industry_list:
                print(f"{Fore.RED}没有获取到任何行业分类数据{Style.RESET_ALL}")
                raise ValueError("No industry classification data retrieved")
            
            print(f"{Fore.GREEN}成功获取到 {len(industry_list)} 条行业分类数据{Style.RESET_ALL}")
            df = pd.DataFrame(industry_list, columns=rs.fields)
            print(f"{Fore.CYAN}行业数据字段: {', '.join(rs.fields)}{Style.RESET_ALL}")
            
            return df
        except Exception as e:
            print(f"{Fore.RED}获取行业分类数据时发生异常: {e}{Style.RESET_ALL}")
            print(f"{Fore.RED}详细错误信息: {traceback.format_exc()}{Style.RESET_ALL}")
            raise

def fetch_kline_data(code: str, start_date: str, end_date: str,
                     retry_attempts: int = 3,
                     retry_delay: int = 1) -> pd.DataFrame:
    """
    Fetch K-line data for a specific stock with retry logic.
    
    Args:
        code: Stock code (e.g., 'sh.600000')
        start_date: Start date in 'YYYY-MM-DD' format
        end_date: End date in 'YYYY-MM-DD' format
        retry_attempts: Maximum number of retry attempts
        retry_delay: Delay between retries in seconds
    
    Returns:
        pd.DataFrame: DataFrame containing K-line data
    """
    retries = 0
    print(f"{Fore.CYAN}获取K线数据: {code}, 时间范围: {start_date} 至 {end_date}{Style.RESET_ALL}")
    
    while True:
        try:
            # Ensure we're logged in
            baostock_login()
            
            # Query historical K-line data
            print(f"{Fore.CYAN}正在查询 {code} 的K线数据...{Style.RESET_ALL}")
            rs = bs.query_history_k_data_plus(
                code,
                "date,open,high,low,close,volume,turn,preclose,pctChg,peTTM,pbMRQ",
                start_date=start_date,
                end_date=end_date,
                frequency="d",     # Daily frequency
                adjustflag="2"     # Forward adjusted prices
            )
            
            # Check for API errors
            if rs.error_code != '0':
                retries += 1
                print(f"{Fore.YELLOW}尝试 {retries}/{retry_attempts}: {code} 查询失败. 错误: {rs.error_msg}{Style.RESET_ALL}")
                
                if retries >= retry_attempts:
                    print(f"{Fore.RED}{code} 数据获取失败，已达到最大重试次数 {retry_attempts}{Style.RESET_ALL}")
                    return pd.DataFrame()
                
                # Retry with re-login
                sleep_time = retry_delay * (1 + retries * 0.5)
                print(f"{Fore.YELLOW}将在 {sleep_time:.1f} 秒后重试...{Style.RESET_ALL}")
                time.sleep(sleep_time)
                print(f"{Fore.YELLOW}正在重新登录...{Style.RESET_ALL}")
                baostock_relogin()
                continue
            
            # Process the data if query was successful
            print(f"{Fore.CYAN}正在处理 {code} 返回的K线数据...{Style.RESET_ALL}")
            data_list = []
            row_count = 0
            while (rs.error_code == '0') & rs.next():
                data_list.append(rs.get_row_data())
                row_count += 1
                if row_count % 100 == 0:
                    print(f"{Fore.GREEN}已处理 {code} 的 {row_count} 条K线记录{Style.RESET_ALL}")
            
            # Convert to DataFrame
            if not data_list:
                print(f"{Fore.YELLOW}{code} 在 {start_date} 至 {end_date} 期间没有K线数据{Style.RESET_ALL}")
                return pd.DataFrame()
            
            df = pd.DataFrame(data_list, columns=rs.fields)
            
            # Convert numeric columns
            print(f"{Fore.CYAN}正在转换 {code} 的数值列...{Style.RESET_ALL}")
            numeric_cols = ['open', 'high', 'low', 'close', 'volume', 'turn', 'preclose', 'pctChg', 'peTTM', 'pbMRQ']
            for col in numeric_cols:
                if col in df.columns:
                    df[col] = pd.to_numeric(df[col], errors='coerce')
            
            print(f"{Fore.GREEN}成功获取 {code} 的 {len(df)} 条K线数据{Style.RESET_ALL}")
            return df
            
        except Exception as e:
            retries += 1
            print(f"{Fore.RED}尝试 {retries}/{retry_attempts}: 获取 {code} 数据时发生异常: {e}{Style.RESET_ALL}")
            print(f"{Fore.RED}详细错误信息: {traceback.format_exc()}{Style.RESET_ALL}")
            
            if retries >= retry_attempts:
                print(f"{Fore.RED}{code} 数据获取失败，已达到最大重试次数 {retry_attempts}{Style.RESET_ALL}")
                return pd.DataFrame()
            
            # Retry with re-login
            sleep_time = retry_delay * (1 + retries * 0.5)
            print(f"{Fore.YELLOW}将在 {sleep_time:.1f} 秒后重试...{Style.RESET_ALL}")
            time.sleep(sleep_time)
            print(f"{Fore.YELLOW}正在重新登录...{Style.RESET_ALL}")
            baostock_relogin()
