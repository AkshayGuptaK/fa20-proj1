-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;
-- Question 0
CREATE VIEW q0(era) AS
SELECT MAX(era)
FROM pitching;
-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear) AS
SELECT namefirst,
  namelast,
  birthyear
FROM people
WHERE weight > 300;
-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear) AS
SELECT namefirst,
  namelast,
  birthyear
FROM people
WHERE namefirst LIKE '% %'
ORDER BY namefirst,
  namelast;
;
-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count) AS
SELECT birthyear,
  AVG(height),
  COUNT(*)
FROM people
GROUP BY birthyear
ORDER BY birthyear;
-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count) AS
SELECT birthyear,
  AVG(height),
  COUNT(*)
FROM people
GROUP BY birthyear
HAVING AVG(height) > 70
ORDER BY birthyear;
-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid) AS
SELECT p.namefirst,
  p.namelast,
  p.playerid,
  hof.yearid
FROM people AS p
  INNER JOIN halloffame AS hof ON p.playerid = hof.playerid
  AND hof.inducted = 'Y'
ORDER BY yearid DESC,
  p.playerid;
-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid) AS WITH californiacollegiates(playerid, schoolid) AS (
  SELECT playerid,
    cp.schoolid
  FROM collegeplaying AS cp
    INNER JOIN (
      SELECT schoolid
      FROM schools
      WHERE state = 'CA'
    ) AS s
  WHERE cp.schoolid = s.schoolid
)
SELECT namefirst,
  namelast,
  p.playerid,
  schoolid,
  hof.yearid
FROM (
    SELECT namefirst,
      namelast,
      p.playerid,
      cc.schoolid
    FROM people AS p
      INNER JOIN californiacollegiates AS cc
    WHERE p.playerid = cc.playerid
  ) AS p
  INNER JOIN halloffame AS hof ON p.playerid = hof.playerid
  AND hof.inducted = 'Y'
ORDER BY yearid DESC,
  p.schoolid,
  p.playerid;
-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid) AS
SELECT p.playerid,
  p.namefirst,
  p.namelast,
  schoolid
FROM (
    SELECT p.namefirst,
      p.namelast,
      p.playerid,
      cp.schoolid
    FROM people p
      LEFT JOIN collegeplaying cp ON p.playerid = cp.playerid
  ) AS p
  INNER JOIN halloffame AS hof ON p.playerid = hof.playerid
  AND hof.inducted = 'Y'
ORDER BY p.playerid DESC,
  schoolid;
-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg) AS
SELECT p.playerid,
  namefirst,
  namelast,
  yearid,
  slg
FROM (
    SELECT playerid,
      yearid,
      (H + H2B + 2.0 * H3B + 3 * HR) / AB AS slg
    FROM batting
    WHERE AB > 50
    ORDER BY slg DESC
    LIMIT 10
  ) AS h
  LEFT JOIN people p ON h.playerid = p.playerid;
-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg) AS
SELECT p.playerid,
  namefirst,
  namelast,
  lslg
FROM (
    SELECT playerid,
      (SUM(H) + SUM(H2B) + 2.0 * SUM(H3B) + 3 * SUM(HR)) / SUM(AB) AS lslg
    FROM batting
    GROUP BY playerid
    HAVING SUM(AB) > 50
    ORDER BY lslg DESC
    LIMIT 10
  ) AS h
  LEFT JOIN people p ON h.playerid = p.playerid
ORDER BY lslg DESC,
  p.playerid;
-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg) AS
SELECT namefirst,
  namelast,
  lslg
FROM (
    SELECT playerid,
      (SUM(H) + SUM(H2B) + 2.0 * SUM(H3B) + 3 * SUM(HR)) / SUM(AB) AS lslg
    FROM batting
    GROUP BY playerid
    HAVING SUM(AB) > 50
      AND lslg > (
        SELECT (SUM(H) + SUM(H2B) + 2.0 * SUM(H3B) + 3 * SUM(HR)) / SUM(AB)
        FROM batting
        WHERE playerid = 'mayswi01'
        GROUP BY playerid
      )
  ) AS h
  LEFT JOIN people p ON h.playerid = p.playerid
ORDER BY lslg DESC,
  p.playerid;
-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg) AS
SELECT yearid,
  MIN(salary),
  MAX(salary),
  AVG(salary)
FROM salaries
GROUP BY yearid
ORDER BY yearid;
-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count) AS WITH aggs(step, minimum, maximum) AS (
  SELECT CAST ((MAX(salary) - MIN(salary)) / 10 AS INT) AS step,
    MIN(salary) AS minimum,
    MAX(salary) AS maximum
  FROM salaries
  WHERE yearid = 2016
)
SELECT binid,
  minimum + binid * step AS low,
  minimum + binid * step + step AS high,
  COUNT(*) AS count
FROM (
    SELECT CAST(
        CASE
          salary
          WHEN maximum THEN 9
          ELSE (salary - minimum) / step
        END AS INT
      ) AS binid,
      salary,
      minimum,
      step
    FROM salaries,
      aggs
    WHERE yearid = 2016
  )
GROUP BY binid
ORDER BY binid;
-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff) AS WITH avgs(yearid, minimum, maximum, average) AS (
  SELECT yearid,
    MIN(salary),
    MAX(salary),
    AVG(salary)
  FROM salaries
  GROUP BY yearid
)
SELECT avgs.yearid,
  avgs.minimum - avgs2.minimum AS mindiff,
  avgs.maximum - avgs2.maximum AS maxdiff,
  avgs.average - avgs2.average AS avgdiff
FROM avgs
  INNER JOIN avgs AS avgs2 ON avgs.yearid = avgs2.yearid + 1
ORDER BY avgs.yearid;
-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid) AS
SELECT s.playerid,
  p.namefirst,
  p.namelast,
  s.salary,
  s.yearid
FROM (
    salaries s
    INNER JOIN (
      SELECT MAX(salary) AS mx,
        yearid
      FROM salaries
      GROUP BY yearid
      HAVING yearid = '2000'
        OR yearid = '2001'
    ) AS ms ON s.salary = mx
    AND s.yearid = ms.yearid
  ) AS s
  LEFT JOIN people p ON p.playerid = s.playerid;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
SELECT asf.teamid,
  MAX(salary) - MIN(salary)
FROM allstarfull asf
  LEFT JOIN salaries s ON asf.playerid = s.playerid
WHERE asf.yearid = '2016'
  AND s.yearid = '2016'
GROUP BY asf.teamid;