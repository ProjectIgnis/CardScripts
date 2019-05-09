--Doom Virus Dragon
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,57728570,11082056)
	--Doom Virus (Faceup)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)	
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_MSET)
	e2:SetOperation(s.chkop)
	c:RegisterEffect(e2)
end
s.material_trap=57728570
function s.filter(c,g,pg)
	return c:IsFaceup() and c:GetAttack()>=1500 and c:IsDestructable() and not c:IsCode(id)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local conf=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_MZONE,nil)
	if #conf>0 then
		Duel.ConfirmCards(tp,conf)
		g:Merge(conf)
	end
	Duel.Destroy(g,REASON_EFFECT)
end
function s.filter2(c)
	return c:IsFacedown() and c:IsAttackAbove(1500) and c:IsDestructable()
end
function s.chkop(e,tp,eg,ep,ev,re,r,rp)
	local conf=Duel.GetFieldGroup(tp,0,LOCATION_MZONE,POS_FACEDOWN)
	if #conf>0 then
		Duel.ConfirmCards(tp,conf)
	end
end
