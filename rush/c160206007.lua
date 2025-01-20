--伝説の戦士－バスター・ブレイダー
--Legendary Swordsman - Buster Blader
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Buster Blader" in the Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(78193831)
	c:RegisterEffect(e1)
	--Gains 500 ATK per each Dragon monster the opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	--Cannot attack directly
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCountRush(aux.FaceupFilter(Card.IsRace,RACE_DRAGON),c:GetControler(),0,LOCATION_MZONE,nil)*500
end