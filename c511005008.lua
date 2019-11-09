--Pappycorn
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
s.listed_names={511002672}
function s.fil(c)
	return c:IsCode(511002672) and c:IsFaceup()
end
function s.val(e,c)
	if Duel.IsExistingMatchingCard(s.fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		return 1000
	end
		return 0
end