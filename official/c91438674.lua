--ＡＲＧ☆Ｓ－栄冠のアドラ
--Argostars - Glorious Adra
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Change the ATK of 1 face-up monster on the field to 0
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E|TIMING_DAMAGE_STEP)
	e1:SetCondition(s.atkcond)
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Apply "Your opponent cannot activate cards or effects in response to the activation of your Continuous Trap Cards and their effects effects this turn" effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	--Place up to 2 "ARG☆S" Continuous Traps with different names from your hand and/or Deck face-up in your Spell & Trap Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ARGOSTARS}
function s.atkcond(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsContinuousTrap),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsTurnPlayer(1-tp) and aux.StatChangeDamageStepCondition()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackAbove,1),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAttackAbove,1),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		--Change its ATK to 0 until the end of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	local c=e:GetHandler()
	--Your opponent cannot activate cards or effects in response to the activation of your Continuous Trap Cards and their effects this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(s.actop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,3))
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and re:IsActiveType(TYPE_CONTINUOUS) and re:IsTrapEffect() then
		Duel.SetChainLimit(function(e,rp,tp) return tp==rp end)
	end
end
function s.plfilter(c)
	return c:IsSetCard(SET_ARGOSTARS) and c:IsContinuousTrap() and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(ft,2),aux.dncheck,1,tp,HINTMSG_TOFIELD)
	if #sg==0 then return end
	for tc in sg:Iter() do
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end