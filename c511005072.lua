--Quick Star: Level 3
--クイック・スターレベル３
--  By Shad3

local scard=s

function scard.initial_effect(c)
  --Activate
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCategory(CATEGORY_LVCHANGE)
  e1:SetTarget(scard.tg)
  e1:SetOperation(scard.op)
  c:RegisterEffect(e1)
end

function scard.g_slvl(g)
  local rg=Group.CreateGroup()
  local eg={}
  local ei={}
  local c=g:GetFirst()
  while c do
    local lv=c:GetLevel()
    if not eg[lv] then
      eg[lv]={}
      ei[lv]=0
    end
    table.insert(eg[lv],c)
    ei[lv]=ei[lv]+1
    c=g:GetNext()
  end
  for j,k in pairs(ei) do
    if k>1 then
      for _,tc in pairs(eg[j]) do
        rg:AddCard(tc)
      end
    end
  end
  return rg
end

function scard.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  local g=scard.g_slvl(Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil))
  if chk==0 then return #g>0 end
  Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,0,0,3)
end

function scard.op(e,tp,eg,ep,ev,re,r,rp)
  local g=scard.g_slvl(Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil))
  if #g==0 then return end
  local c=e:GetHandler()
  local tc=g:GetFirst()
  while tc do
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetValue(3)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    tc=g:GetNext()
  end
end