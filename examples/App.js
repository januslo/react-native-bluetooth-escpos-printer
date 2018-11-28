/**
 * Created by januslo on 2018/9/20.
 */
/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {ActivityIndicator,Platform, StyleSheet, Text, View,Image,Button,NativeModules,ListView,DeviceEventEmitter,NativeEventEmitter,Switch} from 'react-native';
import {BluetoothManager,BluetoothEscposPrinter,BluetoothTscPrinter} from 'react-native-bluetooth-escpos-printer';


var dateFormat = require('dateformat');

//获取屏幕信息
var Dimensions = require('Dimensions');
var width = Dimensions.get('window').width;
var height = Dimensions.get('window').height;


const ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
const base64Image = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAMAAABg3Am1AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAA8FBMVEUAAABCQkJDQ0NFRUU/Pz9BQUFAQEBERERDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0MAAAA0ZZMIAAAATnRSTlMAAAAAAAAAABWFz8JdBQFHt9OYIxSi/PBsBFHjvCSk/vJt5b7mo26h75ziIZkD1csRXvpziwvx+QadveRSSA3XF6r31DMPOSLWzMTZFgd4wftfAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAALEgAACxIB0t1+/AAAAaBJREFUSMe11dlSwjAUgOE2WmUTQRBtBQVBREREQEVUFkHcz/s/jklbQ7YOhwtz2fzftJ1OTi0rWDaJxRPJ1A6xxEXSu5nsXo7Ylrpskt8vABwcuqIgG94RABRLmtgk+eMTugXliiAI8U7ZRaiqwvnrJUH7WnBRFfR5zsKeinoohN4XRHyeZc8F2RJ6SSh9KJReeCpH7QOh9st76L3/5lrPRf5c6wEaF039IlQvmYgXAL1aVxQk8D20YxQk1wDXHQpuGui+22Pv4FbK2L5/639Rt44TYY8WvEcKoUcJqUcIpV8ptN4Xd5H9vd5TMXiIBMOOoXe8x0igzJKgf6pB9JJmCaIXJkPYb6/oFYHoJYHqxXllo/qlcDxcz8VzE9lTkWInLoPuAZIjCrJrgPGEgtYaYDqgIFc07LwMTbNkNmfvQEpVbafbfzXMkvbCn622Lth50adP2BuEf740MVvwP4oi+LyShNArQphXgpB69v/jQppXXCi9IJR5FQqt50KbV74w9Ey8td4/etq8Sn1+TeeGngn3u5PW7myPJj/G/v/WL4DMswebZ4AxAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDE1LTA2LTI1VDA4OjQ0OjQ2KzA4OjAww1b9dwAAACV0RVh0ZGF0ZTptb2RpZnkAMjAxNS0wNi0yNVQwODo0NDo0NiswODowMLILRcsAAAAASUVORK5CYII=";
const base64Jpg = "/9j/4AAQSkZJRgABAQEAYABgAAD/4QBoRXhpZgAATU0AKgAAAAgABAEaAAUAAAABAAAAPgEbAAUAAAABAAAARgEoAAMAAAABAAIAAAExAAIAAAARAAAATgAAAAAAAABgAAAAAQAAAGAAAAABcGFpbnQubmV0IDQuMC4xNgAA/9sAQwAHBQUGBQQHBgUGCAcHCAoRCwoJCQoVDxAMERgVGhkYFRgXGx4nIRsdJR0XGCIuIiUoKSssKxogLzMvKjInKisq/9sAQwEHCAgKCQoUCwsUKhwYHCoqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq/8AAEQgBQwKeAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/aAAwDAQACEQMRAD8Ao0UUV+sn5AFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAVoaHpba3rdtpySiFrhiocrkDgnp+FZ9dD4D/wCR60v/AK6n/wBBNYYibhRnOO6T/I3w0I1K8IS2bS/E6j/hTt1/0F4f+/J/xo/4U7df9BeH/vyf8a9Wor4X+2sd/P8Agv8AI++/sPAfyfi/8zyn/hTt1/0F4f8Avyf8aP8AhTt1/wBBeH/vyf8AGvVqKP7ax38/4L/IP7DwH8n4v/M8p/4U7df9BeH/AL8n/Gj/AIU7df8AQXh/78n/ABr1aij+2sd/P+C/yD+w8B/J+L/zPKf+FO3X/QXh/wC/J/xo/wCFO3X/AEF4f+/J/wAa9Wryr4v/ABtsfhyo0vTIkv8AxBLGJFicEw26k8GQgg5IzhRzxk4BGT+2sd/P+C/yD+w8B/J+L/zMLxR4P0jwZYLd+J/Ftjp8b/6tZImMkuCAdkaks+Ny52g4BycCvMrn4ieD4LqWKK61a5SNyqzRWCBJADgMu6YNg9RkA+oFeV65r2q+JdWm1PXr+a+vJiS0szZxyTgDoqjPCjAHQAVn0f21jv5/wX+Qf2HgP5Pxf+Z68vxJ8KEfOdZByellEeM8f8tvSui0bV/C3iK1T+zPFmnWV4QXktdc3WXlqGx/rMPGWPykKGJwc8YIr5/oo/trHfzfgv8AIP7DwH8n4v8AzPbvGup6r4A1VbHxLoNxB5u429xHKrxXCqcFkYfgcHDAMuQMiub/AOFo2f8A0Dp/++xVLwP8TZtCs08OeKbRde8Hys4n0yZFZod/WSBzhkcckAEDJbG1jvFT4h+BoPCV1Y3+h6lHq3hvWUebSr5WG91UgNHIvBDoWAPA+gO5Vf8AbeN/m/BC/sLA/wAv4s2P+Fo2f/QOn/77FH/C0bP/AKB0/wD32K81oo/tvG/zfgg/sLA/y/iz0r/haNn/ANA6f/vsUf8AC0bP/oHT/wDfYrzWij+28b/N+CD+wsD/AC/iz0r/AIWjZ/8AQOn/AO+xR/wtGz/6B0//AH2K81oo/tvG/wA34IP7CwP8v4s9t0rx14J1G6aK81i+0pFQsJrzTiyMcgbR5Tu2ec8jHB56Z9S0r4cWuvWrXWh+KtN1K3RzG0tmRMisACVJViM4IOPcV8gV23wr+JN58NPFn9oRpJdafcJ5V7ZrJtEq87WHUblJyDjoWGRuJpf21jv5/wAF/kP+w8B/J+L/AMz6X/4U7df9BeH/AL8n/Gj/AIU7df8AQXh/78n/ABr0jRtZ07xDo1tq2i3cd5Y3Sb4Zozww6fUEEEEHBBBBAIq9R/bWO/n/AAX+Qf2HgP5Pxf8AmeU/8Kduv+gvD/35P+NH/Cnbr/oLw/8Afk/416tRR/bWO/n/AAX+Qf2HgP5Pxf8AmeU/8Kduv+gvD/35P+NH/Cnbr/oLw/8Afk/416tRR/bWO/n/AAX+Qf2HgP5Pxf8AmeU/8Kduv+gvD/35P+NZXiT4dT+HNEk1GXUY51RlXYsRBOTjrmva65H4n/8AIi3H/XWP/wBCFdWEzbGVcRCEpaNpbI5cZk+DpYadSEdUm93/AJnh1FFFfbnwgUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRTJZoreJpZ5EijUZZ3YAD8TWefEuiCQJ/a1nk/8ATZcfnnFZyqwh8UkjSFKpP4It/I06Kr5ttTtAYp/NhY5ElvOVz9GQj+dc3rfhfVWjebQtcv0cZP2ea5YhvZWzx+OfqKyrVZwjzwhzLyeptRo06kuSpPlfmtDrKK8SutZ8Q2Vy9vd6jqEU0ZwyNO4I/Wov+Ei1r/oLXv8A4EN/jXhviGknZ02e8uHKrV1UR7lRXhv/AAkWtf8AQWvf/Ahv8aP+Ei1r/oLXv/gQ3+NL/WKj/I/wH/q3W/5+L8T3KivDf+Ei1r/oLXv/AIEN/jSr4k1tHDDVrzIORmdiPyJo/wBYqP8AI/wD/Vut/OvxPcaK810L4kXMUqw66gniJ/18ahWX6gcEfTH416LaXcF9apc2kqzQyDKuhyDXs4THUMXG9J69up4mMwFfBytVWndbEtFFFdpwhRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAV0PgP/AJHrS/8Arqf/AEE1z1dD4D/5HrS/+up/9BNc2L/3ep/hf5HVg/8Aeaf+Jfme/UUUV+Xn6qFFFFABRRRQBznjzxpYeAfB15r2pASeSAsFv5gRriU/djUn16nAOFDHBxXwZrOs6j4h1m51bWruS8vrp9800h5Y9Og4AAAAAwAAAAAK9a/aO+I0firxZF4e0id30zRXdZjhlWW6yVc4zhggG1TgHJkwSCCfGKACiiigAooooAK7/wCHus/2vpV18NtUFv8AYNem32FxImGs9R2gQuGCMdrsqRNxwrEgr827gKKAJLm2ns7qW1vIZILiFzHLFKhV42BwVYHkEEYINR16n8RtNuPGXgnRvihbKs01xEthr4iO8xXUX7tZnxwgkQJ8oVQuU67wa8soAKKKKACiiigAooooA90/Zr+JE2jeJl8H6pcqNL1NmNp5m0eTdYGBuJGFcArt5y+zAGWz9X1+blfc3we+IUXxD8CW91NMp1azVbfUY9y7vMA4lwAMK+NwwMA7lGdpoA72iiua0/xzpWueLJ9B8PSrqU1hk6nPET5VoMfKu/BV5GY42g8BJMkFQrAHS0UUUAFcj8T/APkRbj/rrH/6EK66uR+J/wDyItx/11j/APQhXbgP97p/4l+Zw5j/ALnV/wAL/I8Oooor9MPy4KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACuW8VeNYNCza2YW4vu6k/LEP8Aax39v5cZteMfEH9gaMWhYC7nykAxnHq2Pb+ZFeNu7SSM8jFnY5ZmOST6187m+aSw/wC5o/F1fb/gn0uT5VHE/v63w9F3/wCAWtR1W+1afzdRupJ27bjwv0HQfhVSiivipSlN80ndn3EYxhHlirIs2GpXml3IuNPuHgkHGVPUehHQj2NeleE/HKavIljqgSG8PCOvCy+3sf5/pXllKrFWDKSGByCD0ruwWYVsJO8X7vVdDgx2X0cZBqatLo+p7J4q8LweIrLK7Y76Jf3Mvr/st7fy6+oPjs8EltcSQToUljYq6nqCOor13wX4k/t7Sylyw+22+Fl7bx2b8e/v9RWJ8SNADRLrVsvzLhLkDuOit/T8vSvezTC08XQWNofPzX+aPn8qxdXCYh4HEfLyf+T6HnVFFFfIn2IUUUUAFb/hXxTceHbza26Wylb97Dnp/tL7/wA+noRgUVrRrToTVSm7NGNajTr03TqK6Z9AW9xFd20dxbSCSKRQyOvQg1JXmnw88SfZbn+x7xz5MzZt2Y8I/wDd+h/n9a9Lr9HwOMji6KqLfquzPzTH4OWDrunLbo+6Ciiiu04QooooAKKKKACiiigAooooAKKKKACiiigArofAf/I9aX/11P8A6Ca56uh8B/8AI9aX/wBdT/6Ca5sX/u9T/C/yOrB/7zT/AMS/M9+ooor8vP1UKKKKACvOfjh8QD4B+Hs0lhMsesai32WxGQWQkfPLjcDhV6EZAdkyMGvRq+I/jl4y1Pxb8SLuO/t7mytNNJt7K0uEkjYR9fNMbhSrSDa3Kg7dgOduaAPOKKKKACiiigAooooAKu6No2oeIdZttJ0W0kvL66fy4YYxyx+p4AAySTgAAkkAVSr6P/Zc8BP5t1431GJfL2vZ6eskXJPHmTKSOB/yzDKecyA4xyAe12/w70G2+GZ8CxwyHSDavbkyEPJliWMuWBG/eS4OMBsYAAAr4b8U+GtQ8H+KL7QdZWNbyykCOYn3KwIDKyn0KkEZweeQDxX6G14f+0v8P113wmnivToWfUdHULcBASZLUk54CnJRjuzkAKZCc8UAfJlFFFABRRRQAUUUUAFd/wDBv4jSfDrxxFcztnSb/bbagjM+1ELDEwVc5ZOSOCSC6jBbI4CigD2f4i/H3xB8QPM8O+FbKbTtNvW+z+VFmS6vQzEBTt+6GBUGNck8jcwOK+h/hL4GHw++HdlpEuDfSk3V8yk4M7gZHUj5VCpkYB2ZwCTXgH7NHgA694ufxTqMCvp2jHEAcAiS6I+XgqQdindnIIYxkd6+tKACiiigArkfif8A8iLcf9dY/wD0IV11cj8T/wDkRbj/AK6x/wDoQrtwH+90/wDEvzOHMf8Ac6v+F/keHUUUV+mH5cFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFNllSCF5ZmCRxqWZmOAoHJNOrgviP4g8qFdGtX+eQB7gg9F6hfx6/THrXJjMTHC0XVl0282dmDwssXXjSj138kcd4l1x9f1qW6ORCPkgQ/woOn4nqfrWTRRX5rUqSqzc5u7Z+n0qcaUFTgrJBRRRWZoFFFFAGp4c1l9C1yC8GTHnZMo/iQ9f8AEe4Fe1yxQX1m8cgWWCdCDg5DKR/hXhmlabNq+qQWNsPnlbG7so7k/Qc17lZ2qWVjBaw7jHBGsa7jk4AwM19hw86jpzjJe5+vU+M4jVONSEov3/06HiGt6TLousT2M2T5bfI5GN6nofy/XNUK9T+Imhfb9KGpQLmezHz4/ij7/kefpuryyvAzHCPCYhwWz1XofQ5bjFjMOpvdaP1/4IUUUV5x6QUUUUAKrMjh0YqynIIOCDXtHhTXl1/RI5nI+0xfu51B/i/vfQ9fzHavFq3fCGvHQdcSSViLWb93OOwHZvwP6Z9a9fKcb9Vr2k/dlo/0fyPHzfA/W8PeK96Oq/VfP8z2eigHIyORRX6EfnAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAV0PgP/ketL/66n/0E1z1dD4D/AOR60v8A66n/ANBNc2L/AN3qf4X+R1YP/eaf+Jfme/UUUV+Xn6qFFFFABXMeOvh54f8AiHpKWPiK2ZmhYtb3ULBJoCeDtbB4PcEEHAOMgEdPRQB8TfEn4H+JPh60l4inV9EQJ/xMYI9uwkHIkjySmCPvcryvOTtHmtfpHXj/AMTf2e9E8ZvNqnh5o9E1uR3llcKTBdsV4DqD8hLAEuo7sSrE5AB8eUVseJvCeu+DdWOm+JdNlsLraHVXIZXUjOVdSVYdsgnByDyCKx6ACiiigDS8O6BfeKfElhomkx77u+mWKPIYquerNtBIVRlicHABPavv/wAO6DY+F/DdhomlR7LSxhWGPIUM2OrttABZjlicDJJPevB/2XPAduunXXjXUIC108rWun+bDgRoAN8qMepYkpkAY2OMncQPoqgApssUc8LxTIskcilXRxkMDwQR3FOooA+Evix4Am+Hfju60xFkbTZv3+nzuB88R/hyCeVOVOcE4DYAYVxNfbXx08B/8Jz8OLn7FB5uraXm7stiZd8D95EMKWO5eijGXWPJwK+JaACiiigAooooAKs6bp91q+q2mm6fF513eTJBBHuC73dgqjJIAySOScVWr6R/Zb8B/wDH5421KD+9aab5if8Af2Vcr9EDK3/PVSKAPdvBnhe18F+DdN8P2J3x2MIRpMEebITud8EnG5izYyQM4HArcoooAKKKKACuR+J//Ii3H/XWP/0IV11cj8T/APkRbj/rrH/6EK7cB/vdP/EvzOHMf9zq/wCF/keHUUUV+mH5cFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUABzg469s14r4l0jV9P1KWfWELtO5b7QnKOT2B7dOnHAr2qmTQRXMLQ3EaSxuMMjqCD9Qa83McAsbTUeazW3b5nqZbmDwNRy5bp79/kfP1Feh6/8ADcHdceH2weptZG/9BY/yP51wFxbT2lw0F1E8MqHDI64I/CvhMVgq+Elaqvn0Z99hMdQxcb0n8uqI6KKK4ztCiiui8F+H/wC3daBnXNpbYeb/AGvRfxx+QNbUKM69RU4bsxr1oUKUqs9kdl8PvD/9m6X/AGjcri5u1BTP8EfUfn1/Kuwoor9Lw2HhhqUaUNkfl+KxE8TWlVnuxHRZEZJFDKwwysMgj0rxPxPox0LXprQZ8k/vISe6Hp+XI/Cvba5jx3oZ1fQTPAu65s8yIB1Zf4h+Qz+HvXnZxg/rOH5o/FHVfqj0slxv1bEcsvhlo/0Z5FRRRX5+fogUUUUAFFFFAHc6F8QV0vw4tpdQSXFzB8kODhSnbcfbpwOmPrW94NvtT1+a41bUpNsCnyreCMYQHjc2OpPQZJPVq8st4JLq5it4F3yyuERfUk4Ar3XSdOj0nSbexh+7CgUn+8epP4nJ/Gvrcnq4nFTXtJe5Bfe+l+9v8j4/OqWGwkH7OPv1H9y627X/AMy3RRRX1h8gFFFFABRRRQAUUUUAFFFFABRRRQAV0PgP/ketL/66n/0E1z1dD4D/AOR60v8A66n/ANBNc2L/AN3qf4X+R1YP/eaf+Jfme/UV53c/Hr4b2d1La3niCSC4hcxyxS6bdK8bA4KsDFkEEYINRf8ADQfwx/6Gb/yQuf8A43X5efqp6TRXm3/DQfwx/wChm/8AJC5/+N0f8NB/DH/oZv8AyQuf/jdAHpNFebf8NB/DH/oZv/JC5/8AjdH/AA0H8Mf+hm/8kLn/AON0Aek0V5t/w0H8Mf8AoZv/ACQuf/jdei21zBeWsV1ZzRz28yCSKWJwySKRkMpHBBByCKAKOveHdH8UaU+m+IdOt9QtHyfLnTO0lSu5T1VgGOGUgjPBFfMvxE/Zm1TQ4ZNR8DTzazZopZ7KYL9qjAUElSMCXJDcABuVADHmvqyigD84Lm2ns7qW1vIZILiFzHLFKhV42BwVYHkEEYINbHgzwvc+NPGemeHrJxHJfTbGlIB8tACzvgkZ2orHGRnGO9fY/wARvg34Z+IsLT3cX9nasMldStI1EjnZtUSjH7xRheCQQFwGUE55z4HfBy8+HOo61qOvvBNqEpW0tZLdiUMGFdmHI+82FIZQQYjgkNyAetabp9rpGlWmm6fF5NpZwpBBHuLbERQqjJJJwAOSc1ZoooAKKK8k8ceH/jP4q3W2jax4f8OaecfJZXtwZ2+6fmn8kEfMpxsCcMQd1AG541+NXgvwPtjvdR/tG785oXs9MZJpYWXhvMG4BMHjDEHPQHBx8aeMNdg8T+MdT1y104aamoTtcG2Exl2O3LnccZy2W6ADOAAMCvVP+GVPG/8A0FfD/wD4ET//ABmj/hlTxv8A9BXw/wD+BE//AMZoA8Sor23/AIZU8b/9BXw//wCBE/8A8Zo/4ZU8b/8AQV8P/wDgRP8A/GaAPEqK9t/4ZU8b/wDQV8P/APgRP/8AGaP+GVPG/wD0FfD/AP4ET/8AxmgDy7wX4VvPGvjHTtA0/KyXkoWSUKD5MY5eQgkZ2qCcZGcYHJFff2m6fa6RpVppunxeTaWcKQQR7i2xEUKoySScADknNeY/BH4QXHw0t9Tutcls7rVrx1jSW1JdY4FAO0MyKwLMSWHQ7E9K9XoAKKKKACiub1P4geGtJ8Wad4au9Vt/7W1CYwpbLKpaE7N6+Zz8m7KqoPLF1wCMkdJQAVyPxP8A+RFuP+usf/oQrrq5H4n/APIi3H/XWP8A9CFduA/3un/iX5nDmP8AudX/AAv8jw6iiiv0w/LgooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKztY0HT9ct/K1CAMQCElXh0+h/p09q0aKicI1IuM1dMunUnTkpwdmjyHxD4H1DRd88AN5ZjnzEHzIP9pfz5HHHauZr6ErlfEHgOw1bfPZYsrs85UfI5917fUfrXyuOyHeeG+5/o/wDP7z63A8QbQxX3r9V/l9x5RBBJc3EcECF5ZGCIo7knAFe3eHtFj0HRYrOPDP8Aflf++56n6dh7AVzXgrwdcaTqM97qqKJoiY4ArZB45f8AI4H45FdxXXkuXuhF1qqtJ6ei/wCCcmeZjHESVGk7xWrfd/8AACiiivoj5oKKKKAPG/Gehf2JrziJcWtxmSHA4Hqv4H9CK5+vXPH8FhP4cf7ZcRw3EZ8y33H5mYdVA6nI/oT0ryOvzvNsLHDYlqOz19PI/ScoxUsThVKe609fP+uoUUUV5R6wUUUqqWYKoJJOAB3oA7T4baP9q1STU5lzFajbHnvIR/QZ/MV6fWX4c0ldE0G3s8L5irulI/ic8nnv6fQCtSv0nLcL9Vw0YPfd+r/qx+ZZni/rWJlNbLRei/z3CiiivQPNCiiigAooooAKKKKACiiigAooooAK6HwH/wAj1pf/AF1P/oJrnq6HwH/yPWl/9dT/AOgmubF/7vU/wv8AI6sH/vNP/EvzPRviL8JvDvxHsmOpQ/ZdVjiKW2pQj95H3AYZAkXI+63QFtpUnNfH3j34ceIPh1q62WvwK0cqhoLy3y0E3HIViB8w6FSAR1xggn75rzv466/p2g/CDV/7Uto7s6gn2G2glUkNM4JVs4IBQK0gJxzGACCQa/Lz9VPiCiiigAooooAK+p/2YfH8mraJd+D9TmaS50xPPsmckk2xIDJ04CMVxlskSAAYSvlitTwz4iv/AAl4msdd0d1W8sZfMj3glWGMMrAEHaykg4IOCeRQB+h9FZvh3XrHxR4bsNb0p99pfQrNHllLLnqjbSQGU5UjJwQR2rSoAKKKKACiiigAooooAKKKKACiiigAooooAKKZPPFa28lxcypDDEheSSRgqooGSSTwAB3rwf4m/tKafpKz6T4B8vUr4q8bamf9RbuGxlAR+9OAxB+590/OMigD2XxL4p0Xwfo7ar4k1COws1cR+Y4JLMeiqqgsx4JwATgE9Aa+XviP+0jrfiTzNO8HLNoemHbm53bbyTGc/MpxGpyOFyfl+9gla8l17xFrHijVX1LxDqNxqF2+R5k77toLFtqjoqgscKoAGeAKzaAHwzS21xHPbyPFNEweORGKsjA5BBHQg96+6vhJ45/4WB8OrLVpiPt8JNrfgD/lugGW+6B8ylXwOBvxng18JV6v+z14+i8G/EA2OpzpBpWtKtvNI5AWKVcmJydpOMlk6gDzNxPy0AfZlcj8T/8AkRbj/rrH/wChCuurkfif/wAiLcf9dY//AEIV24D/AHun/iX5nDmP+51f8L/I8Oooor9MPy4KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiuZ8TaDrF7m50TV7mGQDm280orcfwkdD9fXqKxr1JU4c0Y83kjehThVmozko+bOmqOa4htk33E0cS/3pGCj9a8O1G41aO5ktdUuLvzYzh45pWOPzNUK+aqcRcraVL73/wD6enw3zJN1fuX/BPc38RaNHnfqtnx2E6n+Rqg/jrw7GSDqIJH92Fzn8duK8borllxDiH8MEvv/wA0dceHMOvim39y/Rnq0vxK0SM4SO7l91jA/mwroNG1e31zTEvbQMsbkja+NykHGDgn6/jXhNd38MtV8q8udLlbCzDzYgT/ABD7w+pGD/wGujL85rVsSqda1n+fT/I5sxyWjQwzqUb3Wvy6/wCZ6TRRRX1p8eFFFFABRRRQAVzviK+8SJuh0DTAVxzctIhP/AUJ/nn6V0VFY1qbqw5VJx81ubUaqpT53FS8nt+aPD9Q07XZJpLnU7O+Zzy8ssTH9cVl19CVDcWdtdrtu7eKcDoJUDfzr5upw9zO8an3r/gn09LiRxVpUtPJ/pY8Bor2u68IaBdkGXS4Vx08rMf/AKCRWXP8NtDlbMb3cA/upICP/HgTXDPh/FR+Fp/16HfT4iwkviTX9ep5RXVfD/R/7S8Qi5lXMNkBIfd/4R+eT/wGteb4WH5jb6qDz8qyQf1Df0rqvC2g/wDCPaMLV2V53cvK6ZwT0GM+wH61eAyivHExlXjaK16fIjMM5w8sLKNCV5PTrpffc2aKKK+1PhgooqC2vrW8kmS1uIpngbbKEYHYfQ/57H0pOSTSfUpRbTaWxPRRRTJCiiigAooooAKKKKACiiigArofAf8AyPWl/wDXU/8AoJrnq6HwH/yPWl/9dT/6Ca5sX/u9T/C/yOrB/wC80/8AEvzPfq+PP2j/ABynij4gDSNPuJHsNDVrZ0ZNqm63ESsOMkDCpzxlCRwcn6M+Lvjj/hAPhxfarA+3UJsWthxn9+4OG5Vh8qhnwwwdm3uK+E6/Lz9VCiiigAooooAKKKKAPoT9mD4gz2+szeCdTuZJLW6RptMVySIZVy0kajacBl3PyQoKHAy5r6fr84bS6nsbyG7s5nguLeRZYpY2w0bqchgexBGa+9vhz40t/H3gTT9dh2LPInl3cKEfuZ14dcZJAz8ygnO1lJ60AdRRRRQAUUUUAFFFFABRRRQAUUUUAFcH8QvjB4X+HttNHe3aXurqp8vS7ZwZC2AQJCM+UCGU5bkjJUNjFcX+0Z408beELCwXw5PFY6Rfq0M17ChNwkuGzHuPCBlIKlfnyjYIxz8mUAdv46+Lvi7x+0kWragbfTmPGm2eY4MfKfmGcycoG+cnBzjHSuIoooAKKKKACiiigD7f+CfxCPxB8ART30qtq+nt9mvh8oLkDKS7QSQGXvgAsrgDArW+J/8AyItx/wBdY/8A0IV8pfAvx5/wg3xHtvtk/l6TqmLS93vhEyf3cpywUbW6sc4RpMDJr6t+J/8AyItx/wBdY/8A0IV24D/e6f8AiX5nDmP+51f8L/I8Oooor9MPy4KKKKACiiigAooooAKKKKACiiigAooooAKKKKACqup6hDpWmT3tyf3cK7iB1Y9gPcnAq1XmfxH177TeJpFu2Y7c75iD958cD8AfzPtXDj8WsJQdTrsvU9DL8G8ZiFT6bv0/rQ4+/vZtS1Ce8uTmWZyzY6D2HsOlV6KK/NZScm5Pdn6dGKilFbIKKKKQwq1pl/JpeqW17DndBIGwDjcO4/EZH41VoqoycZKUd0TKKnFxlsz6BgmjubeOeBt8cqh0YdwRkGn1yXw61X7d4fNpIcy2TbPqh5X+o+gFdbX6fha6xFGNVdV/w5+V4qg8PXlSfR/8N+AUUUV0HMFFFFABRRRQAUUUUAFFFFABRRUF7fWunWrXF9OkES9Wc4/Aep9hSlJRV3sVGLk7RV2T1l614j03QYt19P8AvCMrCnLt+Hpx1OBXFa/8R5pi1voKmGPkG5cfM3+6O34889q4aWWSeVpZ5Gkkc5Z3bJJ9zXzeNz2nTvDD+8+/T/gn02ByCpUtPEvlXbr/AMA6PXvHGpayGhhP2O1YYMUbfMw/2m7/AEGB9areEtdOg65HLIxFrN+7nH+z/e/A8/mO9YdFfLPGV3WVeUryR9WsFh1QdCMbRf8AX3n0ICCAQcg9CKK434ea/wDb9MOmXLZntF/d5/ii6D8un0xXZV+jYXERxNGNWHU/NcVh54WtKlPoFFFFdBzBRRRQAUUUUAFFFFABXQ+A/wDketL/AOup/wDQTXPUNrUnh21u9Wt5/s9xa2k728uzftl8phGcEEH5yvUY9eK5sX/u9T0f5HVg/wDeaf8AiX5nLftF+OP+Eq+I76VaPnT9A32qcfenJHnNyoI+ZQmMkfu8j71eSUUV+Xn6qFFFFABRRRQAUUVJbW095dRWtnDJPcTOI4ookLPIxOAqgckknAAoAjr2f9nH4i/8Iv4wPhzUpG/s3XJEji+8whus7UIAOAHyFJx1CZICmvevAvwl0jw58Lf+ES162tdTN5ul1JtrbJZW7rk5G0BVVhtPy7gFJNeafET9mBJpJdR+HU8cACAnSLp2IJCnPlysScsQoCvxksd4GAAD6NorlPhxreu614Qj/wCEu0y607W7GRrS9FxEEE7pj99HjhkbP3l+XIYDIAJ6ugAooooAKKKKACiiigAooooAxPGXhi18Z+DdT8P3zbIr6EosmCfKcEMj4BGdrhWxkA4weDXwBqWn3Wkard6bqEXk3dnM8E8e4NsdGKsMgkHBB5BxX6NV8z/tQ/D+K2mt/HGmowe6kW11IbmYFggEUgGMKNqFTyBnZgZLEgHzpRRRQAUUUUAFFFFABX1L4R8eXHjf4Azrqsyy6npVzFaTu02+WZBtKSuDyCwJXJzuMbHPUD5artfhdqDWniG8twpZb2zMR+bAUiRH3Y7/AHCP+BV25f8A73T/AMS/M4cx/wBzq/4X+R6fRRRX6YflwUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAZniLWU0LRZrxsGQDbEh/ic9B9O59ga8QlleeZ5ZmLySMWZj1JPJNdb8RdYN7rgsImPk2Yww7GQ8k/gMD65rkK+BzrFuviORfDHT59T9CyTBrD4b2kvilr8un+YUUUV4h7oUUUUAFFFdh4K8IRa3DcXepK4tcGOLadpZ+7A+35En2row2HqYmoqVPc5sTiaeFpOrU2RR8Dap/ZniiAOf3V1+4f/AIEflP8A31j8M17FXkfiDwNqGjbp7XN5aLk70HzoP9pf6j07V6T4c1Qaz4ftbwnMjJtl6D5xw3H1GfoRX12SurQcsJWVmtV+p8fnipV1DF0XdPR/oadFFFfRnzIUUUUAFFFFABRRRQAUjMEUsxCqBkkngCloIBBBGQeooA43XviJZ2O6DSFW9nHBkP8Aql/H+L8OPevONR1W91a58/Ubh537bui/QDgfhWl4u0E6DrjxxKRazfvIDzwO659j+mPWsKvzvMcXiqtV06ztZ7Lb/gn6TluDwtKlGpQV7rd7/wDACiiivKPWCiiigC5pOpzaPqsF9b8tE2SufvDuv4ivcbG9h1Gxhu7V98UyhlP9D7joa8Cr034Y37TaVd2L5P2eQOhJ7N2A+qk/jX0mQ4pwrOg9pbeq/wCAfM8QYRTorELeO/o/+CdvRRRX2p8MFFFFABRRRQAUUUUAFVNYso7/AMParDMWVVsLiYFTzmOJnH4ZUZ9qt10PgP8A5HrS/wDrqf8A0E1zYv8A3ep6P8jqwf8AvNP/ABL8z5aor0j4yfCm++HXiSW5tod/h6+mY2M8e4rDkkiBySSGUdCSdwGeoYL5vX5efqoUUUUAFFFFABXvv7Mvw5XVdWn8Y61ZLJZ2JEemiZMq9xnJlHP/ACzAAGVI3PkEMnHjHhXwzqPjHxRY6BoyxteXrlUMr7UUAFmZj6BQScZPHAJwK++/Dug2Phfw3YaJpUey0sYVhjyqhmwOXbaACzHLE4GSSe9AGlRRRQAUUUUAFFFFABRRRQAUUUUAFFY3iTxPZeGIdOe+3F9S1G3062RQcvLK+0c4wAF3Mc44XHUgVs0AFZviLQbHxR4bv9E1WPfaX0LQyYVSy56Ou4EBlOGBwcEA9q0qKAPzx8T+HNQ8I+Jr7QtYRVvLKTy32HKsMAqyk4O1lIIyAcEcCsqvqD9qPwG17pdt43s3dpLBEs7yI7dohZ22SDJByHfaQM53g8BTn5foAKKKKACiiigArtvhhpV3ea5d38MTfZbC33TylTtBdgqrnGNxySAcZCt6Vy2jaNqPiHWbbSdFtJLy+un2Qwxjlj1+gAAJJOAACSQBX1z/AMIHb/Dv4FrosbCS6aaO4vpVcsslwxUMVzjCgKFHA4UEjJNduX/73T9V+Zw5j/udX/C/yPPaKKK/TD8uCiiigAooooAKKKKACiiigAooooAKKKKACoby5SysZ7qXOyCNpGx6AZP8qmrC8bStD4N1BkJBKqvHozqD+hrGvU9lRlU7Jv7kb4en7WtCn3aX3s8cnnkubmWedt0srl3b1JOSajoor8tbbd2fq6SSsgooopDCiiigC7o+lzazqsFjb8NI3zNjIRe7H6CvcLGyg06xhtLRAkMKhVH9T7nqT61zHw/0D+zdJ+33CYubxQVyOUj6gfj1/L0rrq+8yXA/V6PtJr3pfguh+f53jvrFf2UH7sfxfX/IKht7S3tDKbaFIvOfzHCDAZiME49eKmor3LJu54N2lZBRRRTEFFFFABRRRQAUUUUAFFFFAGH4t0Ea9obxRqPtUP7yA8ct/dz6Hp+R7V4uQVYhgQQcEHtX0JXlnxD0H+z9UGpW6Yt7xvnx/DJ3/Pr9c18tn2C5orEwWq0fp0Z9Zw/juWTws3o9V69UcdRRRXx59mFFFFABXafDCVh4guogfla1LEe4ZcfzNcXXoPwusTuvtQZflwsKN6/xMP8A0H869TKYyljYW/rQ8rOJRjganN/Wp6HRRRX6KfmoUUUUAFFFFABRRRQAV0PgP/ketL/66n/0E1z1dD4D/wCR60v/AK6n/wBBNc2L/wB3qf4X+R1YP/eaf+Jfmd18Tb3T/DtobnxLpo1HwhrEgtNbjERZrVyAIrr5Vzt+UIx3ZBEJTDAh/AfGXwGvI7SLX/hhO/ijw5cQ+YjRyI9xGRwwwAPM5B4UbgcqV+XJ+uNU0yz1rSbrTNThE9neQtDPESRvRhgjIwRweo5FfEF/J4x+Cfj7UNN0vU7vT54pDtkVQIr2L5hHKYyWRgVYkA7tpJHDA1+Xn6qcTc209ndS2t5DJBcQuY5YpUKvGwOCrA8ggjBBqOvfrf8AaP0XxALGL4j+ANO1QwF911EiS+Xu/wCecMqnGcID+85xn0FZj+Jv2emjZV8D+IUJGAyztlfcZusUAeKUV6rf3vwIvPL+z6Z41sNmd32Zrc7846+Y7dMdsdabp158CbK682507xtqKYx5Ny1sqdQc/u3Ru2Ovc+1AHsX7Nvw4/wCEd8MHxXqkRXU9YixbjfkR2h2svGOGcjd1PyhOh3Cvbq8S/wCGq/BH/QK8Qf8AgPB/8eo/4ar8Ef8AQK8Qf+A8H/x6gD22ivEv+Gq/BH/QK8Qf+A8H/wAeo/4ar8Ef9ArxB/4Dwf8Ax6gD22ivEv8AhqvwR/0CvEH/AIDwf/HqP+Gq/BH/AECvEH/gPB/8eoA9torxL/hqvwR/0CvEH/gPB/8AHq9S8HeK7Hxv4Ts/EOlRXENpeb/LS5VVkGx2Q5Ckjqp79KANuiiigAoorzL47/EIeBfAEsNlK0esaur21kU3AxjAEkoYEFSqsMEHIZlOCAaAPHfGXxF/4Tv9o7wtb2Eivo+j63b29oy7WErG4QSShlzlWKjbzjaqnAJNfV9fnl4T1WDQfGmiaveJI9vp+oQXUqxAF2VJFYhQSBnA4yRX1B/w1X4I/wCgV4g/8B4P/j1AHttFeJf8NV+CP+gV4g/8B4P/AI9R/wANV+CP+gV4g/8AAeD/AOPUAey6hYW2q6ZdaffxCa1u4XgnjJI3owKsMjnkE9K+DfiR4Mn8A+PNR0KUSNbxv5lnLID++gblGztUMQPlYgY3KwHSvo3/AIar8Ef9ArxB/wCA8H/x6uW8WfGH4M+Obq3uvFHhHXL24tkMccoRInCk52kpcKWAOSAc4ycYycgHzlRXtv8AwlH7PP8A0IniD/v+/wD8lVe0rx/8AtGumuLPwBqkjshQi8hS6TGQeElnZQeOoGeozyaAPCLa2nvLqK1s4ZJ7iZxHFFEhZ5GJwFUDkkk4AFemeD/2ffHHim4ie9sG0GwY/PcaipRwAwBCw/fLYJI3BVOPvDiu8T9pPwn4buJI/BPw8jt7aZQZXVorJnYE4BWNHBAB4JPc8dz5x40+OfjbxtZfYru9i02xZCsttpitCswIYEOSxZgQxBXO08cZ5oA9n+G9r4C8Ia8fCnw/vrjxD4l1GHbfa5bqjR2MQRCzrJsZFXJyqgSAybUkboR6J8RrdLT4dvbxGRkhaFFMsjSOQCANzMSzH1JJJ6k1xf7N/wAPD4Y8HN4j1OGMalraJJCcqxitcBkGccFydxAPIEeQCpFdz8T/APkRbj/rrH/6EK7cB/vdP/EvzOHMf9zq/wCF/keHUUUV+mH5cFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFZHiuyfUPCt/bwglzHvUAZLFSGwPc4xWvRWdWmqtOUHs0195pSqOlUjUW6af3Hz3RXT+OdAGja0Z7dNtpdkugAwEb+Jf6j2OO1cxX5jiKE8PVlSnuj9Uw9eGIpRqw2YUUUVgbhXQ+DPD/8AbutAzrm0tsPN/tei/jj8gawYYZLidIYULySMFRR1JPAFe2+HNFj0HRYrNMGT78zj+Jz1P07D2Ar2cowP1qvzS+GO/n2R4mcY76rQ5Yv3paLy7s1KKKK/QD87CiiigAooooAKKKKACiiigApqSJIu6NgwyRkHPIOCPzFcx438T/2Jp/2W0b/TrhflIP8Aql6Fvr2Hvz2q74LOfB2n5/uN/wChGuOOLhLEvDx3Su/w0O2WDnDCrEy0Tdl+OpuUUUV2HEFUtX0yHWNJnsbjhZVwG/ut2P4GrtFTKMZxcZK6ZUJyhJSi7NHgN5aTWF7La3KbJYXKMPcf0qGvT/HHhCfV7iK+0mJWucbJk3Bd47Nk45HT6Y9K5L/hA/Ef/QPH/f8Aj/8Aiq/PMVlmIo1pQhByXRpNn6Rhc0w1ajGc5qL6ptLU52iuotvh3r87Yligtx6yzAj/AMdzW5pvwwRWV9Wvt4/iit1xz/vHt+FTSyrGVXpBr10/MdXNsFSV3UT9NfyOL0bRL3Xb0W9jFuxjfIfuxj1Jr2jSdMg0fS4bG1HyRLyx6s3dj9TUljYWum2q21jAkEK9FUfqT3PuabDfxXN9Lb2rLJ9n4mYchW7Ln17n0/Gvrsvy6ngVeTvN6f8AAR8fmOZVMe7RVoR1/wCC/wBC1RRRXsniBRRRQAUUUUAFFFFABXQ+A/8AketL/wCup/8AQTXPV0PgP/ketL/66n/0E1zYv/d6n+F/kdWD/wB5p/4l+Z79XiX7THgP+3/BsXibT4N1/oufP2JlpLVj82cKSdjYbkhVUymvbaK/Lz9VPzcorufi94Bl+H/xAvLGKB00q5Y3GnSEHaYm52AlmJKElDk5OAxHzCuGoAKKKKACiiigAooooAKKKKACvtr9nz/khPh7/t5/9KZa+Ja+2v2fP+SE+Hv+3n/0ploA9JooooAjubmCztZbq8mjgt4UMkssrhUjUDJZieAABkk18LfF3xx/wn/xHvtVgbdYQ4tbDjH7hCcN91T8zFnwwyN+M8Cvfv2l/iANB8JJ4V06dk1HWBuuChIMdqCc8hgQXYbcYIKiQHHFfJdABRRRQAUUUUAFFFFABRRRQAV3fwg+H0/xB8e2lpLbSSaRaus2pSgHYsYyRGSGUgyEbBg7hksAQprhK+2vgX4D/wCEG+HFt9sg8rVtUxd3u9MOmR+7iOVDDavVTnDtJg4NAHpNcj8T/wDkRbj/AK6x/wDoQrrq5H4n/wDIi3H/AF1j/wDQhXbgP97p/wCJfmcOY/7nV/wv8jw6iiiv0w/LgooooAKKKKACiiigAooooAKKKKACiiigAooooAzPEOjR67os1k+A5G6Jz/A46H6dj7E14jNDJb3EkM6lJI2KOp7EHBFfQNec/EjQdkqazbKdr4juAOx6K39Py9a+az3Be0p/WIbx39P+AfT5BjvZ1Pq09pbev/B/M4GiirmkabJq+r21jDwZnwW/ur1J/AAmvjYRlOSjHdn205xhFylsjsvhx4fLytrV0nyplLYEdT0Zvw6fn6V3Wq6ra6Np0l7fMVjTgBeWY9gB3NT2ttFZ2kVtbJsiiQIi+gFeUeOvEB1fWWtoHzaWhKIAeHf+Jv6D2+tfc1JQyjBKMdZP8X39F/kfBU4TzjHOUtIr8F0Xq/8AM6wfEzRT1gvR9Y1/+Kp4+JOhnql2PrEP8a8oorwf7exnl9x9B/YGC8/vPWl+Iugt1e4X6xVKvxA8PN1u3X6wv/hXkFFUs/xa6L7n/mS+HsG+svvX+R7H/wAJ54b/AOgj/wCQJP8A4mtbTNVstYtTc6dN50QYoW2MvIxxggeteDV6v8NxjwqT63Dn9BXq5Zm1fF1/ZzSta+l/8zyc0yjD4PD+1ptt3S1t/kdbRRRX0p8uFZ+uaxBoWky3tx823iOPODIx6L/nsDV2aaO3heaZwkcalnZjwoHU1414q8RSeIdWMi7ltYsrBGT2/vH3P+A7V5WZ49YOlp8T2/z+R62V5e8bW1+Fb/5fMzNQv59T1Ca8u23SzNubHQegHsBxXqHhLXNKtfCljDc6jaxSohDI8ygj5j1Ga8mor4zB4+eEqyqpXb7/AHn2+Ny+ni6MaTfKl29LHuX/AAkei/8AQWsv+/6/40f8JHov/QWsv+/6/wCNeG0V6v8ArFW/kX4nkf6t0f53+B7l/wAJHov/AEFrL/v+v+NH/CR6L/0FrL/v+v8AjXhtFH+sVb+RfiH+rdH+d/ge5f8ACR6L/wBBay/7/r/jR/wkei/9Bay/8CF/xrw2ij/WKt/IvxD/AFbo/wA7/A9vl8T6HCpZ9VtCB/clDH8hWVd/EXQrcfuHnujj/llEQB9d2K8lorOpxBiZK0YpGtPh3Cxd5yb/AAOu1Tx7q+sOtrpsf2NZSFCwktIxPGN319ADXofh7R00PRIbNMFwN0rj+Jz1P9B7AVwnw40MXeoSarcJmK1O2LPeQjr+AP5kelenV7GUQrVYvFV3dvReS/4J4uc1KNKSwmHVktX5v9bBRRRXvnzwUUUUAFFFFABRRRQAV0PgP/ketL/66n/0E1z1dD4D/wCR60v/AK6n/wBBNc2L/wB3qf4X+R1YP/eaf+Jfme/UUUV+Xn6qeZfHb4dp478BS3FpDJJrOjo9xYhGY+YODJFtAO4sqfKAM7goyATn4pr9I6+Mf2gPh7D4H8eLdaVAkGkayrT28UahVhkUgSxqAegLKw4AAfaPu0AeVUUUUAFFFFABRRRQAUUUUAFfbX7Pn/JCfD3/AG8/+lMtfEtfbX7Pn/JCfD3/AG8/+lMtAHpNZ+va5YeGtBvNY1idbeys4jLK7EDgdAM9WJwAO5IA61oV4/8AtMrrR+EsjaVJGNOF1ENUjMYLtHuGwhieAJAmQAScjkAMCAfK/jLxPdeM/GWp+IL5dkt9MXWPIPlIAFRMgDO1Aq5wCcZPJrEoooAKKKKACiiigAooooAKKKktrae8uora0hknuJnEcUUSFnkYnAVQOSSTgAUAepfs+/D6Dxt48a71a2judI0dBNcRSgMk0jZEUbDcDjIZzwVPl7SMNX2bXK/DbwTb+APAdhocIRrhV829lQ5EtwwG9gcDIB+VcjO1VB6V1VABXI/E/wD5EW4/66x/+hCuurkfif8A8iLcf9dY/wD0IV24D/e6f+JfmcOY/wC51f8AC/yPDqKKK/TD8uCiiigAooooAKKKKACiiigAooooAKKKKACiiigAqG8tIb+zltbpA8MylXU+h/rU1FJpSVmNNxd1ueE6zpU2i6tPYz5Jjb5XxjevZvxH+Fdf8MNO33N5qLqf3aiGNiOMnlvxAC/nWx8QdA/tLSf7Qt1zc2aktj+OPqR+HX8/WnfDeMJ4VLDrJcOx/ID+lfI4bL/q+aKL+FXa/ryPssVmP1jKnNfE7Rf9eZpeL9WOj+GrieNts0g8qEg4IZu49wMn8K8Wr0X4pzOsGmwhv3btI7L6kBQD/wCPH8686riz2s54vk6RS/HU7cgoqng/adZN/hoFFFFeEe+FFFFABXrfw6GPCKe8zn9a8kr174fDHg+395HP/jxr38g/3t+j/NHz3EP+5r/EvyZ01FFc5431m50fQC1lG/mTt5XnL0iyOv19P85+0r1o0KUqstkfD0KMq9WNKG7OX+IHif7VM2jWTfuYm/0hwfvsP4foD19/pzw1FFfm2KxM8VVdWfX8F2P0/CYWGEoqlDp+L7hRRRXKdQUUUUAFFFFABRRRQAVNaWs19eRWtsm+WZwiD3NQ16D8NdCy0ms3C8DMdvn1/ib+n/fVdmCwssVXjSXz9Dix2KjhKEqr+Xr0O30nTYtI0m3sYOVhTBbH3j1J/EkmrlFFfpcYqEVGOyPy+cpTk5S3YUUUVRIUUUUAFFFFABRRRQAV0PgP/ketL/66n/0E1z1dD4D/AOR60v8A66n/ANBNc2L/AN3qf4X+R1YP/eaf+Jfme/UUUV+Xn6qFcr8SfBUHj/wHf6HKEW4dfNs5XOBFcKCUbO0kAn5WwM7WYDrXVUUAfnBc209ndS213DJBcQuY5YpUKvGwOCrA8ggjBBqOvoL9pv4d3NvrQ8b6ZbA2NwkcOoGPczJMMqsjDoqlQiZGBuA7tz8+0AFFFFABRRRQAUUUUAFfbX7Pn/JCfD3/AG8/+lMtfEtfbX7Pn/JCfD3/AG8/+lMtAHpNQXtlb6jp9xY30Sz21zE0M0TdHRhhlPsQSKnooA+BfiR4Ln8A+PNR0KUSNbxv5lnLID++gblGztUMQPlYgY3KwHSuWr7J/aG8AR+LPh/LrFqsaanoSPdLIQcyQBSZY+uOgDAkHlMDG4mvjagAooooAKKKKACiiigAr3z9l/wGuqa9d+MNRgSS100m3stxz/pJALPgH+BCOoxmQEcrx5z8OPhXr3xJ1Py9NT7Lp0T7bnUpo2MUeMZVcfffDAhMjtkgHNfa3hXwzp3g7wvY6BoyyLZ2SFUMr7nYlizMx9SzEnGBzwAMCgDXooooAK5H4n/8iLcf9dY//QhXXVyPxP8A+RFuP+usf/oQrtwH+90/8S/M4cx/3Or/AIX+R4dRRRX6YflwUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABWToWmLo32yziBEDTmeEY4VWA+XPsQ34Eeta1FRKnGUlPqv1NI1JRg4LZ/ocD8UoJGtdNuAP3cbyIx9CwUj/0E15zXuPiLR113RJ7IkLIRuic/wuOh+nY+xNeJ3VrNZXUltdRtFNG210bqDXxOfYeUMT7XpL81ofc5BiY1ML7HrG/3PUiooor58+iCiiigAr2HwCMeDLP3aQ/+PtXj1ex+A/8AkSbD/tp/6MavoeH/APepf4X+aPnOIv8AdI/4l+TOhqG8s4L+zltbuMSQyrtdT3/+v71NRX27SkrM+ETcXdbnh/iHQp/D+qvazfNGfmhk/vr6/X1FZde2+JdAh8Q6U1u+1Z0y0Ep/gb/A9/8A6wrxe5tprO6kt7mMxyxMVdT2Ir8+zTL3g6t4/A9v8j9GyrMFjKVpfGt/8yKiiivIPYCiiigAooooAKKKKALWl6fLquqW9jb/AH5n25x90dz+Ayfwr3Oxs4dPsYbS1XbFCgVR/U+56muP+HXh97K1k1S8jKS3C7YQw5EfXP4nH4D3rt6+6yTB+wo+1mvel+X/AAd/uPgc9xvt6/soP3Y/n/wNvvCiiivfPngooooAKKKKACiiigAooooAK6HwH/yPWl/9dT/6Ca56uh8B/wDI9aX/ANdT/wCgmubF/wC71P8AC/yOrB/7zT/xL8z36iiivy8/VQooooAZLFHPC8M8ayxSKVdHXKsDwQQeorwz4jfsz6Xrsx1DwLLb6JdtkyWUoY20rF87gRkxYBb5VUrwoAXkn3aigD4R1v4P+PtC1E2lz4W1K6ONyy2EDXMbLkgHdGCBnGcHDYxkDNcnqGm32kX8ljqtncWN3FjzLe5iaORMgEZVgCMgg/Q1+jVFAH5uUV+kdFAH5uUV+kdFAH5uV9tfs+f8kJ8Pf9vP/pTLXpNFABRRRQAV8S/HTwH/AMIN8R7n7FB5Wk6pm7stiYRMn95EMKFG1uijOEaPJya+2q4j4u+Bv+E/+HN9pcCbtQg/0qw5x+/QHC8so+YFkyxwN+7HAoA+F7a2nvLqK1s4ZJ7iZxHFFEhZ5GJwFUDkkk4AFdB/wrjxv/0JviD/AMFc/wD8TUvgG3ns/i74ZtruGSCeHXbWOWKVSrRsJ1BUg8ggjBBr76oA+AP+FceN/wDoTfEH/grn/wDiaP8AhXHjf/oTfEH/AIK5/wD4mvv+igD4Ftvhj46urqK3i8H64rzOEUy6fLGgJOBudgFUepJAHUmvWfAv7L2rSaxZ3njye1h01V8yawtZ2ad27RMwG1V9WVicDAxncPqGigCjo2jad4e0a20nRbSOzsbVNkMMY4UdevUkkkknJJJJJJq9RRQAUUUUAFcj8T/+RFuP+usf/oQrrq5H4n/8iLcf9dY//QhXbgP97p/4l+Zw5j/udX/C/wAjw6iiiv0w/LgooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigArD8ReFLHxFGGmzBcoMJcIOfoR3H+cjmtyisqtKnWg4VFdM1o1qlGanTdmjx3VPA2t6YxK25vIs8SW/wAx/Fev6Y96550eOQpIrI6nBVhgg19B0V89V4epSd6c2vlf/I+ko8SVYxtVgpejt/mfPdFfQZVW+8oP1FMNtA33oYz9UFYPhx9Kv4f8E6FxKutL8f8AgHz/AF7H4E/5Emw/7af+jGrZOn2TfetID9Yh/hU0UUcEYjhjWNB0VFwB+Fd+XZTLBVnUc73VtvNf5HnZlm8cdRVNQtZ338n/AJjqKKK94+fCuN8eeF/7StTqdhHm7hX96q9ZUH8yP1HHoK7KiufE4eGJpOlPZnThcTUwtVVae6/HyPnuiux8eeF/7Luv7SsI8Wc7fvFXpE59uwP6Hj0ro/CXhzR7rwzZXVzp8Ms0iks7jOfmIr4WnlVaeJlh20mtfVeR99VzehTw0cSk2np6PzPK6K9zHh3RR/zCbH/wHX/CnDQNHX7ulWI+lsn+Feh/q7V/nR53+slH/n2/wPCqkhgmuZBHbxPK56LGpYn8BXuqaVp0ZzHYWqkf3YVH9KtgYGBwK0jw4/tVPw/4JlLiVfZpfj/wDxvT/BGu6gQfsZtkP8dydmPw+9+ldxoPw/0/S2S4vm+23K8gMMRqfZe/1P5Cusor1sNk+Fw75rcz8/8AI8jFZ1isQuW/KvL/ADCiiivYPFCiiigAooooAKKKKACiiigAooooAK6HwH/yPWl/9dT/AOgmueq5pepT6RqkN/aBDNASybxkZxjp+NY4iDqUZwju01+Bvh5qnWhOWyaf4n0nRXiv/C1vEf8A06f9+T/jR/wtbxH/ANOn/fk/418V/YOM8vv/AOAfcf6wYPz+7/gntVFeK/8AC1vEf/Tp/wB+T/jR/wALW8R/9On/AH5P+NH9g4zy+/8A4Af6wYPz+7/gntVFeK/8LW8R/wDTp/35P+NH/C1vEf8A06f9+T/jR/YOM8vv/wCAH+sGD8/u/wCCe1UV4r/wtbxH/wBOn/fk/wCNH/C1vEf/AE6f9+T/AI0f2DjPL7/+AH+sGD8/u/4J7VRXiv8AwtbxH/06f9+T/jR/wtbxH/06f9+T/jR/YOM8vv8A+AH+sGD8/u/4J7VRXiv/AAtbxH/06f8Afk/40f8AC1vEf/Tp/wB+T/jR/YOM8vv/AOAH+sGD8/u/4J7VRXiv/C1vEf8A06f9+T/jR/wtbxH/ANOn/fk/40f2DjPL7/8AgB/rBg/P7v8AgntVFeK/8LW8R/8ATp/35P8AjR/wtbxH/wBOn/fk/wCNH9g4zy+//gB/rBg/P7v+Ce1UV4r/AMLW8R/9On/fk/40f8LW8R/9On/fk/40f2DjPL7/APgB/rBg/P7v+Cc58T/h2+hfHvwn4v06GNNM1bXbJLgKyr5d35oJ+UAcOq7s8ktvJIyufo2vDL/4i6zqdukF9FaSxJNFOq+Wy4eKRZEPDdnRTjocYORVn/ha3iP/AKdP+/J/xo/sHGeX3/8AAD/WDB+f3f8ABPaqK8V/4Wt4j/6dP+/J/wAaP+FreI/+nT/vyf8AGj+wcZ5ff/wA/wBYMH5/d/wT2qivFf8Aha3iP/p0/wC/J/xo/wCFreI/+nT/AL8n/Gj+wcZ5ff8A8AP9YMH5/d/wT2qivFf+FreI/wDp0/78n/Gj/ha3iP8A6dP+/J/xo/sHGeX3/wDAD/WDB+f3f8E9qorxX/ha3iP/AKdP+/J/xo/4Wt4j/wCnT/vyf8aP7Bxnl9//AAA/1gwfn93/AAT2quR+J/8AyItx/wBdY/8A0IVwf/C1vEf/AE6f9+T/AI1Q1rx7rGvaW9hfi38lyGOyMg5ByOc10YXJcVSrwqStZNPc5sXneErYedON7tNbHM0UUV9mfEhRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAEV1aw3trJbXUYkhlUq6HuKraNpw0jSYbFX3rDuCsepBYkZ98Gr1FR7OPPz21tb5GntJcns76Xv8woooqzMKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/2Q==";

