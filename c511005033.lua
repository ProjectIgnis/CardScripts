--Line World Revival
-- By Shad3

local scard=s

function scard.initial_effect(c)
  --Activate
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetCondition(scard.cd)
  e1:SetTarget(scard.tg)
  e1:SetOperation(scard.op)
  c:RegisterEffect(e1)
end
s.listed_names={511005032}

function scard.lw_fil(c)
  return c:IsCode(511005032) and c:IsFaceup()
end

function scard.cd(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(scard.lw_fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end

function scard.sum_fil(c,e,tp)
  return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function scard.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(scard.sum_fil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end

function scard.op(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
  local g=Duel.GetMatchingGroup(scard.sum_fil,tp,LOCATION_GRAVE,0,nil,e,tp)
  if #g<1 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  Duel.SpecialSummon(g:Select(tp,1,1,nil),0,tp,tp,false,false,POS_FACEUP)
end