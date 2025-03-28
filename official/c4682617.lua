--魔界劇団のカーテンコール
--Abyss Actors' Curtain Call
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--activity check
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
s.listed_series={SET_ABYSS_SCRIPT,SET_ABYSS_ACTOR}
function s.chainfilter(re,tp,cid)
	return not (re:IsSpellEffect() and re:GetHandler():IsSetCard(SET_ABYSS_SCRIPT))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ABYSS_ACTOR) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ABYSS_ACTOR) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ctfilter(c)
	return c:IsSpell() and c:IsSetCard(SET_ABYSS_SCRIPT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local ct=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_GRAVE,0,nil)
	if ct<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,ct,nil)
	if #hg>0 and Duel.SendtoHand(hg,nil,REASON_EFFECT)~=0 then
		local sct=Duel.GetOperatedGroup():FilterCount(Card.IsControler,nil,tp)
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),sct)
		if sct>0 and ft>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
			local g=aux.SelectUnselectGroup(sg,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON,false)
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.splimit(e,c)
	return not (c:IsSetCard(SET_ABYSS_ACTOR) and c:IsType(TYPE_PENDULUM))
end