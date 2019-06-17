return {
  name = [[Selector]],
  desc = [[怪物AI]],
  children = {
    {
      name = [[Sequence]],
      desc = [[攻击]],
      children = {
        {
          name = [[GetHp]],
          desc = [[获取血量]],
          output = {"hp",},
        },
        {
          name = [[Cmp]],
          desc = [[大于50]],
          input = {"hp",},
          args = {ge = 50,},
        },
        {
          name = [[Log]],
          desc = [[进攻]],
          args = {str="Attack!",},
        },
      },
    },
    {
      name = [[Log]],
      desc = [[逃跑]],
      args = {str="Run!",},
    },
  },
}
