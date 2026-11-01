[out:json][timeout:180];
(
  area(3600062273)->.roi;
  area(3600156393)->.ni;
  area(3600058446)->.scotland;
);
(
  nwr(area.roi)["man_made"="survey_point"]["benchmark"="yes"]["wikimedia_commons"];
  nwr(area.ni)["man_made"="survey_point"]["benchmark"="yes"]["wikimedia_commons"];
  nwr(area.scotland)["man_made"="survey_point"]["benchmark"="yes"]["wikimedia_commons"];
);
out meta;
