--絶火の竜神ヴァフラム
--Vahram, the Magistus Divinity Dragon
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Prevent destruction by opponent's Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(s.indesvalue)
	c:RegisterEffect(e1)
	--Destroy all opponent's face-up cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon1)
	e2:SetTarget(s.destg1)
	e2:SetOperation(s.desop1)
	c:RegisterEffect(e2)
	--Destroy battling monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.descon2)
	e3:SetTarget(s.destg2)
	e3:SetOperation(s.desop2)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MAGISTUS}
function s.indesvalue(e,re,rp)
	return re:IsSpellTrapEffect() and rp==1-e:GetHandlerPlayer()
end
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSynchroSummoned()
end
function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetBattleTarget()
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetHandler():GetEquipTarget()
	local bc=ec:GetBattleTarget()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return false end
	local ec=e:GetHandler():GetEquipTarget()
	local bc=ec:GetBattleTarget()
	if ec and bc and bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end