import { appAccount, BusinessError } from "@kit.BasicServicesKit"
import { bundleManager } from "@kit.AbilityKit"
import { UserPreference } from "./UserPerference"

/**
 * AccountManager类提供了一组管理用户账号的方法，包括保存账号及其刷新令牌、获取账号列表、获取刷新令牌等。
 * 它通过单例模式确保全局只有一个实例，以统一管理账号信息。
 */
export class AccountManager {
  // 单例模式实现，确保全局只有一个AccountManager实例
  private static instance: AccountManager
  // 账号管理器，用于调用底层账号管理接口
  private readonly accountManager: appAccount.AppAccountManager
  // 刷新令牌的键名，用于存储和获取刷新令牌
  private static readonly REFRESH_TOKEN = 'refresh_token'

  // 私有构造函数，防止外部实例化
  private constructor() {
    this.accountManager = appAccount.createAppAccountManager()
  }

  /**
   * 获取AccountManager的单例实例
   * @returns {AccountManager} AccountManager的实例
   */
  public static getInstance(): AccountManager {
    if (!AccountManager.instance) {
      AccountManager.instance = new AccountManager()
    }
    return AccountManager.instance
  }

  /**
   * 保存账号信息和刷新令牌
   * @param {string} account 账号名称
   * @param {string} refreshToken 刷新令牌
   * @param {appAccount.CreateAccountOptions} opt 可选的账号创建选项
   */
  public saveAccount(account: string, refreshToken: string, opt?: appAccount.CreateAccountOptions): void {
    // 先移除已存在的账号，再创建新账号，以确保账号信息的唯一性
    this.accountManager.removeAccount(account)
      .catch((e: BusinessError) => {
        console.error('移除账号失败', e)
      }).finally(() => {
      this.accountManager.createAccount(account, opt).catch((e: BusinessError) => {
        console.error('保存账号失败', e)
      })
      // 保存刷新令牌
      this.accountManager.setAuthToken(account, AccountManager.REFRESH_TOKEN, refreshToken)
        .catch((e: BusinessError) => {
          console.error('保存token失败', e)
          UserPreference.set(AccountManager.REFRESH_TOKEN, refreshToken)
        })
    })
  }

  /**
   * 获取所有账号信息
   * @returns {Promise<appAccount.AppAccountInfo[]>} 账号信息数组的Promise对象
   */
  public getAccounts(): Promise<appAccount.AppAccountInfo[]> {
    // 通过bundleManager获取当前应用的包名，以获取对应的账号信息
    return this.accountManager.getAccountsByOwner(bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      .name)
  }

  /**
   * 获取指定账号的刷新令牌
   * @param {string} username 账号名称
   * @returns {Promise<string>} 刷新令牌的Promise对象
   */
  public getRefreshToken(username: string): Promise<string> {
    // 获取指定账号的刷新令牌
    return this.accountManager.getAuthToken(username,
      bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).name,
      AccountManager.REFRESH_TOKEN)
  }

  /**
   * 获取指定账号的自定义数据
   * @param {string} username 账号名称
   * @param {string} key 自定义数据的键名
   * @returns {string} 自定义数据的值
   */
  public getAccountCustomData(username: string, key: string): string {
    // 同步获取指定账号的自定义数据
    return this.accountManager.getCustomDataSync(username, key)
  }

  /**
   * 保存指定账号的自定义数据
   * @param {string} username 账号名称
   * @param {string} key 自定义数据的键名
   * @param {string} value 自定义数据的值
   * @returns {Promise<void>} 表示异步操作完成的Promise对象
   */
  public saveAccountCustomData(username: string, key: string, value: string): Promise<void> {
    // 异步保存指定账号的自定义数据
    return this.accountManager.setCustomData(username, key, value)
  }
}
