return {
  name = [[Or]],
  desc = [[怪物AI]],
  children = {
    {
      name = [[And]],
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
          args = {str="进攻",},
        },
      },
    },
    {
      name = [[Log]],
      desc = [[逃跑]],
      args = {str="逃跑",},
    },
  },
}
