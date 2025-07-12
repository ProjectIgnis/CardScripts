--エクソシスター・ジブリーヌ
--Exosister Gibrine
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	--Check if this card was Xyz Summoned by using an "Exosister" monster as material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Cannot be destroyed by the activated effects of monsters Special Summoned from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
	--Negate the effects of 1 Effect Monster your opponent controls until the end of this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e2:SetCost(Cost.HintSelectedEffect)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--Apply a "for the rest of this turn, all Xyz Monsters you control will gain 800 ATK" effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.AND(Cost.DetachFromSelf(1),Cost.HintSelectedEffect))
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_EXOSISTER}
function s.valcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsSetCard,1,nil,SET_EXOSISTER) then
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END&~RESET_TOFIELD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end
function s.indval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsSpecialSummoned() and rc:IsSummonLocation(LOCATION_GRAVE) and re:IsMonsterEffect() and re:IsActivated()
end
function s.disfilter(c)
	return c:IsNegatableMonster() and c:IsType(TYPE_EFFECT)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--Negate its effects until the end of this turn
		tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,3))
	--For the rest of this turn, all Xyz Monsters you control will gain 800 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_XYZ))
	e1:SetValue(800)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
