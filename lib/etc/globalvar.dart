double cutPercentage(int type, {num value = 1}) => switch (type) {
      0 => 0.48 * value,
      1 => 0.5 * value,
      2 => 0.4 * value,
      3 => 0.1 * value,
      4 => 0.5 * value,
      int() => 1.0 * value,
    };

bool debugmode = true;
bool adminonly = false;
