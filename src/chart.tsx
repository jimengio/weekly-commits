import React, { FC, useEffect, useState } from "react";
import { css, cx } from "emotion";

import commitData from "../data/commits.json";
import produce from "immer";
import ReactECharts from "echarts-for-react";

interface IStatsData {
  total: number;
  additions: number;
  deletions: number;
}

interface ICommitData {
  author: {
    date: string;
    email: string;
    name: string;
  };
}

interface ICommitDataList {
  commit: ICommitData;
  stats: IStatsData;
}

interface IProjectDetail {
  projectName: string;
  additions: number;
  deletions: number;
  total: number;
  commitNumber: number;
}

interface IProcessedData {
  userName: string;
  projectNameList: string[];
  projectDetail: IProjectDetail[];
  totalProjectsAdditions: number;
  totalProjectsDeletions: number;
  totalProjectsTotal: number;
  totalProjectsCommitNumber: number;
}

let PageChart: FC<{}> = props => {
  /** Methods */
  const [processedData, setProcessedData] = useState<IProcessedData[]>([]);
  const [userNameList, setUserNameList] = useState<string[]>([]);
  const [selectProjectName, setSelectProjectName] = useState<string>();
  const [projectNameList, setProjectNameList] = useState<string[]>([]);

  const getRealName = (userName: string) => {
    switch (userName) {
      case "ChenYong":
        return "ChenYong";
      case "rebirthO":
        return "rebirthO";
      case "Dave":
      case "wangcch":
        return "wangcch";
      case "yuanjiaCN":
      case "yuan jia":
        return "yuanjiaCN";
      case "yuelei":
        return "yuelei";
      case "hejinlei":
        return "hejinlei";
      default:
        return userName;
    }
  };

  const getProcessedData = () => {
    let processedData: IProcessedData[] = [];
    let userNameList: string[] = [];
    let projectNameList: string[] = [];

    commitData.forEach(item => {
      projectNameList = projectNameList.concat(item[0] as string);

      (item[1] as ICommitDataList[]).map(commitDetail => {
        let userAlreadyExists = userNameList.includes(
          getRealName(commitDetail.commit.author.name)
        );

        if (userAlreadyExists === false) {
          /**人无，项目无 */
          userNameList = userNameList.concat(
            getRealName(commitDetail.commit.author.name)
          );

          processedData = processedData.concat({
            userName: getRealName(commitDetail.commit.author.name),

            //所有项目的总和数据
            projectNameList: [item[0] as string],
            totalProjectsAdditions: commitDetail.stats.additions,
            totalProjectsDeletions: commitDetail.stats.deletions,
            totalProjectsTotal: commitDetail.stats.total,
            totalProjectsCommitNumber: 1,

            //单个项目的数据
            projectDetail: [
              {
                projectName: item[0] as string,
                additions: commitDetail.stats.additions,
                deletions: commitDetail.stats.deletions,
                total: commitDetail.stats.total,
                commitNumber: 1
              }
            ]
          });
        } else {
          let nameIndex = userNameList.findIndex(userName => {
            return userName === getRealName(commitDetail.commit.author.name);
          });

          let thisProjectAlreadyExists = processedData[
            nameIndex
          ].projectNameList.includes(item[0] as string);

          if (thisProjectAlreadyExists === true) {
            /**人有，项目有 */
            let projectNameIndex = processedData[
              nameIndex
            ].projectNameList.findIndex(projectName => {
              return projectName === (item[0] as string);
            });

            processedData = produce(processedData, draft => {
              //所有项目的总和数据
              draft[nameIndex].totalProjectsAdditions +=
                commitDetail.stats.additions;
              draft[nameIndex].totalProjectsDeletions +=
                commitDetail.stats.deletions;
              draft[nameIndex].totalProjectsTotal += commitDetail.stats.total;
              draft[nameIndex].totalProjectsCommitNumber += 1;

              //单个项目的数据
              draft[nameIndex].projectDetail[projectNameIndex].additions +=
                commitDetail.stats.additions;
              draft[nameIndex].projectDetail[projectNameIndex].deletions +=
                commitDetail.stats.deletions;
              draft[nameIndex].projectDetail[projectNameIndex].total +=
                commitDetail.stats.total;
              draft[nameIndex].projectDetail[
                projectNameIndex
              ].commitNumber += 1;
            });
          } else {
            /**人有，项目无 */
            processedData = produce(processedData, draft => {
              draft[nameIndex].projectNameList = draft[
                nameIndex
              ].projectNameList.concat(item[0] as string);

              //所有项目的总和数据
              draft[nameIndex].totalProjectsAdditions +=
                commitDetail.stats.additions;
              draft[nameIndex].totalProjectsDeletions +=
                commitDetail.stats.deletions;
              draft[nameIndex].totalProjectsTotal += commitDetail.stats.total;
              draft[nameIndex].totalProjectsCommitNumber += 1;

              //单个项目的数据
              draft[nameIndex].projectDetail = draft[
                nameIndex
              ].projectDetail.concat({
                projectName: item[0] as string,
                additions: commitDetail.stats.additions,
                deletions: commitDetail.stats.deletions,
                total: commitDetail.stats.total,
                commitNumber: 1
              });
            });
          }
        }
        return commitDetail;
      });
    });

    setProcessedData(processedData);
    setUserNameList(userNameList);
    setProjectNameList(projectNameList);
  };

  /** Effects */
  useEffect(() => {
    getProcessedData();
  }, []);

  /** Renderers */
  const getProjectOption = () => {
    let additions: number[] = [];
    let deletions: number[] = [];

    if (selectProjectName && selectProjectName !== "total") {
      processedData.forEach(userItem => {
        if (userItem.projectNameList.includes(selectProjectName)) {
          userItem.projectDetail.forEach(projectItem => {
            if (projectItem.projectName === selectProjectName) {
              additions = additions.concat(projectItem.additions);
              deletions = deletions.concat(projectItem.deletions);
            }
          });
        } else {
          additions = additions.concat(0);
          deletions = deletions.concat(0);
        }
      });
    } else {
      additions = processedData.map(item => {
        return item.totalProjectsAdditions;
      });

      deletions = processedData.map(item => {
        return item.totalProjectsDeletions;
      });
    }

    return {
      legend: {
        data: ["增加", "删去"],
        x: "70%"
      },
      grid: {
        x: 60,
        y: 60
      },
      xAxis: {
        type: "value"
      },
      yAxis: {
        type: "category",
        data: userNameList
      },
      series: [
        {
          name: "删去",
          data: deletions,
          type: "bar",
          stack: "代码行数",
          color: "#cb2431",
          label: {
            normal: {
              show: true,
              position: "insideRight"
            }
          }
        },
        {
          name: "增加",
          data: additions,
          type: "bar",
          stack: "代码行数",
          color: "#28a745",
          label: {
            normal: {
              show: true,
              position: "insideRight"
            }
          }
        }
      ]
    };
  };

  return (
    <div className={cx(styleContainer)}>
      <div>
        <select
          style={{ height: 40, fontSize: 30, marginBottom: 50 }}
          value={selectProjectName}
          onChange={event => {
            setSelectProjectName(event.target.value);
          }}
        >
          <option value="total">total</option>
          {projectNameList.map(projectName => {
            return (
              <option key={projectName} value={projectName}>
                {projectName}
              </option>
            );
          })}
        </select>
      </div>
      <ReactECharts style={{ height: "60vh" }} option={getProjectOption()} />
    </div>
  );
};

export default PageChart;

let styleContainer = css`
  margin: 40px;
`;
