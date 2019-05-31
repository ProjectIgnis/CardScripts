--Pappycorn
--  By Shad3

local scard=s

function scard.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetRange(LOCATION_MZONE)
  e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e1:SetValue(scard.val)
  c:RegisterEffect(e1)
end
s.listed_names={511002672}

function scard.fil(c)
  return c:IsCode(511002672) and c:IsFaceup()
end

function scard.val(e,c)
  if Duel.IsExistingMatchingCard(scard.fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
    return 1000
  end
  return 0
end