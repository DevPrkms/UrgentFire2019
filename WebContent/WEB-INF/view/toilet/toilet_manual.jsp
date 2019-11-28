<%@ page import="poly.util.CmmUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userId = CmmUtil.nvl((String) session.getAttribute("userId"));
    String userGroup = CmmUtil.nvl((String) session.getAttribute("userGroup"));
%>
<html>
<head>
    <title>급한불 - 내 주변 공중화장실</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <link rel="stylesheet" href="/assets/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="/assets/fonts/font-awesome.min.css">
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css?family=Cookie">
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css?family=Nanum+Gothic">
    <link rel="stylesheet" href="/assets/css/Navigation-with-Button.css">
    <link rel="stylesheet" href="/assets/css/Pretty-Footer.css">
    <link rel="stylesheet" href="/assets/css/styles.css">
    <script src="/assets/js/jquery.min.js"></script>
    <script src="/assets/bootstrap/js/bootstrap.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
    <style>
        @media screen and (max-width: 433px) {
            #navbar-user-text {
                position: relative;
                left: 20%;
            }

            #map {
                margin: 0 auto;
                width: 100%;
                margin-bottom: 25px;
            }

            .kakaomap {
                width: 100%;
            }

            .container {
                display: block !important;
            }

        }

        .container {
            width: 100%;
            display: flex;
        }

        .kakaomap {
            display: flex;
            margin: 0 auto;
            margin-bottom: 50px;
            width: 60%;
            height: 400px;
        }

        .filloc {
            width: 35%;
        }

        .filloc input {
            margin: 0 auto;
            width: 30%;
            position: relative;
            top: -1.9px;
        }

        select{
            width: 150px;
            height: 35px;
            font-size: 15px;
            color: #999;
            border: 2px solid #ddd;
            border-radius: 5px;
            margin-right: 10px;
        }

        select::-ms-expand {
            opacity: 0;
        }
    </style>
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=7f5f12b2030f275b598757498f39278f&libraries=services"></script>
</head>

<body>
<% if (userId == "") { %>
<jsp:include page="/WEB-INF/view/header/default.jsp"></jsp:include>
<% } else if (userGroup.equals("2")) {%>
<jsp:include page="/WEB-INF/view/header/admin.jsp"></jsp:include>
<% } else { %>
<jsp:include page="/WEB-INF/view/header/normal.jsp"></jsp:include>
<% } %>

