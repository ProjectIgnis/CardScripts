--サイバー・ブレイダー
--Cyber Blader
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,false,false,97023549,11460577)
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.con)
	e1:SetLabel(1)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetLabel(2)
	e2:SetCondition(s.con)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--negate effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetLabel(3)
	e3:SetCondition(s.con)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
s.material_setcode=0x93
function s.con(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)==e:GetLabel()
end
function s.atkval(e,c)
	return c:GetAttack()*2
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if rp~=tp then
		Duel.NegateEffect(ev)
	end
end
