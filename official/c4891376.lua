--鎖縛竜ザレン
--Zaren the Chainbound Dragon
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ Synchro Monsters
	Synchro.AddProcedure(c,nil,1,1,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,99)
	--Multiple Tuner check (Red Nova)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--If this card you control would be used as Synchro Material, you can treat it as a non-Tuner
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function() return Duel.GetCurrentChain()>1 end)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_MULTIPLE_TUNERS)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD)|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsChainDisablable(ev)
	local b2=Duel.IsChainDisablable(ev-1)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	local ch=ev-op+1
	e:SetLabel(ch)
	local eff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
	local rc=eff:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,rc,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(eff) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,tp,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local ch=e:GetLabel()
	local eff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
	local rc=eff:GetHandler()
	if Duel.NegateEffect(ch) and rc:IsRelateToEffect(eff) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end