--バスター・ブレイダー (Rush)
--Buster Blader (Rush)
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCountRush(aux.FaceupFilter(Card.IsRace,RACE_DRAGON),c:GetControler(),0,LOCATION_MZONE|LOCATION_GRAVE,nil)*500
end