<!-- 메인 컨텐츠 시작 -->
<div id="main-wrapper" style="min-height: 100vh">
<div id="main_c" class="container" style="">
    <div id="map" class="kakaomap"></div>
    <script type="text/javascript"
            src="//dapi.kakao.com/v2/maps/sdk.js?appkey=7f5f12b2030f275b598757498f39278f"></script>

    <script>
        // 37.504852, 127.110114
        // 37.587551, 127.058382
        // 37.550081, 126.842321

        navigator.geolocation.getCurrentPosition(function (position) {

            var corlat = position.coords.latitude;
            var corlon = position.coords.longitude;

            console.log(corlat, corlon);
            var mapContainer = document.getElementById('map'), // 지도를 표시할 div
                mapOption = {
                    center: new kakao.maps.LatLng(corlat, corlon), // 지도의 중심좌표
                    level: 1 // 지도의 확대 레벨
                };

            var map = new kakao.maps.Map(mapContainer, mapOption); // 지도를 생성합니다
            $("#fillse").click(function () {
            var keywordloc = "서울시 " + $("#fillv").val();
            console.log(keywordloc)

            var locinfo = document.getElementById("locinfo");
            locinfo.innerHTML = "<strong><font color='red'>" + keywordloc + "</font></strong> 의 공중화장실 정보입니다.";

                var ps = new kakao.maps.services.Places();

                ps.keywordSearch(keywordloc, placesSearchCB);

            function placesSearchCB(data, status, pagination) {
                if (status === kakao.maps.services.Status.OK){
                    var bounds = new kakao.maps.LatLngBounds();

                    for (var i=0; i<data.length; i++){
                        // displayMarker(data[i]);
                        bounds.extend(new kakao.maps.LatLng(data[i].y, data[i].x));
                    }

                    map.setBounds(bounds);
                    map.setZoomable(false);
                    map.setDraggable(false);
                }
            }

            map.setLevel(6);
            // function displayMarker(place) {
            //     var marker = new kakao.maps.Marker({
            //         map: map,
            //         position: new kakao.maps.LatLng(place.y, place.x)
            //     });
            // }
            });

            var imageSrc = '/assets/img/marker/redmarker.png', // 마커이미지의 주소입니다
                imageSize = new kakao.maps.Size(50, 50), // 마커이미지의 크기입니다
                imageOption = {offset: new kakao.maps.Point(27, 48)}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.

            // 마커의 이미지정보를 가지고 있는 마커이미지를 생성합니다
            var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imageOption),
                markerPosition = new kakao.maps.LatLng(corlat, corlon); // 마커가 표시될 위치입니다

            // 마커를 생성합니다
            var marker = new kakao.maps.Marker({
                position: markerPosition,
                image: markerImage // 마커이미지 설정
            });

            // 마커가 지도 위에 표시되도록 설정합니다
            marker.setMap(map);

            // 전체 마커 찍기 start

            var json_url = '/json/toiletloc.json';

            $.getJSON(json_url, function (data, textStatus) {

                var FNAME = null;
                var LATITUDE_Y = null;
                var LONGITUDE_X = null;

                var imageSrc = '/assets/img/marker/bluemarker.png', // 마커이미지의 주소입니다
                    imageSize = new kakao.maps.Size(50, 50), // 마커이미지의 크기입니다
                    imageOption = {offset: new kakao.maps.Point(27, 48)}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.

                // 마커의 이미지정보를 가지고 있는 마커이미지를 생성합니다
                var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imageOption)

                $.each(data.toiletloc, function () {
                    FNAME = this.FNAME;
                    LATITUDE_Y = this.LATITUDE_Y;
                    LONGITUDE_X = this.LONGITUDE_X;

                    var marker = new kakao.maps.Marker({

                        map: map, // 마커를 표시할 지도
                        image: markerImage,
                        position: new kakao.maps.LatLng(LATITUDE_Y, LONGITUDE_X) // 마커를 표시할 위치
                    });

                    var customOverlay = new daum.maps.CustomOverlay({
                        position: new kakao.maps.LatLng(LATITUDE_Y, LONGITUDE_X)
                    });

                    var content = document.createElement('div');
                    content.style.position = "relative";
                    content.style.bottom = "60px";
                    // content.style.left = "25px";
                    content.style.padding = "5px";
                    content.style.borderRadius = "6px";
                    content.style.border = "1px solid #ccc";
                    content.style.borderBottom = "2px solid #ddd";
                    content.style.cssFloat = "left";
                    content.style.backgroundColor = "#fff";

                    var ourl = 'https://map.kakao.com/link/to/' + FNAME + ', ' + LATITUDE_Y + ', ' + LONGITUDE_X

                    var info = document.createElement('div');
                    info.appendChild(document.createTextNode(FNAME));
                    content.appendChild(info);
                    info.style.fontSize = "13pt";
                    info.style.fontWeight = "bold";
                    info.style.borderBottom = "1px solid #ddd";
                    info.style.textAlign = "center";
                    info.onclick = function () {
                        window.open(ourl, '_blank')
                    };

                    var closeBtn = document.createElement('div');
                    closeBtn.appendChild(document.createTextNode('X'));
                    closeBtn.onclick = function () {
                        customOverlay.setMap(null);
                    };
                    content.appendChild(closeBtn);
                    closeBtn.style.color = "white";
                    closeBtn.style.fontWeight = "bold";
                    closeBtn.style.backgroundColor = "#d95050";
                    closeBtn.style.textAlign = "center";
                    closeBtn.style.borderRadius = "0px 0px 4px 4px";

                    // 마커를 클릭했을 때 커스텀 오버레이를 표시합니다
                    kakao.maps.event.addListener(marker, 'click', function () {
                        customOverlay.setMap(map);
                    });

                    customOverlay.setContent(content);
                    customOverlay.setMap(null);
                });

            });

        });

        // 전체 마커 찍기 end

    </script>

    <form class="filloc">
        <select name = "fillloc" id="fillv">
            <option value="" selected disabled hidden>지역 선택</option>
            <option value="강남구">강남구</option>
            <option value="강동구">강동구</option>
            <option value="강서구">강서구</option>
            <option value="강북구">강북구</option>
            <option value="관악구">관악구</option>
            <option value="광진구">광진구</option>
            <option value="구로구">구로구</option>
            <option value="금천구">금천구</option>
            <option value="노원구">노원구</option>
            <option value="동대문구">동대문구</option>
            <option value="도봉구">도봉구</option>
            <option value="동작구">동작구</option>
            <option value="마포구">마포구</option>
            <option value="서대문구">서대문구</option>
            <option value="성동구">성동구</option>
            <option value="성북구">성북구</option>
            <option value="서초구">서초구</option>
            <option value="송파구">송파구</option>
            <option value="영등포구">영등포구</option>
            <option value="용산구">용산구</option>
            <option value="양천구">양천구</option>
            <option value="은평구">은평구</option>
            <option value="종로구">종로구</option>
            <option value="중구">중구</option>
            <option value="중랑구">중랑구</option>
        </select>
        <input class="btn btn-outline-primary" id="fillse" style="width: 80px; height: auto; font-size: 10pt; font-weight: bold;" type="button" value="검색">
        <hr>
        <p id="locinfo"></p>
    </form>

</div>
<p style="text-align: center; color: #999;">파란색 마커 클릭 시 오버레이가 출력되며, 오버레이창에서 이름 클릭 시 해당 위치 카카오맵으로 자동 이동됩니다.</p>
</div>
<!-- 메인 컨텐츠 종료 -->

<jsp:include page="/WEB-INF/view/footer/footer.jsp"></jsp:include>
</body>
</html>