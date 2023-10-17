--セレブローズ・ゴシップ・マジシャン
--Celeb Rose Gossip Magician
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_CELEB_ROSE_MAGICIAN,160015009)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--battle protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcond)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.val(e,c)
	local tp=e:GetHandler():GetControler()
	local ct=Duel.GetMatchingGroupCount(Card.IsEquipSpell,tp,LOCATION_GRAVE,0,nil)
	return ct*400
end
function s.indcond(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSpell),tp,LOCATION_ONFIELD,0,1,nil)
end