export default class App extends Component {
    _listeners = [];

    constructor() {
        super();
        this.state = {
            devices: null,
            pairedDs: ds.cloneWithRows([]),
            foundDs: ds.cloneWithRows([]),
            bleOpend: false,
            loading: true,
            boundAddress: '',
            debugMsg: ''
        }
    }

    componentDidMount() {//alert(BluetoothManager)
        BluetoothManager.isBluetoothEnabled().then((enabled)=> {
            this.setState({
                bleOpend: Boolean(enabled),
                loading: false
            })
        }, (err)=> {
            err
        });

        if (Platform.OS === 'ios') {
            let bluetoothManagerEmitter = new NativeEventEmitter(BluetoothManager);
            this._listeners.push(bluetoothManagerEmitter.addListener(BluetoothManager.EVENT_DEVICE_ALREADY_PAIRED,
                (rsp)=> {
                    this._deviceAlreadPaired(rsp)
                }));
            this._listeners.push(bluetoothManagerEmitter.addListener(BluetoothManager.EVENT_DEVICE_FOUND, (rsp)=> {
                this._deviceFoundEvent(rsp)
            }));
            this._listeners.push(bluetoothManagerEmitter.addListener(BluetoothManager.EVENT_CONNECTION_LOST, ()=> {
                this.setState({
                    name: '',
                    boundAddress: ''
                });
            }));
        } else if (Platform.OS === 'android') {
            this._listeners.push(DeviceEventEmitter.addListener(
                BluetoothManager.EVENT_DEVICE_ALREADY_PAIRED, (rsp)=> {
                    this._deviceAlreadPaired(rsp)
                }));
            this._listeners.push(DeviceEventEmitter.addListener(
                BluetoothManager.EVENT_DEVICE_FOUND, (rsp)=> {
                    this._deviceFoundEvent(rsp)
                }));
            this._listeners.push(DeviceEventEmitter.addListener(
                BluetoothManager.EVENT_CONNECTION_LOST, ()=> {
                    this.setState({
                        name: '',
                        boundAddress: ''
                    });
                }
            ))
        }
    }

