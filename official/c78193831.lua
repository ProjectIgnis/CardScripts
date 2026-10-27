--バスター・ブレイダー
--Buster Blader
local s,id=GetID()
function s.initial_effect(c)
	--Gains 500 ATK for each Dragon monster your opponent controls or is in their GY.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
end
function s.atkval(e,c)
	return 500*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,IsRace,RACE_DRAGON),c:GetControler(),0,LOCATION_MZONE|LOCATION_GRAVE,nil)
end
