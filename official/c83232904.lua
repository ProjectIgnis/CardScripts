--道化の一座『極芸』
--Clown Crew "Malabarism"
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon up to 2 "Clown Crew" monsters from your Deck and/or Extra Deck, ignoring their Summoning conditions, also you cannot activate the effects of monsters Special Summoned from the Deck or Extra Deck until the end of the next turn after this card resolves
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During your Main Phase, if this card in your GY, except the turn it was sent there: You can banish it and Tribute 1 monster from your hand or field, then target 1 card on the field; return it to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(Cost.AND(Cost.SelfBanish,s.rthcost))
	e2:SetTarget(s.rthtg)
	e2:SetOperation(s.rthop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CLOWN_CREW}
function s.spfilter(c,e,tp,mmz_chk)
	if not (c:IsSetCard(SET_CLOWN_CREW) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return mmz_chk
	elseif c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.pendlinkfilter(c)
	return (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()) or c:IsLinkMonster()
end
function s.rescon(mmz_ct,linkmz_ct)
	return	function(sg,e,tp,mg)
				return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=mmz_ct
					and sg:FilterCount(s.pendlinkfilter,nil)<=linkmz_ct
			end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		--You cannot activate the effects of monsters Special Summoned from the Deck or Extra Deck until the end of the next turn after this card resolves
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
	local mmz_ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local emz_ct=Duel.GetLocationCountFromEx(tp,tp,nil,nil,ZONES_EMZ)
	local linkmz_ct=Duel.GetLocationCountFromEx(tp,tp)
	local ft=math.min(mmz_ct+emz_ct,2)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,nil,e,tp,mmz_ct>0)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon(mmz_ct,linkmz_ct),1,tp,HINTMSG_SPSUMMON)
	if #sg==0 then return end
	local fup,fdown=sg:Split(s.pendlinkfilter,nil)
	local fdown_main,fdown_ex=fdown:Split(Card.IsLocation,nil,LOCATION_DECK)
	local priority_0,priority_1
	if linkmz_ct<mmz_ct then
		priority_0=fup
		priority_1=fdown_main
	else
		priority_0=fdown_main
		priority_1=fup
	end
	for prio0_c in priority_0:Iter() do
		Duel.SpecialSummonStep(prio0_c,0,tp,tp,true,false,POS_FACEUP)
	end
	for prio1_c in priority_1:Iter() do
		Duel.SpecialSummonStep(prio1_c,0,tp,tp,true,false,POS_FACEUP)
	end
	for fdown_ex_c in fdown_ex:Iter() do
		Duel.SpecialSummonStep(fdown_ex_c,0,tp,tp,true,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsOnField() and rc:IsSummonLocation(LOCATION_DECK|LOCATION_EXTRA)
end
function s.rthcostfilter(c)
	return Duel.IsExistingTarget(Card.IsAbleToHand,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
function s.rthcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.rthcostfilter,1,true,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.rthcostfilter,1,1,true,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end