--誇りと魂の究極竜 
--Ultimate Dragon of Pride and Soul
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 3 monsters with 2500 original ATK and DEF
	Fusion.AddProcMixN(c,true,true,function(c) return c:IsBaseAttack(2500) and c:IsBaseDefense(2500) end,3)
	--This Fusion Summoned card cannot be destroyed by your opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--Your opponent cannot target this Fusion Summoned card with card effects
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--While you have 25 or more cards in your GY, this Fusion Summoned card gains 4500 ATK/DEF
	local e3=e1:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_GRAVE,0)>=25 end)
	e3:SetValue(4500)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	--Destroy all cards your opponent controls
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=25 end)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end