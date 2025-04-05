--肆世壊からの天跨
--Scareclaw Straddle
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Boost ATK of 1 "Scareclaw" monster or "Visas Stafrost"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Negate an effect that targets "Scareclaw" monster(s) and/or "Visas Stafrost"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_VISAS_STARFROST}
s.listed_series={SET_SCARECLAW}
function s.atkfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) 
		and (c:IsSetCard(SET_SCARECLAW) or c:IsCode(CARD_VISAS_STARFROST) or c:IsControler(1-tp))
end
function s.atkrescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetControler)==2
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.atkrescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.atkrescon,1,tp,HINTMSG_FACEUP)
	Duel.SetTargetCard(tg)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<2 then return end
	local tc,ac=g:GetFirst(),g:GetNext()
	if tc:IsControler(1-tp) then tc,ac=ac,tc end
	if tc:IsFaceup() and tc:IsControler(tp) and ac:IsFaceup() and ac:IsControler(1-tp) then
		--Increase ATK/DEF
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(math.max(ac:GetAttack(),ac:GetDefense()))
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
function s.disconfilter(c,tp)
	return c:IsFaceup() and c:IsOnField() and c:IsControler(tp)
		and ((c:IsSetCard(SET_SCARECLAW) and c:IsMonster()) or c:IsCode(CARD_VISAS_STARFROST))
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.disconfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not re:GetHandler():IsStatus(STATUS_DISABLED) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end