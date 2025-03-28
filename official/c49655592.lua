--Ｆ．Ａ．ウィップクロッサー
--F.A. Whip Crosser
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--activate cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCost(s.costchk)
	e2:SetTarget(s.costtg)
	e2:SetOperation(s.costop)
	c:RegisterEffect(e2)
	--accumulate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	--increase level
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_LVCHANGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.lvcon)
	e5:SetOperation(s.lvop)
	c:RegisterEffect(e5)
	--restricts discarding
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,1)
	e6:SetCode(EFFECT_CANNOT_DISCARD_HAND)
	e6:SetCondition(s.excon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(0,LOCATION_HAND)
	e7:SetCode(EFFECT_CANNOT_TO_GRAVE_AS_COST)
	e7:SetCondition(s.excon)
	c:RegisterEffect(e7)
end
s.listed_series={SET_FA}
function s.atkval(e,c)
	return c:GetLevel()*300
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsSpellTrapEffect() and re:GetHandler():IsSetCard(SET_FA)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.costchk(e,te_or_c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.CheckLPCost(tp,ct*300)
end
function s.costtg(e,te,tp)
	if not te:IsMonsterEffect() then return false end
	local tc=te:GetHandler()
	local lv=e:GetHandler():GetLevel()
	if tc:GetRank()>0 then
		return tc:GetOriginalRank()<lv
	elseif tc:HasLevel() then
		return tc:GetOriginalLevel()<lv
	else return false end
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,300)
end
function s.excon(e)
	return e:GetHandler():IsLevelAbove(7)
end