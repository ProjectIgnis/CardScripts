--ＡＲＧ☆Ｓ－ＧｉａｎｔＫｉｌｌｉｎｇ
--Argostars - Giant Hunting
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Argostars" monster from your Deck to your hand, then, immediately after this effect resolves, you can Normal Summon 1 Warrior monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Return 2 cards on the field, including 1 "Argostars" card, to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.retthtg)
	e2:SetOperation(s.retthop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ARGOSTARS}
function s.thfilter(c)
	return c:IsSetCard(SET_ARGOSTARS) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.trapfilter(c)
	return c:IsContinuousTrap() and (c:IsLocation(LOCATION_MZONE) or (c:IsTrapMonster() and c:IsLocation(LOCATION_STZONE))) and c:IsFaceup()
end
function s.nsfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsSummonable(true,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)
		if Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_ONFIELD,0,1,nil)
			and Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) 
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
			if sc then
				Duel.BreakEffect()
				Duel.Summon(tp,sc,true,nil)
			end
		end
	end
end
function s.argstrapfilter(c,tp)
	return c:IsSetCard(SET_ARGOSTARS) and c:IsContinuousTrap() and c:IsControler(tp) and c:IsFaceup()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.argstrapfilter,1,nil,tp)
end
function s.retthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return #rg>=2 and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)
end
function s.retthop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end