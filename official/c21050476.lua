--ＡＲＧ☆Ｓ－熱闘のパルテ
--Argostars - Fierce Parthe
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Gains 700 ATK/DEF for each "Argostars" monster with a different name you control, except this card
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(function(e,c)
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_ARGOSTARS),e:GetHandlerPlayer(),LOCATION_MZONE,0,e:GetHandler())
		return g:GetClassCount(Card.GetCode)*700
	end)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	--(Quick Effect): You can reveal this card in your hand; return 1 "Argostars" Continuous Trap you control to the hand, and if you do, Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(Cost.SelfReveal)
	e2:SetTarget(s.rthsptg)
	e2:SetOperation(s.rthspop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
	--You can banish this card you control; Set 1 Continuous Trap from your hand. It can be activated this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ARGOSTARS}
function s.rthfilter(c,tp)
	return c:IsSetCard(SET_ARGOSTARS) and c:IsContinuousTrap() and Duel.GetMZoneCount(tp,c)>0 and c:IsFaceup()
		and c:IsAbleToHand()
end
function s.rthsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.rthspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.rthfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	local c=e:GetHandler()
	if Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.setfilter(c)
	return c:IsContinuousTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if sc and Duel.SSet(tp,sc)>0 then
		--It can be activated this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		sc:RegisterEffect(e1)
	end
end