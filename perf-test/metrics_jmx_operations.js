/*
 * Copyright 2015 WSO2 Inc. (http://wso2.org)
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * How to run (examples):
 * Using jrunscript:
 * jrunscript -cp ~/.m2/repository/org/wso2/carbon/metrics/org.wso2.carbon.metrics.manager/1.1.1/org.wso2.carbon.metrics.manager-1.1.1.jar metrics_jmx_operations.js localhost 11111 9999 admin admin disable
 * jrunscript -cp ~/.m2/repository/org/wso2/carbon/metrics/org.wso2.carbon.metrics.manager/1.1.1/org.wso2.carbon.metrics.manager-1.1.1.jar metrics_jmx_operations.js enable
 *
 * Using jjs:
 *
 * jjs -cp ~/.m2/repository/org/wso2/carbon/metrics/org.wso2.carbon.metrics.manager/1.1.1/org.wso2.carbon.metrics.manager-1.1.1.jar metrics_jmx_operations.js -- localhost 11111 9999 admin admin disable
 * jjs -cp ~/.m2/repository/org/wso2/carbon/metrics/org.wso2.carbon.metrics.manager/1.1.1/org.wso2.carbon.metrics.manager-1.1.1.jar metrics_jmx_operations.js -- enable
 * 
 */
packages = new JavaImporter(java.lang,
                            java.lang.reflect,
                            java.lang.management,
                            java.io,
                            java.util,
                            javax.management.remote,
                            javax.management,
                            org.wso2.carbon.metrics.manager.jmx);

var Array = Java.type("java.lang.reflect.Array");
var JString = Java.type("java.lang.String");

with (packages)
{
    if (arguments.length != 1 && arguments.length != 6)
    {
        print("Invoke JMX Operation on Metrics Manager.\n");
        print("Usage: metrics_jmx_operations.js [host] [rmiserverport] [rmiregistryport] [username] [password] action\n");
        print("Action is one of the following: enable, disable, report\n");
        quit();
    }
    var host = "localhost";
    var rmiserverport = "11111";
    var rmiregistryport = "9999";
    var username = "admin";
    var password = "admin";
    var method = "";
    if (arguments.length == 6) {
        host = arguments[0];
        rmiserverport = arguments[1];
        rmiregistryport = arguments[2];
        username = arguments[3];
        password = arguments[4];
        method = arguments[5];
    } else {
        method = arguments[0];
    }

    var environment = new HashMap();
    var usernamePassword = Array.newInstance(JString.class, 2);
    usernamePassword[0] = username;
    usernamePassword[1] = password;

    environment.put(JMXConnector.CREDENTIALS, usernamePassword);

    var serviceUrl =  new JMXServiceURL("service:jmx:rmi://" + host + ":" + rmiserverport + "/jndi/rmi://" + host + ":" + rmiregistryport + "/jmxrmi");
    var jmxConnector = JMXConnectorFactory.connect(serviceUrl, environment);
    var mbsc =  jmxConnector.getMBeanServerConnection();

    var mbeanName = new ObjectName("org.wso2.carbon:type=MetricManager");
    var mbeanProxy = MBeanServerInvocationHandler.newProxyInstance(mbsc, mbeanName, MetricManagerMXBean.class, true);

    if ("enable".equals(method)) {
        mbeanProxy.enable();
    } else if ("disable".equals(method)) {
        mbeanProxy.disable();
    } else if ("report".equals(method)) {
        mbeanProxy.report();
    }

    jmxConnector.close();
}
