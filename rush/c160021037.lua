--紫鱗弾の超越爆撃速竜
--Violet-Scale Enhanced Blast Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_BLUETOOTH_B_DRAGON,CARD_REDBOOT_B_DRAGON)
	--Gains ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandler():GetControler()
end
function s.atkfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
function s.val(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	if #g==0 then return 0 end
	local atk=g:GetMaxGroup(Card.GetBaseAttack):GetFirst():GetBaseAttack()
	return atk
end