--セラフィムガンナー
--Seraphim Blaster
local s,id=GetID()
function s.initial_effect(c)
	--Gains 300 ATK for each other Fairy monster in the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_FAIRY),c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())*300
end