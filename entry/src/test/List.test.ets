import ApiClientTest from './ApiClient.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  ApiClientTest()
}