    componentWillUnmount() {
        for (let ls in this._listeners) {
            this._listeners[ls].remove();
        }
    }

    _deviceAlreadPaired(rsp) {
        var ds = null;
        if (typeof(rsp.devices) == 'object') {
            ds = rsp.devices;
        } else {
            try {
                ds = JSON.parse(rsp.devices);
            } catch (e) {
            }
        }
        this.paired = ds || []
        this.setState({
            pairedDs: this.state.pairedDs.cloneWithRows(this.paired)
        });
    }

    _deviceFoundEvent(rsp) {//alert(JSON.stringify(rsp))
        var r = null;
        try {
            if (typeof(rsp.device) == "object") {
                r = rsp.device;
            } else {
                r = JSON.parse(rsp.device);
            }
        } catch (e) {//alert(e.message);
            //ignore
        }
        //alert('f')
        if (r) {
            if (!this.found || !this.found.push){
                this.found = []
            };
            this.found.push(r);
            this.setState({
                foundDs: this.state.foundDs.cloneWithRows(this.found)
            });
        }
    }

    render() {
        return (
            <View style={styles.container}>
                <Text>{this.state.debugMsg}</Text>
                <Text>Blutooth Opended:</Text><Switch value={this.state.bleOpend} onValueChange={(v)=>{
           this.setState({
              loading:true
          })
           if(!v){
            BluetoothManager.disableBluetooth().then(()=>{
              this.setState({
               bleOpend:false,
               loading:false,
               foundDs:this.state.foundDs.cloneWithRows([]),
               pairedDs:this.state.pairedDs.cloneWithRows([])
           });
              this.paired = [];
              this.found = [];
          },(err)=>{alert(err)});

        }else{
            BluetoothManager.enableBluetooth().then((r)=>{
                var paired = [];
                if(r && r.length>0){
                    for(var i=0;i<r.length;i++){
                        try{
                            paired.push(JSON.parse(r[i]));
                        }catch(e){
                            //ignore
                        }
                    }
                }
                this.setState({
                   bleOpend:true,
                   loading:false,
                   pairedDs:this.state.pairedDs.cloneWithRows(paired)
               })
            },(err)=>{
               this.setState({
                  loading:false
              })
               alert(err)
           });
        }
    }}/>
                <Text>Connected:{!this.state.name ? 'No Devices' : this.state.name}</Text>
                <Button disabled={this.state.loading || !this.state.bleOpend} onPress={()=>{
                    this._scan();
                    }} title="Scan"/>
                <Text>Open BLE Before Scanning</Text>
                <Button disabled={this.state.loading || !(this.state.bleOpend && this.state.boundAddress.length > 0 )}
                        title="Self Test" onPress={()=>{
                    this._selfTest()
                    }}/>
                <Button disabled={this.state.loading|| !(this.state.bleOpend && this.state.boundAddress.length > 0) }
                        title="Print Label" onPress={()=>{
                     BluetoothTscPrinter.printLabel(
                     {
                        width: 40,
                        height: 30,
                        gap: 20,
                        direction: BluetoothTscPrinter.DIRECTION.FORWARD,
                        reference: [0, 0],
                        tear: BluetoothTscPrinter.TEAR.ON,
                        sound: 1,
                        text: [{
                            text: 'I am a testing txt',
                            x: 20,
                            y: 0,
                            fonttype: BluetoothTscPrinter.FONTTYPE.SIMPLIFIED_CHINESE,
                            rotation: BluetoothTscPrinter.ROTATION.ROTATION_0,
                            xscal:BluetoothTscPrinter.FONTMUL.MUL_1,
                            yscal: BluetoothTscPrinter.FONTMUL.MUL_1
                        },{
                            text: '你在说什么呢?',
                            x: 20,
                            y: 50,
                            fonttype: BluetoothTscPrinter.FONTTYPE.SIMPLIFIED_CHINESE,
                            rotation: BluetoothTscPrinter.ROTATION.ROTATION_0,
                            xscal:BluetoothTscPrinter.FONTMUL.MUL_1,
                            yscal: BluetoothTscPrinter.FONTMUL.MUL_1
                        }],
                        qrcode: [{x: 20, y: 96, level: BluetoothTscPrinter.EEC.LEVEL_L, width: 3, rotation: BluetoothTscPrinter.ROTATION.ROTATION_0, code: 'show me the money'}],
                        barcode: [{x: 120, y:96, type: BluetoothTscPrinter.BARCODETYPE.CODE128, height: 40, readable: 1, rotation: BluetoothTscPrinter.ROTATION.ROTATION_0, code: '1234567890'}],
                        image: [{x: 160, y: 160, mode: BluetoothTscPrinter.BITMAP_MODE.OVERWRITE,width: 60,image: base64Image}]
                    }
                    ).then(()=>{alert("done")},(err)=>{alert(err)});

                 }
             }/>
                <Button disabled={this.state.loading || !(this.state.bleOpend && this.state.boundAddress.length > 0)}
                        title="Print Receipt" onPress={async ()=>{
                      try{
      await BluetoothEscposPrinter.printerInit();
      await BluetoothEscposPrinter.printerLeftSpace(0);
      await BluetoothEscposPrinter.printBarCode("123456789012", BluetoothEscposPrinter.BARCODETYPE.JAN13, 3, 120, 0, 2);
     await  BluetoothEscposPrinter.printQRCode("你是不是傻？",280,BluetoothEscposPrinter.ERROR_CORRECTION.L);//.then(()=>{alert('done')},(err)=>{alert(err)});
    await BluetoothEscposPrinter.printerUnderLine(2);
      await  BluetoothEscposPrinter.printText("中国话\r\n",{
        encoding:'GBK',
        codepage:0,
        widthtimes:0,
        heigthtimes:0,
        fonttype:1
    });
      await BluetoothEscposPrinter.printerUnderLine(0);
      await BluetoothEscposPrinter.rotate(BluetoothEscposPrinter.ROTATION.ON);
      await  BluetoothEscposPrinter.printText("中国话中国话中国话中国话中国话\r\n",{
        encoding:'GBK',
        codepage:0,
        widthtimes:0,
        heigthtimes:0,
        fonttype:1
    });
      await BluetoothEscposPrinter.rotate(BluetoothEscposPrinter.ROTATION.OFF);
      await  BluetoothEscposPrinter.printText("中国话中国话中国话中国话中国话\r\n",{
        encoding:'GBK',
        codepage:0,
        widthtimes:0,
        heigthtimes:0,
        fonttype:1
    });
      await BluetoothEscposPrinter.printerLeftSpace(0);
      await BluetoothEscposPrinter.printColumn([BluetoothEscposPrinter.width58/8/3,BluetoothEscposPrinter.width58/8/3-1,BluetoothEscposPrinter.width58/8/3-1],
        [BluetoothEscposPrinter.ALIGN.CENTER,BluetoothEscposPrinter.ALIGN.CENTER,BluetoothEscposPrinter.ALIGN.CENTER],
        ["我就是一个测试看看很长会怎么样的啦",'testing','223344'],{fonttype:1});


      await BluetoothEscposPrinter.printerAlign(BluetoothEscposPrinter.ALIGN.CENTER);
      await BluetoothEscposPrinter.setBlob(0);
      await  BluetoothEscposPrinter.printText("广州俊烨\r\n",{
        encoding:'GBK',
        codepage:0,
        widthtimes:3,
        heigthtimes:3,
        fonttype:1
    });
      await BluetoothEscposPrinter.setBlob(0);
      await  BluetoothEscposPrinter.printText("销售单\r\n",{
        encoding:'GBK',
        codepage:0,
        widthtimes:0,
        heigthtimes:0,
        fonttype:1
    });
      await BluetoothEscposPrinter.printerAlign(BluetoothEscposPrinter.ALIGN.LEFT);
      await  BluetoothEscposPrinter.printText("客户：零售客户\r\n",{});
      await  BluetoothEscposPrinter.printText("单号：xsd201909210000001\r\n",{});
      await  BluetoothEscposPrinter.printText("日期："+(dateFormat(new Date(), "yyyy-mm-dd h:MM:ss"))+"\r\n",{});
      await  BluetoothEscposPrinter.printText("销售员：18664896621\r\n",{});
      await  BluetoothEscposPrinter.printText("--------------------------------\r\n",{});
      let columnWidths = [12,6,6,8];
      await BluetoothEscposPrinter.printColumn(columnWidths,
        [BluetoothEscposPrinter.ALIGN.LEFT,BluetoothEscposPrinter.ALIGN.CENTER,BluetoothEscposPrinter.ALIGN.CENTER,BluetoothEscposPrinter.ALIGN.RIGHT],
        ["商品",'数量','单价','金额'],{});
      await BluetoothEscposPrinter.printColumn(columnWidths,
        [BluetoothEscposPrinter.ALIGN.LEFT,BluetoothEscposPrinter.ALIGN.LEFT,BluetoothEscposPrinter.ALIGN.CENTER,BluetoothEscposPrinter.ALIGN.RIGHT],
        ["React-Native定制开发我是比较长的位置你稍微看看是不是这样?",'1','32000','32000'],{});
          await  BluetoothEscposPrinter.printText("\r\n",{});
        await BluetoothEscposPrinter.printColumn(columnWidths,
        [BluetoothEscposPrinter.ALIGN.LEFT,BluetoothEscposPrinter.ALIGN.LEFT,BluetoothEscposPrinter.ALIGN.CENTER,BluetoothEscposPrinter.ALIGN.RIGHT],
        ["React-Native定制开发我是比较长的位置你稍微看看是不是这样?",'1','32000','32000'],{});
      await  BluetoothEscposPrinter.printText("\r\n",{});
      await  BluetoothEscposPrinter.printText("--------------------------------\r\n",{});
      await BluetoothEscposPrinter.printColumn([12,8,12],
        [BluetoothEscposPrinter.ALIGN.LEFT,BluetoothEscposPrinter.ALIGN.LEFT,BluetoothEscposPrinter.ALIGN.RIGHT],
        ["合计",'2','64000'],{});
      await  BluetoothEscposPrinter.printText("\r\n",{});
      await  BluetoothEscposPrinter.printText("折扣率：100%\r\n",{});
      await  BluetoothEscposPrinter.printText("折扣后应收：64000.00\r\n",{});
      await  BluetoothEscposPrinter.printText("会员卡支付：0.00\r\n",{});
      await  BluetoothEscposPrinter.printText("积分抵扣：0.00\r\n",{});
      await  BluetoothEscposPrinter.printText("支付金额：64000.00\r\n",{});
      await  BluetoothEscposPrinter.printText("结算账户：现金账户\r\n",{});
      await  BluetoothEscposPrinter.printText("备注：无\r\n",{});
      await  BluetoothEscposPrinter.printText("快递单号：无\r\n",{});
      await  BluetoothEscposPrinter.printText("打印时间："+(dateFormat(new Date(), "yyyy-mm-dd h:MM:ss"))+"\r\n",{});
      await  BluetoothEscposPrinter.printText("--------------------------------\r\n",{});
      await  BluetoothEscposPrinter.printText("电话：\r\n",{});
      await  BluetoothEscposPrinter.printText("地址:\r\n\r\n",{});
      await BluetoothEscposPrinter.printerAlign(BluetoothEscposPrinter.ALIGN.CENTER);
      await  BluetoothEscposPrinter.printText("欢迎下次光临\r\n\r\n\r\n",{});
      await BluetoothEscposPrinter.printerAlign(BluetoothEscposPrinter.ALIGN.LEFT);
}catch(e){
  alert(e.message || "ERROR");
}

  }}/>
                <Button disabled={this.state.loading || !(this.state.bleOpend && this.state.boundAddress.length > 0)}
                        title="ESC Print Image" onPress={async()=>{
        try{
            await BluetoothEscposPrinter.printPic(base64Image,{width:200,left:40});
        }catch(e){
          alert(e.message || "ERROR")
        }
      }}/>
                <Text>Found(tap to connect):</Text>
                {this.state.loading ? (<ActivityIndicator animating={true}/>) : null}
                <ListView style={{width:width,height:height/3}} enableEmptySections={true}
                          dataSource={this.state.foundDs}
                          renderRow={(rowData) => <Text style={{width:'100%',marginBottom:20}} onPress={()=>{
 this.setState({
     loading:true
 });
 BluetoothManager.connect(rowData.address)
 .then((s)=>{
   this.setState({
    loading:false,
    boundAddress:rowData.address
})
},(e)=>{
   this.setState({
     loading:false
 })
   alert(e);
})

}}>{rowData.name||rowData.address}</Text>}/>
                <Text>Paired:</Text>
                {this.state.loading ? (<ActivityIndicator animating={true}/>) : null}
                <ListView style={{width:width,height:height/3}} enableEmptySections={true}
                          dataSource={this.state.pairedDs}
                          renderRow={(rowData) => <Text style={{width:'100%',marginBottom:20}} onPress={()=>{
 this.setState({
     loading:true
 });
 BluetoothManager.connect(rowData.address)
 .then((s)=>{
   this.setState({
    loading:false,
    boundAddress:rowData.address,
    name:rowData.name || rowData.address
})
   alert(s);
},(e)=>{
   this.setState({
     loading:false
 })
   alert(e);
})

}}>{rowData.name||rowData.address}</Text>}/>
            </View>
        );
    }

    _selfTest() {
        this.setState({
            loading: true
        }, ()=> {
            BluetoothEscposPrinter.selfTest(()=> {
            });

            this.setState({
                loading: false
            })
        })
    }

    _scan() {
        this.setState({
            loading: true
        })
        BluetoothManager.scanDevices()
            .then((s)=> {
                var ss = s;
                try {
                    ss = JSON.parse(s);
                } catch (e) {
                    //ignore
                }
                this.setState({
                    pairedDs: this.state.pairedDs.cloneWithRows(ss.paired || []),
                    foundDs: this.state.foundDs.cloneWithRows(ss.found || []),
                    loading: false
                }, ()=> {
                    this.paired = ss.paired || [];
                    this.found = ss.found || [];
                });
            }, (er)=> {
                this.setState({
                    loading: false
                })
                alert('error' + JSON.stringify(er));
            });
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
});
