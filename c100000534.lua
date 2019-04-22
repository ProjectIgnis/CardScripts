--ワルキューレ・ドリット (Anime)
--Valkyrie Dritte (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkvalue)
	c:RegisterEffect(e1)
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.atkvalue(e,c)
	return Duel.GetMatchingGroupCount(s.rmfilter,c:GetControler(),0,LOCATION_REMOVED,nil)*100
end