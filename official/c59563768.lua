--転身テンシーン
--Tenshin
local s,id=GetID()
function s.initial_effect(c)
	--This card gains 400 ATK for each face-up Level 2 monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c)
		return 400*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsLevel,2),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	end)
	c:RegisterEffect(e1)
end