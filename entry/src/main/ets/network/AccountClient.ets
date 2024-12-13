import { ApiUtil } from './util/ApiUtil';
import { rcp } from '@kit.RemoteCommunicationKit';

export class AccountClient {
  /**
   * 修改账号信息？
   * */
  public static accountEdit(currentPassword:string,newMailAddress:string='',newUserAccount:string='',newPassword:string=''):Promise<rcp.Response|null>{
    let form = new rcp.Form({
      'current_password': currentPassword
    })
    if (newMailAddress && newMailAddress.length>0) {
      form.fields['new_mail_address'] = newMailAddress
    }
    if (newUserAccount && newUserAccount.length>0) {
      form.fields['new_user_account'] = newUserAccount
    }
    if (newPassword && newPassword.length>0) {
      form.fields['new_password'] = newPassword
    }
    return ApiUtil.post('/api/account/edit',form)
  }
  /**
   * 创建账号？
   * */
  public static createProvisionalAccount(username:string):Promise<rcp.Response|null>{
    const request = new rcp.Request(
      '/api/provisional-accounts/create',
      'POST',
      {
        'authorization': 'Bearer l-f9qZ0ZyqSwRyZs8-MymbtWBbSxmCu1pmbOlyisou8'
      },
      new rcp.Form({
        'user_name': username,
        'ref': 'pixiv_android_app_provisional_account'
      })
    )
    return ApiUtil.fetch(request)
  }
}