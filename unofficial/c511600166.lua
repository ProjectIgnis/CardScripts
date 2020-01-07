--復讐のソード・ストーカー (Manga)
--Swordstalker (Manga)
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--ATK Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.val(e,c)
	return Duel.GetMatchingGroup(Card.IsReason,c:GetControler(),LOCATION_GRAVE,0,nil,REASON_BATTLE):GetSum(Card.GetAttack)/5
end