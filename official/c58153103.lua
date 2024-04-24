--アームド・ドラゴン・サンダー ＬＶ１０
--Armed Dragon Thunder LV10
--Scripted by AlphaKretin
Duel.LoadCardScript("c59464593.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Register if this card is Special Summoned by the effect of an "Armed Dragon" monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TEMP_REMOVE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2)) end)
	c:RegisterEffect(e0)
	--ICHI - This card's name becomes "Armed Dragon LV10"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon(1))
	e1:SetValue(59464593)
	c:RegisterEffect(e1)
	--JUU - Control of this card cannot switch
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e10:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCondition(s.atkcon(10))
	c:RegisterEffect(e10)
	--HYAKU - Cannot be destroyed by battle
	local e100=Effect.CreateEffect(c)
	e100:SetType(EFFECT_TYPE_SINGLE)
	e100:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e100:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e100:SetRange(LOCATION_MZONE)
	e100:SetCondition(s.atkcon(100))
	e100:SetValue(1)
	c:RegisterEffect(e100)
	--SEN - Destroy 1 other card on the field and make this card gain 1000 ATK
	local e1000=Effect.CreateEffect(c)
	e1000:SetDescription(aux.Stringid(id,0))
	e1000:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1000:SetType(EFFECT_TYPE_QUICK_O)
	e1000:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1000:SetCode(EVENT_FREE_CHAIN)
	e1000:SetRange(LOCATION_MZONE)
	e1000:SetCountLimit(1)
	e1000:SetHintTiming(0,TIMING_DAMAGE_STEP|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1000:SetCondition(s.descon)
	e1000:SetCost(s.descost)
	e1000:SetTarget(s.destg)
	e1000:SetOperation(s.desop)
	c:RegisterEffect(e1000)
	--MANJOUME THUNDER - Destroy all other cards on the field
	local e10000=Effect.CreateEffect(c)
	e10000:SetDescription(aux.Stringid(id,1))
	e10000:SetCategory(CATEGORY_DESTROY)
	e10000:SetType(EFFECT_TYPE_IGNITION)
	e10000:SetRange(LOCATION_MZONE)
	e10000:SetCountLimit(1)
	e10000:SetCondition(s.atkcon(10000))
	e10000:SetTarget(s.desalltg)
	e10000:SetOperation(s.desallop)
	c:RegisterEffect(e10000)
end
s.listed_names={59464593} --"Armed Dragon LV10"
s.listed_series={SET_ARMED_DRAGON}
s.LVnum=10
s.LVset=SET_ARMED_DRAGON_THUNDER
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	if not (re and re:IsMonsterEffect()) then return false end
	local rc=re:GetHandler()
	local trig_loc,trig_setcodes=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SETCODES)
	if not Duel.IsChainSolving() or (rc:IsRelateToEffect(re) and rc:IsFaceup() and rc:IsLocation(trig_loc)) then
		return rc:IsSetCard(SET_ARMED_DRAGON)
	else
		for _,setcode in ipairs(trig_setcodes) do
			if (SET_ARMED_DRAGON&0xfff)==(setcode&0xfff) and (SET_ARMED_DRAGON&setcode)==SET_ARMED_DRAGON then return true end
		end
	end
end
function s.atkcon(atk)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return c:HasFlagEffect(id) and c:IsAttackAbove(atk)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and s.atkcon(1000)(e,tp,eg,ep,ev,re,r,rp)
		and not (Duel.IsPhase(PHASE_DAMAGE) and Duel.IsDamageCalculated())
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:UpdateAttack(1000)
	end
end
function s.desalltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desallop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end