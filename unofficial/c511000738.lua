--ジャンク・ドラゴンセント (Manga)
--Junk Dragonlet (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--Banish this card from your GY to increase the ATK of 1 attacking Synchro Monster by 800
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetCost(Cost.SelfBanish)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.IsPhase(PHASE_DAMAGE) or Duel.IsDamageCalculated()) then return false end
	local a=Duel.GetAttacker()
	return a:IsRelateToBattle() and a:IsSynchroMonster()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	a:UpdateAttack(800,RESET_EVENT|RESETS_STANDARD,e:GetHandler())
end
