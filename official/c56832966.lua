--ＳＮｏ．３９ 希望皇ホープ・ザ・ライトニング
--Number S39: Utopia the Lightning
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 5 LIGHT monsters OR 1 Rank 4 "Utopia" monster you control
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),5,3,s.ovfilter,aux.Stringid(id,0))
	--Cannot be used as material for an Xyz Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--If this card battles, your opponent cannot activate cards or effects until the end of the Damage Step
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(function(e) local c=e:GetHandler() return Duel.GetAttacker()==c or Duel.GetAttackTarget()==c end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--This card's ATK becomes 5000 during that damage calculation only
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetCost(Cost.AND(Cost.DetachFromSelf(2),Cost.SoftOncePerBattle))
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_UTOPIA}
s.xyz_number=39
function s.ovfilter(c,tp,xyzc)
	return c:IsRank(4) and c:IsSetCard(SET_UTOPIA,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsFaceup()
end
function s.atkconfilter(c)
	return c:IsSetCard(SET_UTOPIA) and c:IsType(TYPE_XYZ)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and c:GetOverlayGroup():IsExists(s.atkconfilter,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--This card's ATK becomes 5000 during that damage calculation only
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(5000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
	end
end