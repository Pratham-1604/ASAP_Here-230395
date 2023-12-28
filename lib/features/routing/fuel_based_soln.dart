import 'package:here_sdk/routing.dart';
import 'package:here_sdk/routing.dart' as here;

int fuel_based_consumption(List<here.Route>? routeList, num mileage) {
  int best_ind = 0;
  num best_score = 1000000;
  for (int i = 0; i < routeList!.length; i++) {
    here.Route a = routeList[i];
    double jamV = jamVal(a);
    num score = formula(
      a.lengthInMeters,
      mileage,
      a.trafficDelay,
      double.parse(a.duration.toString()),
      jamV,
    );

    if (score < best_score) {
      best_score = score;
      best_ind = i;
    }
  }
  return best_ind;
}

double jamVal(here.Route route) {
  double avg = 0;
  for (var section in route.sections) {
    for (var span in section.spans) {
      TrafficSpeed trafficSpeed = span.trafficSpeed;
      if (trafficSpeed.jamFactor != null) {
        avg += trafficSpeed.jamFactor!;
      }
    }
  }
  return avg;
}

num formula(distance, mileage, idle_time, driving_time, jam) {
  return ((distance / mileage) *
      (1 + (idle_time / driving_time)) *
      ((jam / 10) + 1));
}
